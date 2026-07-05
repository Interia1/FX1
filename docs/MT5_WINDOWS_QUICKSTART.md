# MT5 Windows Quickstart (No More Manual Copy)

## One-time setup

1. Open MT5 -> `File` -> `Open Data Folder`.
2. Open `MQL5` folder.
3. Clone repository in that folder:
   - `git clone https://github.com/Interia1/FX1.git FX1_repo`
4. Create links (run CMD as Administrator):
   - `mklink "Experts\\FX1_EA.mq5" "%CD%\\FX1_repo\\src\\Experts\\FX1_EA.mq5"`
   - `mklink /D "Include\\FX1" "%CD%\\FX1_repo\\src\\Include\\FX1"`

## Daily flow

1. Run `FX1_repo\\scripts\\windows\\01_pull_latest.bat`
2. Open MetaEditor and compile `FX1_EA.mq5` with `F7`
3. Test in Strategy Tester (`Ctrl+R`)

## Save your changes back to GitHub

1. Run `FX1_repo\\scripts\\windows\\02_commit_and_push.bat`
2. Enter commit message
3. Done

## Important

If compiler still shows old errors, you are likely compiling stale local files.
Always run `01_pull_latest.bat` first.
