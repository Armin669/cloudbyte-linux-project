#!/bin/bash
# admin-menu.sh: one front door for the six CloudByte admin tools.
# Author:  Armin
# Created: 2026-10-09
# Purpose: Print a numbered menu, guard each tool, run the chosen one, and
#          re-prompt until the user quits.
# Usage:   sudo bash scripts/admin-menu.sh

set -eo pipefail

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    echo "Usage: sudo bash scripts/admin-menu.sh"
    echo "Menu for onboard, backup, cleanup, log generator, log analyser, and health."
    echo "Choose 0 to quit."
    exit 0
fi

if [ "$EUID" -ne 0 ]; then
    echo "Error: this script must be run as root."
    echo "Try: sudo bash $0 $*"
    exit 1
fi

TOOL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ ! -d "$TOOL_DIR" ]; then
    echo "Error: tool directory missing: $TOOL_DIR"
    exit 1
fi

run_tool() {
    local tool="$1"
    shift
    local path="$TOOL_DIR/$tool"
    if [ ! -f "$path" ]; then
        echo "Error: $tool isn't installed ($path)"
        return 0
    fi
    bash "$path" "$@" || echo "Warning: $tool exited with an error."
}

show_latest_health() {
    local latest
    latest="$(ls -1t /logs/health-reports/health-*.txt 2>/dev/null | head -1)"
    if [ -z "$latest" ]; then
        echo "No health report found."
        return 0
    fi
    echo "Latest report: $latest"
    cat "$latest"
}

while true; do
    echo ""
    echo "CloudByte admin menu"
    echo "1) Onboard a user"
    echo "2) Back up /shared"
    echo "3) Preview old-backup cleanup"
    echo "4) Generate a test log"
    echo "5) Analyse logs"
    echo "6) System health report"
    echo "7) View latest health report"
    echo "0) Quit"
    read -rp "Choose: " choice || break
    case "$choice" in
        1) run_tool onboard-user.sh ;;
        2) run_tool backup-shared.sh ;;
        3) run_tool cleanup-backups.sh --preview ;;
        4) run_tool log-generator.sh ;;
        5) run_tool analyse-logs.sh ;;
        6) run_tool system-health.sh ;;
        7) show_latest_health ;;
        0) echo "Bye."; break ;;
        *) echo "invalid choice: $choice" ;;
    esac
done
