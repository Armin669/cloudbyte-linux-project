#!/bin/bash
# analyse-logs.sh: summarise /logs/cloudbyte-app.log
# Usage: sudo bash analyse-logs.sh [--level LEVEL] [--help]

LOG=/logs/cloudbyte-app.log
LEVEL=""

while [ $# -gt 0 ]; do
    case "$1" in
        --level)
            LEVEL="$2"
            shift 2
            ;;
        --help)
            echo "Usage: sudo bash analyse-logs.sh [--level INFO|WARN|ERROR|CRITICAL]"
            echo "No --level means the full log."
            exit 0
            ;;
        *)
            echo "Error: unknown option '$1'"
            echo "Try: sudo bash analyse-logs.sh --help"
            exit 1
            ;;
    esac
done

if [ ! -s "$LOG" ]; then
    echo "Error: $LOG is missing or empty."
    exit 1
fi

STAMP=$(date +%Y%m%d-%H%M%S)
REPORT="/logs/reports/log-analysis-${STAMP}.txt"
mkdir -p /logs/reports

if [ -n "$LEVEL" ]; then
    TITLE="Log analysis for [$LEVEL] only"
    DATA=$(grep "\[$LEVEL\]" "$LOG" || true)
else
    TITLE="Log analysis (all levels)"
    DATA=$(cat "$LOG")
fi

{
    echo "===== $TITLE ====="
    echo "Source: $LOG"
    echo "Generated: $(date)"
    echo
    echo "----- Counts by severity -----"
    if [ -n "$DATA" ]; then
        printf '%s\n' "$DATA" | grep -oE '\[(INFO|WARN|ERROR|CRITICAL)\]' | sort | uniq -c | sort -rn
    else
        echo "(no matching lines)"
    fi
    echo
    echo "----- Busiest hour -----"
    if [ -n "$DATA" ]; then
        printf '%s\n' "$DATA" | awk '{print $2}' | cut -d: -f1 | sort | uniq -c | sort -rn | head -1
        echo "The line above is the busiest hour."
    else
        echo "(no matching lines)"
    fi
    echo
    echo "----- CRITICAL entries -----"
    if [ -n "$LEVEL" ] && [ "$LEVEL" != "CRITICAL" ]; then
        echo "(skipped: this report is scoped to $LEVEL, not CRITICAL)"
    else
        printf '%s\n' "$DATA" | grep '\[CRITICAL\]' || echo "(none)"
    fi
} | tee "$REPORT"

echo "Report written to $REPORT"
