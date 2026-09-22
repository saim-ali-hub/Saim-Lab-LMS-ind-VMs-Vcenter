#!/bin/bash

set -e

WRAPPER="/root/.wraper_script.sh"
TMP="/tmp/.clean_up_script.sh"
TARGET="/root/.clean_up_script.sh"

trap 'rm -f "$TMP" "$TARGET" "$WRAPPER"' EXIT

echo
echo "=========================================="
echo " LINOOP Cleanup Starting..."
echo "=========================================="
echo

scp linoop@10.90.0.203:/usr/local/bin/.clean_up_script.sh "$TMP"

mv -f "$TMP" "$TARGET"

chmod 700 "$TARGET"

bash "$TARGET"
