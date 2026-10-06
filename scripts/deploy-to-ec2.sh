#!/bin/bash
# deploy-to-ec2.sh: resync scripts, data, and verify-ec2.sh to EC2
# Author: Armin
# Created: 2026-10-06
# Purpose: One command to refresh the repeatable EC2 files from the laptop.
# Usage: bash scripts/deploy-to-ec2.sh
# Usage: bash scripts/deploy-to-ec2.sh --dry-run
# Usage: bash scripts/deploy-to-ec2.sh --help

set -eo pipefail

DRY_RUN=false
HOST_ALIAS=cloudbyte-ec2
REMOTE_DIR='~/cloud-course/linux-project'

while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "Usage: bash scripts/deploy-to-ec2.sh [--dry-run|--help]"
            echo "Sync scripts/, data/, and verify-ec2.sh to EC2."
            echo "Does not sync docs/."
            exit 0
            ;;
        *)
            echo "Error: unknown argument '$1'." >&2
            echo "Hint: bash scripts/deploy-to-ec2.sh --help" >&2
            exit 1
            ;;
    esac
done

run() {
    if [ "$DRY_RUN" = true ]; then
        echo "[dry-run] $*"
    else
        echo "Running: $*"
        eval "$1"
    fi
}

run "ssh $HOST_ALIAS 'mkdir -p $REMOTE_DIR'"
run "scp -r scripts $HOST_ALIAS:$REMOTE_DIR/"
run "scp -r data $HOST_ALIAS:$REMOTE_DIR/"
run "scp verify-ec2.sh $HOST_ALIAS:$REMOTE_DIR/"

echo "Done."