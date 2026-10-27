#!/bin/bash

for i in {201..406}; do
    echo "===== lab${i} ====="
    grep "nakhal.iqbal" "/var/www/private_data/lab/results/lab${i}_result.txt" 2>/dev/null
done

