#!/bin/bash
# disk-usage-tracker.sh: daily per-team disk totals
# Author: Armin
# Created: 2026-10-05
# Purpose: Append one CSV row of /shared team folder sizes.
# Usage: sudo bash disk-usage-tracker.sh

set -eo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "Error: disk-usage-tracker.sh must be run as root."
    echo "Hint: sudo bash $0"
    exit 1
fi

OUT=/shared/company-docs/disk-usage.csv

eng=$(du -sb /shared/engineering | cut -f1)
mkt=$(du -sb /shared/marketing | cut -f1)
ops=$(du -sb /shared/operations | cut -f1)
total=$((eng + mkt + ops))
stamp=$(date '+%Y-%m-%dT%H:%M:%S')

if [ ! -f "$OUT" ]; then
    echo "timestamp,engineering,marketing,operations,total" > "$OUT"
fi

echo "$stamp,$eng,$mkt,$ops,$total" >> "$OUT"
echo "Wrote $stamp to $OUT"