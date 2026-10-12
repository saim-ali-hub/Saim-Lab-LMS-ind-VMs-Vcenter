
#!/bin/bash

INPUT="lab235_result_sorted.txt"
OUTPUT="lab235_result_sorted_percentage.txt"

{
    head -n 4 "$INPUT"

    tail -n +5 "$INPUT" |
    awk '
    NF >= 7 {
        name = $2
        total = $5 + 0
        passed = $6 + 0

        if (!(name in best_passed) ||
            passed > best_passed[name] ||
            (passed == best_passed[name] && total > best_total[name])) {

            best_passed[name] = passed
            best_total[name] = total
            best_row[name] = $0
        }
    }

    END {
        for (name in best_row)
            print best_passed[name] "\t" best_row[name]
    }' |
    sort -k1,1nr -k2,2 |
    awk -F '\t' '
    {
        split($2, a, /[[:space:]]+/)

        printf "%-5d %-26s %-20s %-6s %-6s %s\n", \
            ++n, a[2], a[3] " " a[4], a[5], a[6], a[7]
    }'
} > "$OUTPUT"

