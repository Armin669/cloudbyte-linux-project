# CloudByte Server Handbook

A runbook for the CloudByte Linux server. Read this before changing users, folders, or cron.

## Server overview

CloudByte is a 12-person startup. This VM is the shared Linux server: accounts, team folders, a dropbox, nightly backups, and scripts that replace the manual steps from Section 1. It started as empty directories and hand-made users. It now has group-based access, an onboarding script, and unattended backup and cleanup jobs.

Built locally with Vagrant. The repo is mounted in the VM at /vagrant.

## Users and groups

CloudByte runs with twelve staff across three teams: Engineering, Marketing, and Operations. Each team has its own group, and two Operations staff also sit in the admins group for sysadmin work. Every user has a standard home directory and a shell login.

| Username | Full name | Group(s) | Department |
| -------- | ---------------- | ------------------ | ----------- |
| alice | Alice Tan | engineering | Engineering |
| bob | Bob Patel | engineering | Engineering |
| carol | Carol O'Sullivan | engineering | Engineering |
| dave | Dave Yamamoto | engineering | Engineering |
| emma | Emma Kowalski | marketing | Marketing |
| frank | Frank Nguyen | marketing | Marketing |
| grace | Grace Okafor | marketing | Marketing |
| henry | Henry Mendez | operations | Operations |
| iris | Iris Brennan | operations | Operations |
| jack | Jack Hossain | operations | Operations |
| kate | Kate Reilly | operations, admins | Operations |
| leo | Leo Costa | operations, admins | Operations |

| Group | Members | Access |
| ----------- | ---------------------------- | ----------------------------------------------------------------------------- |
| engineering | alice, bob, carol, dave | Read/write to /shared/engineering |
| marketing | emma, frank, grace | Read/write to /shared/marketing |
| operations | henry, iris, jack, kate, leo | Read/write to /shared/operations |
| admins | kate, leo | Write to /shared/company-docs and /logs/reports; read dropbox submissions |

Admins post to the company notice board and reports directories and triage the dropbox; team members write only to their own folder. Least-privilege as usual.

Lab accounts created later (morgan, testuser1 to testuser6, loguser1, loguser2) are script tests, not staff.

## Server layout

/shared/engineering is root:engineering mode 2770, setgid, team only.
/shared/marketing is root:marketing mode 2770, setgid, team only.
/shared/operations is root:operations mode 2770, setgid, team only.
/shared/company-docs is root:admins mode 775, admins write, others read.
/shared/dropbox is root:admins mode 1773, sticky; others can write but cannot list.
/shared/backups is root:admins mode 2770, setgid, nightly archives.
/logs/reports is root:admins mode 775, admins write, others read.

2770 keeps a team folder private and stamps new files with the team group. 1773 lets anyone drop a file without browsing the inbox. 775 lets everyone read, and only admins change files.

## Scripts inventory

onboard-user.sh creates a user, sets a temp password, adds a group, and forces a password change. Run by hand. Flags: --csv, --dry-run, --log.

backup-shared.sh makes a tar.gz of /shared, excluding /shared/backups. A trap deletes a partial archive. Cron runs it nightly.

cleanup-backups.sh deletes tar.gz files older than 7 days. --preview lists only. Cron runs it on Sundays.

restore-backup.sh picks an archive and extracts it under /tmp. It refuses /shared. Run by hand.

All of these need root.

## Scheduled jobs

These live in root's crontab on the VM, not in git. Re-add them if the VM is rebuilt.

0 2 * * * runs /vagrant/scripts/backup-shared.sh and logs to /var/log/cloudbyte-backup.log.
0 3 * * 0 runs /vagrant/scripts/cleanup-backups.sh and logs to /var/log/cloudbyte-cleanup.log.

0 2 * * * is 02:00 every day. 0 3 * * 0 is 03:00 on Sunday. Both lines end with >> logfile 2>&1.

## Common operations

sudo bash /vagrant/scripts/onboard-user.sh --dry-run --csv /vagrant/data/new-hires.csv
sudo /vagrant/scripts/backup-shared.sh
sudo /vagrant/scripts/cleanup-backups.sh --preview
sudo crontab -l
tail /var/log/cloudbyte-backup.log
sudo /vagrant/scripts/restore-backup.sh

Preview before a real onboard or cleanup. Never point a restore at /shared.

## Self-checks

Run on the VM:

bash /vagrant/verify-foundations.sh
bash /vagrant/verify-permissions.sh
bash /vagrant/verify-onboarding.sh
bash /vagrant/verify-backup.sh

Foundations checks users, groups, and the first directory modes. Permissions checks setgid, the dropbox, and sample files. Onboarding checks the script, CSV, dry-run, and test users. Backup checks the archive, both scripts, and cron.
