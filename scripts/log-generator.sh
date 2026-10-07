#!/bin/bash
# log-generator.sh: simulate a CloudByte application log with severity levels.
# Author:  Armin
# Created: 2026-10-07
# Purpose: Append COUNT synthetic timestamped lines to /logs/cloudbyte-app.log.
# Usage:   sudo bash log-generator.sh [count]

set -eo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "Error: log-generator.sh must be run as root (it writes to /logs)."
    echo "Hint: sudo bash $0"
    exit 1
fi

LOG=/logs/cloudbyte-app.log
COUNT="${1:-200}"

for (( i = 0; i < COUNT; i++ )); do
    case $(( RANDOM % 10 )) in
        0|1|2|3|4|5) level=INFO ;;
        6|7)         level=WARN ;;
        8)           level=ERROR ;;
        9)           level=CRITICAL ;;
    esac

    case $level in
        INFO)     msg="request served" ;;
        WARN)     msg="slow response" ;;
        ERROR)    msg="request failed" ;;
        CRITICAL) msg="service unavailable" ;;
    esac

    ts=$(date -d "$(( RANDOM % 24 )) hours ago" '+%Y-%m-%d %H:%M:%S')
    echo "$ts [$level] $msg" >> "$LOG"
    sleep 0.02
done

echo "Wrote $COUNT lines to $LOG."
