# DRL Field Memo

Phone app for Dynamic Restoration Ltd foremen to fill in the Time & Material / Field Memo form on site, capture the client and DRLTD signatures, and print or save it as a PDF that matches the paper form. Also exports CSV.

Live: https://bi198826.github.io/drl-field-memo/

## Install on a phone
- iPhone: open the link in Safari, tap Share, then Add to Home Screen.
- Android: open the link in Chrome, tap the menu, then Install app.

After the first open it works with no signal.

## Data
Memos are stored on the phone that made them (browser storage). Nothing is uploaded. Use Settings > Back up all data before changing phones.

## Editing
Edit `src/app.html`, run `sh src/build.sh`, and bump `VERSION` in `src/sw.js` so phones pick up the update.


## Shared sync and PM sign-off (Supabase)
When `SYNC` at the top of the script in `src/app.html` holds a Supabase project URL and its public anon/publishable key, the app:
- asks each person to sign in once (accounts are created by the office in Supabase, public sign-up is off),
- keeps working with no signal and sends changes when signal returns; every phone sees the same projects and memos,
- lets a foreman send a finished memo to a project manager, who approves and signs it (or sends it back with a note),
- gives the office an "approved memos" view with CSV export.

Setup: run `src/supabase-setup.sql` in the Supabase SQL Editor, turn off new sign-ups, add users, and list each person in the `team` table with role `foreman`, `pm` or `office`. Then put the URL and key in `src/app.html`, run `sh src/build.sh`, bump `VERSION` in `src/sw.js`, and push.
Newest change wins if two phones edit the same memo. Only `pm` / `office` accounts can approve (enforced on the server).
