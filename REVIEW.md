A basic overview of the what should be reviewed.

### Prerequisites
- Email account supporting Exchange ActiveSync or CalDAV & Card DAV (a gmail account works fine)
  - Needs access into email
  - Can be removed afterwards (within Gmail/Google)

### Notes
- A visual reference can be found at https://github.com/jobisoft/TbSync/wiki/How-to-get-started
- An initial setup is not needed, feel free to just press cancel and move on
- Click the calendar icon on the top right and verify that it should be empty (as it should by default)
- Click the hamburger icon next on the menubar near the `Tasks` section and click through `Add-ons` > `TbSync`
- With the new window click `Account actions` > `Add new account` > `CalDAV & CardDAV`
- With the new window click `Google` > `Next` > `Next` and login to the Gmail account and allowing TbSync access to the account for the permissions requested before clicking `Finish`
- Check `Enable and Synchronize this account` and wait for the `Status` and `Avaiable resources` sections to pop up and populate
- Check the checkbox next to the calendar icon(s) before clicking `Synchronize now` on the bottom right
- Exit the TbSync settings tab back to the main window and switch to the `Calendar` tab where a "Calendar" should have popped up with the name `Google (your_email_here@gmail.com)` or `Google ...` if there were multiple calendars
- If there were any events in your calendar at Gmail, it should also pop up

### Test Script

```bash
#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nixFlakes

# Run flake checks
nix --experimental-features "flakes nix-command" flake check github:ngi-nix/thunderbird-extensions

# Check the extension in practice
TMP=$(mktemp -d)
PROFILE=$TMP/fakeprofile

mkdir -p $PROFILE
nix --experimental-features "flakes nix-command" build --out-link "$TMP/thunderbird" github:ngi-nix/thunderbird-extensions#packages.x86_64-linux.sample-thunderbird
$TMP/thunderbird/bin/thunderbird --profile $PROFILE

printf "tmp directory %s\n" $TMP
```
