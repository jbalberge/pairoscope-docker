version 1.0

# This WDL takes a BAM as input and runs pairoscope to map (png file) discordant reads on loci from distinct chromosomes
# Is also annotates discordant reads and call translocations events involving immunoglobulin (IG) loci in Multiple Myeloma

# To read more about pairoscope, see :
# - http://pairoscope.sourceforge.net/#Manual
# - https://github.com/genome/pairoscope
# Dockerized pairoscope https://hub.docker.com/repository/docker/jbalberge/pairoscope

# The translocation calling algoritm was primarly developed at TGEN under MIT license
# https://github.com/tgen/phoenix/blob/281cb80221a0dd5ccabac39a326b3a7ff1f1fb19/required_scripts/mm_igtx_pairoscope_calling_b38_356362b.py



workflow RunAndCallPairoscopeIGTx {
  input {
    String sample_name
    File tumor_bam
    File tumor_bam_index
    String pairoscope_docker = "jbalberge/pairoscope:0.0.3"

    Int disk_size = 200
    Int preemptible_tries = 3
    Float mem_size_gb = 4
  }

  call RunPairoscope {
    input:
    tumor_bam=tumor_bam,
    sample_name=sample_name,
    docker_image=pairoscope_docker,
    disk_size = disk_size,
    preemptible_tries = preemptible_tries,
    mem_size_gb = mem_size_gb
  }

  call CallTxFromPairoscopeDiscordantReads {
    input:
    pairoscope_reads=RunPairoscope.OUT_READS,
    docker_image=pairoscope_docker,
    preemptible_tries = preemptible_tries,
    sample_name=sample_name
  }

  output {
    File pairoscope_png = RunPairoscope.OUT_PNG
    File pairoscope_reads = RunPairoscope.OUT_READS
    File pairoscope_calls = CallTxFromPairoscopeDiscordantReads.pairoscope_calls
  }
}

task RunPairoscope {
  # Pairoscope documentation
  # http://pairoscope.sourceforge.net/#Manual
  input {
    File tumor_bam
    String sample_name

    Int preemptible_tries
    Int disk_size
    Float mem_size_gb

    String docker_image
  }
  
  command <<<
    pairoscope -q 0 -m 1000000 -H 1400 -W 1024 -u 2000 -l 200 \
      -o "${sample_name}.pairoscope.png" \
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
      ${BAM} 22 22350000 23400000 2> "${sample_name}.pairoscope.reads.txt"
    numLines=$(grep -v "Non-matching mate orientation." -c "${sample_name}.pairoscope.reads.txt" || :)
    if [[ $numLines -gt 0 ]]
    then
      grep -v "Non-matching mate orientation." "${sample_name}.pairoscope.reads.txt" |\
      awk -v var1="${sample_name}" 'BEGIN{OFS="\t" ; print "Specimen", "ChrA", "PositionA", "ChrB", "PositionB"}{print var1, $1, $2, $3, $4}' > "${sample_name}.pairoscope.reads.txt"
    else
      echo $'Specimen\tChrA\tPositionA\tChrB\tPositionB' > "${sample_name}.pairoscope.reads.txt"
    fi
  >>>

  output {
    File OUT_PNG = "${sample_name}.pairoscope.png"
    File OUT_READS = "${sample_name}.pairoscope.reads.txt"
  }
  runtime {
    preemptible: preemptible_tries
    docker: docker_image
    memory: "~{mem_size_gb} GiB"
    disks: "local-disk " + disk_size + " HDD"
  }
}

task CallTxFromPairoscopeDiscordantReads {
  input {
    String sample_name
    String call_tx_py = "/code/phoenix_pairoscope_code.py"

    File pairoscope_reads

    Int preemptible_tries

    String docker_image
  }
  command {
  python3 ${call_tx_py} \
  --input_file ${pairoscope_reads} \
  --specimen ${sample_name} \
  --output_file "${sample_name}.pairoscope.calls.txt" \
  --window 2000 \
  --window_min 100 \
  --call_requirement 2
  }
  output {
    File pairoscope_calls = "${sample_name}.pairoscope.calls.txt"
  }
  runtime {
    preemptible: preemptible_tries
    docker: docker_image
  }
}