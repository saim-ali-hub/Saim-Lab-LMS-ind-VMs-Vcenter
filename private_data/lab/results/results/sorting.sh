#!/bin/bash
LAB=lab204
INPUT="/var/www/private_data/lab/results/${LAB}_result.txt"
OUTPUT="/var/www/private_data/lab/results/${LAB}_result_sorted.txt"
awk '
BEGIN {
    OFS="|"
}

# Match quiz records
/^[[:space:]]*[0-9]+[[:space:]]+/ {

    pct=$NF
    gsub("%","",pct)

    total=$(NF-2)
    passed=$(NF-1)

    date=$(NF-4)" "$(NF-3)

    name=""
    for(i=2;i<=NF-5;i++){
        if(name=="")
            name=$i
        else
            name=name" "$i
    }

    key=tolower(name)

    # Remove null entries
    if(key=="null")
        next

    # Remove Saim Ali (optional)
    if(key=="saim ali")
        next

    if(!(key in best_pct) || pct > best_pct[key]){
        best_pct[key]=pct
        best_line[key]=name OFS date OFS total OFS passed OFS pct
    }
}

END{
    for(i in best_line)
        print best_line[i]
}
' "$INPUT" | sort -t'|' -k5,5nr -k1,1 > /tmp/quiz_final.tmp


{
echo "Result - $LAB"
echo "============================================================================="
echo "Sr  Username                  Date                   Total  Passed Percentage"
echo "-----------------------------------------------------------------------------"
n=1

while IFS="|" read -r name date total passed pct
do
    printf "%-3s %-25s %-22s %-6s %-6s %s%%\n" \
        "$n" "$name" "$date" "$total" "$passed" "$pct"
    ((n++))
done < /tmp/quiz_final.tmp

} > "$OUTPUT"


