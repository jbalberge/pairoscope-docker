#!/usr/bin/env bash

# 1 is sample name
# 2 is bam
pairoscope -q 0 -m 1000000 -H 1400 -W 1024 -u 2000 -l 200 \
      -o "${1}".pairoscope.png \
      "${2}" 2 89150000 90280000 \
      "${2}" 4 1800000 2000000 \
      "${2}" 6 41600000 42300000 \
      "${2}" 8 126000000 130500000 \
      "${2}" 8 144000000 145000000 \
      "${2}" 11 68300000 69500000 \
      "${2}" 12 3800000 4800000 \
      "${2}" 14 106000000 107288051 \
      "${2}" 16 78130000 79983897 \
      "${2}" 20 38300000 39600000 \
      "${2}" 22 22350000 23400000 2> "${1}.pairoscope.reads.txt"
    numLines=$(grep -v "Non-matching mate orientation." -c "${1}.pairoscope.reads.txt" || :)
    if [[ $numLines -gt 0 ]]
    then
      grep -v "Non-matching mate orientation." "${1}.pairoscope.reads.txt" |\
      awk -v var1="${1}" 'BEGIN{OFS="\t" ; print "Specimen", "ChrA", "PositionA", "ChrB", "PositionB"}{print var1, $1, $2, $3, $4}' > "${1}.pairoscope.reads.txt"
    else
      echo $'Specimen\tChrA\tPositionA\tChrB\tPositionB' > "${1}.pairoscope.reads.txt"
    fi