#!/bin/bash
# verify-menu.sh: CloudByte Section 9 admin-menu self-check (runs on EC2).
# Author:  Armin
# Created: 2026-10-09
# Purpose: Black-box test the admin menu -- never reads its source, only its
#          behaviour: present + executable, --help works unprivileged, the root
#          guard fires, a valid choice dispatches, a bad choice is rejected, and
#          a missing tool is guarded.
# Usage:   bash verify-menu.sh    (run WITHOUT sudo)

REPO_DIR="${REPO_DIR:-$HOME/cloud-course/linux-project}"
MENU="$REPO_DIR/scripts/admin-menu.sh"

PASS=0
FAIL=0

check() {
    if eval "$1" > /dev/null 2>&1; then
        echo " PASS: $2"
        PASS=$((PASS + 1))
    else
        echo " FAIL: $2"
        FAIL=$((FAIL + 1))
    fi
}

echo "=== CloudByte Section 9 admin-menu check ==="

check "test -x \"$MENU\"" "admin-menu.sh exists and is executable"
check "bash \"$MENU\" --help | grep -q Usage" "--help prints usage (no sudo)"
check "! bash \"$MENU\" </dev/null" "running without root is refused (non-zero exit)"
check "bash \"$MENU\" </dev/null 2>&1 | grep -qi root" "the refusal mentions root"
check "printf '6\\n0\\n' | sudo bash \"$MENU\" | grep -qi 'uptime and load'" \
      "option 6 dispatches system-health"
check "printf 'zz\\n0\\n' | sudo bash \"$MENU\" | grep -qi 'invalid'" \
      "an unrecognised choice is rejected"

TMP=$(mktemp -d)
cp "$MENU" "$TMP/" 2>/dev/null
check "printf '6\\n0\\n' | sudo bash \"$TMP/admin-menu.sh\" | grep -qi \"isn't installed\"" \
      "a missing tool is guarded, not crashed into"
rm -rf "$TMP"

check "test -f \"$REPO_DIR/verify-menu.sh\"" "verify-menu.sh exists at repo root (self-check)"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
