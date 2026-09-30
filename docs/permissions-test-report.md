# CloudByte Permissions Test Report: Section 2

Date: 2026-09-29
Author: Armin

| User | Action | Expected | Observed |
| ----- | --------------------------------------------------- | --------- | ---------------------------------------------------------------- |
| alice | touch fresh-from-alice.txt in /shared/engineering | allow | allow; group engineering (setgid) |
| - | find /shared/engineering -type f -group engineering | all files | all files listed after chgrp -R |
| emma | ls /shared/dropbox | deny | deny |
| emma | echo > /shared/dropbox/emma-note.txt | allow | allow |
| alice | cat /shared/dropbox/emma-note.txt (known path) | allow | allow; dropbox hides listing, not known-path read |
| alice | rm /shared/dropbox/emma-note.txt | deny | deny (sticky bit) |
| kate | ls /shared/dropbox | allow | allow |
| kate | cat /shared/dropbox/emma-note.txt | allow | allow |

## Notes

- Mode 2770 (setgid) tags new team files with the team group.
- Mode 1773 (sticky) stops deleting someone else's dropbox file.
- First we used 2770, then removed setgid for an older page, then put 2770 back. The leftover "s" was setgid.
