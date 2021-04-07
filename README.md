# meta_vrl
A viral genome reconstruction tool from metagenomic and metatranscriptomic sequencing data.

## Reference data
For MINIMAP2REF, please download and use a genome sequence data of Wuhan-Hu-1 (MN908947.3)
https://www.ncbi.nlm.nih.gov/nuccore/MN908947.3?report=fasta

For KRAKEN2REF, please download and tar -zxvf from following web link.
http://palaeo.nig.ac.jp/Resources/META_VRL/GRCh38.Wuhan.tar.gz

You need to specify the places of MINIMAP2REF and KRAKEN2REF in NIG supercomputer in the META_VAL.sh file.

## Test data
You can obtain test query fastq files from
http://palaeo.nig.ac.jp/Resources/META_VRL/SRR10903401_1.fastq.gz
http://palaeo.nig.ac.jp/Resources/META_VRL/SRR10903401_2.fastq.gz

The details of the fastq files are described in https://www.ncbi.nlm.nih.gov/sra/SRR10903401

## Usage
```bash
mkdir Testdir1
qsub -l s_vmem=10G -l mem_req=10G /home/hoge/META_VRL.sh /home/hoge/SRR10903401_1.fastq /home/hoge/SRR10903401_2.fastq /home/hoge/Testdir1
```
Please replace hoge to your username in NIG supercomputer.
Also, please replace hoge in META_VAL.sh to your username in NIG supercomputer.
The s_vmem and mem_req are depend on the complexity of the query fastq files. Usually, 10G is enough.
You need to specify an input R1 fastq file, an input R2 fastq file, and an output directory.
