# pairoscope-docker

This repo gives a Dockerfile to run pairoscope (https://github.com/genome/pairoscope) v.0.4.2

Original pairoscope v.0.4.2 files have minor corrections (see https://github.com/jbalberge/pairoscope) to automate installation in UBUNTU 18.04 LTS docker image. 

Dockerfile comes with the very convenient TGEN script to annotate discordant reads from immunoglobulin loci and identify initiating and secondary canonical translocations in multiple myeloma (see python script).

Sh file gives general guidelines to test / run pairoscope ; 

WDL file is an example of how to use the docker image in a HPC infrastructure. (in development)

