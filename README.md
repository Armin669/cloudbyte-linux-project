# CloudByte Solutions, Linux Server Project

A multi-user Linux server for a 12-person startup, built from scratch on Amazon Linux 2023 and deployed to AWS EC2. Users and groups, permission-controlled shared storage, and a set of bash tools that automate onboarding, backups, log analysis, and system-health reporting.

## Skills demonstrated

- User and group administration; permission models and least-privilege design
- Bash automation: onboarding, backups, log generation and analysis, health reporting
- Scheduling with cron; reading and parsing log files
- Deploying and operating a remote server over SSH on AWS EC2

## Repository layout

```text
linux-project/
├── README.md
├── Vagrantfile
├── .gitignore
├── data/
│   ├── new-hires.csv            # sample hires for the onboarding script
│   └── cloudbyte-users.csv      # the twelve-person roster
├── docs/
│   ├── server-setup-log.txt     # how the users, groups, and folders were built
│   ├── permissions-test-report.md
│   └── differences-log.txt      # what changed between the local VM and EC2
├── scripts/
│   ├── onboard-user.sh          # interactive or CSV user onboarding
│   ├── offboard-user.sh         # remove a user account
│   ├── backup-shared.sh         # date-stamped /shared backups
│   ├── cleanup-backups.sh       # retention, with --preview
│   ├── restore-backup.sh        # restore a backup archive
│   ├── disk-usage-tracker.sh    # disk-usage snapshot
│   ├── log-generator.sh         # simulated application log
│   ├── analyse-logs.sh          # severity counts, worst hour, criticals
│   ├── system-health.sh         # uptime, memory, disk, service report
│   ├── admin-menu.sh            # one menu for the tools above
│   └── deploy-to-ec2.sh         # resync scripts and data to EC2
├── verify-foundations.sh
├── verify-permissions.sh
├── verify-onboarding.sh
├── verify-backup.sh
├── verify-ec2.sh
├── verify-logs.sh
├── verify-health.sh
└── verify-menu.sh