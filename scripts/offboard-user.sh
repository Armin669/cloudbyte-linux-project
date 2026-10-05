#!/bin/bash
# offboard-user.sh: archive a leaving user's home, then remove the account
# Author: Armin
# Created: 2026-10-05
# Purpose: Keep a handover archive, then delete the user and home separately.
# Usage: sudo bash offboard-user.sh

set -eo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "Error: offboard-user.sh must be run as root."
    echo "Hint: sudo bash $0"
    exit 1
fi

confirm() {
    local prompt="$1"
    read -rp "$prompt [y/N] " reply
    case "$reply" in
        y|Y|yes|Yes) return 0 ;;
        *)           return 1 ;;
    esac
}

read -rp "Username to offboard: " username

if ! id "$username" >/dev/null 2>&1; then
    echo "Error: user '$username' does not exist."
    exit 1
fi

OFFBOARD_DIR=/shared/backups/offboarded-users
mkdir -p "$OFFBOARD_DIR"
chmod 700 "$OFFBOARD_DIR"
chmod g-s "$OFFBOARD_DIR"
chown root:root "$OFFBOARD_DIR"

ARCHIVE="$OFFBOARD_DIR/${username}-$(date +%F).tar.gz"

if ! confirm "Archive /home/$username and delete the account?"; then
    echo "Cancelled."
    exit 0
fi

tar -czf "$ARCHIVE" -C /home "$username"
userdel "$username"
rm -rf "/home/$username"

echo "Offboarded $username. Archive: $ARCHIVE"