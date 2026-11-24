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
