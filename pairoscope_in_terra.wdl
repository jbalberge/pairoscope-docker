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
    String pairoscope_docker = "jbalberge/pairoscope:0.0.6"

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
    File? pairoscope_png = RunPairoscope.OUT_PNG
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
  command {
    echo "Running pairoscope ..."
    echo "Sample: ~{sample_name}"
    /code/pairoscope.sh "~{sample_name}" "~{tumor_bam}"
  }
  output {
    File OUT_READS = "~{sample_name}.pairoscope.reads.txt"
    File? OUT_PNG = "~{sample_name}.pairoscope.png"
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
  echo "Processing discordant reads ..."
  echo "Sample: ${sample_name}"
  echo "Code: ${call_tx_py}"
  python3 ~{call_tx_py} \
  --input_file ~{pairoscope_reads} \
  --specimen ~{sample_name} \
  --output_file "~{sample_name}.pairoscope.calls.txt" \
  --window 2000 \
  --window_min 100 \
  --call_requirement 2
  }
  output {
    File pairoscope_calls = "~{sample_name}.pairoscope.calls.txt"
  }
  runtime {
    preemptible: preemptible_tries
    docker: docker_image
  }
}