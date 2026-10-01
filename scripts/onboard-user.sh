#!/bin/bash
# onboard-user.sh: CloudByte Solutions onboarding automation
# Author: Armin
# Created: 2026-09-30
# Usage: sudo bash onboard-user.sh
# Usage: sudo bash onboard-user.sh --csv path/to/new-hires.csv
# Usage: sudo bash onboard-user.sh --dry-run

set -eo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "Error: this script must be run as root."
    echo "Try: sudo bash $0 $*"
    exit 1
fi

TEMP_PASSWORD="ChangeMe123!"
DRY_RUN=false
LOG=false
CSV_FILE=""

while [ $# -gt 0 ]; do
    case "$1" in
        --csv)
            CSV_FILE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --log)
            LOG=true
            shift
            ;;
        -h|--help)
            grep '^# Usage:' "$0" | sed 's/^# //'
            exit 0
            ;;
        *)
            echo "Error: unknown argument '$1'." >&2
            exit 1
            ;;
    esac
done

create_user() {
    local username="$1"
    local group="$2"
    local fullname="$3"

    if [ "$DRY_RUN" = true ]; then
        echo "[dry-run] would create $username in $group with temp password"
        return 0
    fi

    if ! getent group "$group" >/dev/null 2>&1; then
        echo "Error: group '$group' does not exist for user '$username'."
        return 1
    fi

    if getent passwd "$username" >/dev/null 2>&1; then
        echo "Skip: user '$username' already exists."
        return 0
    fi

    useradd -m -c "$fullname" "$username"
    echo "$username:$TEMP_PASSWORD" | chpasswd
    usermod -aG "$group" "$username"
    chage -d 0 "$username"

    echo "Created $username in group $group with temp password (must change on first login)."

    if [ "$LOG" = true ]; then
        echo "$(date "+%Y-%m-%d %H:%M:%S")  created  $username  $group" >> /var/log/cloudbyte-onboarding.log
    fi
}

if [ -n "$CSV_FILE" ]; then
    if [ ! -f "$CSV_FILE" ]; then
        echo "Error: CSV file '$CSV_FILE' not found."
        exit 3
    fi
    failures=0
    { read -r _header
      while IFS=, read -r u g f || [ -n "$u" ]; do
          [ -z "$u" ] && continue
          if ! create_user "$u" "$g" "$f"; then
              failures=$((failures + 1))
          fi
      done
    } < "$CSV_FILE"
    [ "$failures" -gt 0 ] && exit 4 || exit 0
else
    read -rp "Username: "  username
    read -rp "Group: "     group
    read -rp "Full name: " fullname
    create_user "$username" "$group" "$fullname"
fi