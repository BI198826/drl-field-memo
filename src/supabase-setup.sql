-- DRL Field Memo: shared storage for projects and memos.
-- Paste all of this into Supabase > SQL Editor > New query, then press Run. Safe to run again.

create table if not exists public.records (
  kind text not null check (kind in ('job', 'ticket', 'settings')),
  id text not null,
  data jsonb not null default '{}'::jsonb,
  deleted boolean not null default false,
  mod bigint not null default 0,            -- when the phone made the change (ms)
  updated_by text,                          -- email of the signed-in foreman
  seq bigint not null default 0,            -- increases on every change; phones pull everything after the last seq they saw
  updated_at timestamptz not null default now(),
  primary key (kind, id)
);
create index if not exists records_seq_idx on public.records (seq);
create sequence if not exists public.records_seq;

-- Who is who. Add one row per person in Table Editor > team: their sign-in email, name, and role
-- (foreman, pm or office). Anyone not listed is treated as a foreman. Only pm and office can sign off memos.
create table if not exists public.team (
  email text primary key,
  name text not null default '',
  role text not null default 'foreman' check (role in ('foreman', 'pm', 'office'))
);
alter table public.team enable row level security;
drop policy if exists "team can read team" on public.team;
create policy "team can read team" on public.team for select to authenticated using (true);
revoke all on public.team from anon;
grant select on public.team to authenticated;

-- Newest change wins. A phone that was offline with an older edit cannot overwrite a newer one.
create or replace function public.records_stamp() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if tg_op = 'UPDATE' and new.mod < old.mod then
    new.data := old.data; new.deleted := old.deleted; new.mod := old.mod; new.updated_by := old.updated_by;
  else
    new.updated_by := coalesce(auth.jwt() ->> 'email', new.updated_by);
    -- only a pm or office account can approve or send back a memo; anyone else's attempt is ignored
    if new.kind = 'ticket'
       and coalesce(new.data #>> '{approval,status}', '') in ('approved', 'returned')
       and (case when tg_op = 'INSERT'
                 -- an upsert of an existing memo is checked by the update step that follows, against the stored copy
                 then not exists (select 1 from public.records r where r.kind = new.kind and r.id = new.id)
                 else (new.data -> 'approval') is distinct from (old.data -> 'approval') end)
       and not exists (select 1 from public.team t where lower(t.email) = lower(auth.jwt() ->> 'email') and t.role in ('pm', 'office')) then
      if tg_op = 'INSERT' then new.data := new.data - 'approval';
      else new.data := jsonb_set(new.data, '{approval}', coalesce(old.data -> 'approval', 'null'::jsonb)); end if;
      new.mod := new.mod + 1; -- so the phone that sent it picks up the corrected copy
    end if;
  end if;
  new.seq := nextval('public.records_seq');
  new.updated_at := now();
  return new;
end $$;

drop trigger if exists records_stamp on public.records;
create trigger records_stamp before insert or update on public.records
  for each row execute function public.records_stamp();

-- Only signed-in foremen can read or write. Nobody can hard-delete (deletes are flagged and synced).
alter table public.records enable row level security;
drop policy if exists "team can read" on public.records;
drop policy if exists "team can add" on public.records;
drop policy if exists "team can change" on public.records;
create policy "team can read" on public.records for select to authenticated using (true);
create policy "team can add" on public.records for insert to authenticated with check (true);
create policy "team can change" on public.records for update to authenticated using (true) with check (true);

revoke all on public.records from anon;
grant select, insert, update on public.records to authenticated;
