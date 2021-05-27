BAM=/data/bams/toyBam.bam

SAMPLE=toySAMPLE

OUT_PNG=/data/output/${SAMPLE}.pairoscope.png
OUT_READS=/data/output/${SAMPLE}.pairoscope.reads.txt
OUT_CALLS=/data/output/${SAMPLE}.pairoscope.calls.txt

CALL_IG_TRANSLOCATIONS_PYTHON="/data/code/phoenix_pairoscope_code.py"

pairoscope -q 0 -m 1000000 -H 1400 -W 1024 -u 2000 -l 200 \
	-o ${OUT_PNG} \
	${BAM} 2 89150000 90280000 \
	${BAM} 4 1800000 2000000 \
	${BAM} 6 41600000 42300000 \
	${BAM} 8 126000000 130500000 \
	${BAM} 8 144000000 145000000 \
	${BAM} 11 68300000 69500000 \
	${BAM} 12 3800000 4800000 \
	${BAM} 14 106000000 107288051 \
	${BAM} 16 78130000 79983897 \
	${BAM} 20 38300000 39600000 \
	${BAM} 22 22350000 23400000 2> ${OUT_READS}

numLines=$(grep -v "Non-matching mate orientation." -c ${OUT_READS} || :)
if [[ $numLines -gt 0 ]]; then
  grep -v "Non-matching mate orientation." ${OUT_READS} |\
  awk -v var1="$SAMPLE" 'BEGIN{OFS="\t" ; print "Specimen", "ChrA", "PositionA", "ChrB", "PositionB"}{print var1, $1, $2, $3, $4}' > \
  ${OUT_READS}
else
  echo $'Specimen\tChrA\tPositionA\tChrB\tPositionB' > ${OUT_READS}
fi

python3 ${CALL_IG_TRANSLOCATIONS_PYTHON} \
  --input_file ${OUT_READS} \
  --specimen ${SAMPLE} \
  --output_file ${OUT_CALLS} \
  --window 2000 \
  --window_min 100 \
  --call_requirement 2
