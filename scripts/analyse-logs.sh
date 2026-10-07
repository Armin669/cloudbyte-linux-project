#!/bin/bash
# analyse-logs.sh: summarise /logs/cloudbyte-app.log
# Author:  Armin
# Created: 2026-10-07
# Purpose: Count levels, name the busiest hour, list CRITICAL lines.
# Usage:   sudo bash analyse-logs.sh

set -eo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "Error: analyse-logs.sh must be run as root (it writes to /logs/reports)."
    echo "Hint: sudo bash $0"
    exit 1
fi

LOG=/logs/cloudbyte-app.log
STAMP=$(date '+%Y-%m-%d_%H-%M-%S')
REPORT="/logs/reports/log-analysis-${STAMP}.txt"

{
    echo "Source: $LOG"
    echo "Total entries: $(wc -l < "$LOG")"
    echo
    echo "Count by severity"
    awk '{ print $3 }' "$LOG" | sort | uniq -c | sort -rn
    echo
    echo "Busiest hour"
    awk '{ print $2 }' "$LOG" | cut -c1-2 | sort | uniq -c | sort -rn | head -1
    echo
    echo "CRITICAL entries"
    grep '\[CRITICAL\]' "$LOG" || echo "(none)"
} | tee "$REPORT"
