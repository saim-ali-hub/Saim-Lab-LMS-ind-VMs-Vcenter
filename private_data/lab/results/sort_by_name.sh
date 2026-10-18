#!/bin/bash

{
    head -n 4 lab235_result.txt
    tail -n +5 lab235_result.txt |
    sort -k2,2 |
    awk 'NF {
        printf "%-5d %-26s %-20s %-6s %-6s %s\n", \
        ++n, $2, $3" "$4, $5, $6, $7
    }'
} > lab235_result_sorted_name.txt
