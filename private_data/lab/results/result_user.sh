#!/bin/bash

STUDENT="${1:-talha.zubair}"

for i in {201..406}; do
    FILE="/var/www/private_data/lab/results/lab${i}_result.txt"

    if [[ -f "$FILE" ]]; then
        RESULT=$(grep -iF "$STUDENT" "$FILE")

        if [[ -n "$RESULT" ]]; then
            echo "===== lab${i} ====="
            echo "$RESULT"
        fi
    fi
done

