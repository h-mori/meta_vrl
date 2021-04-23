# META_VRL
A viral genome reconstruction tool from metagenomic and metatranscriptomic sequencing data.

## Reference data
For MINIMAP2REF, please download and use a genome sequence data of Wuhan-Hu-1 (MN908947.3)
https://www.ncbi.nlm.nih.gov/nuccore/MN908947.3?report=fasta
or
http://palaeo.nig.ac.jp/Resources/META_VRL/Wuhan-Hu-1.fasta

For KRAKEN2REF, please download and tar -zxvf from following web link.
http://palaeo.nig.ac.jp/Resources/META_VRL/GRCh38.Wuhan.tar.gz

You need to specify the places of MINIMAP2REF and KRAKEN2REF in NIG supercomputer in the META_VRL.sh file.

## Usage
```bash
mkdir Testdir1
qsub -l s_vmem=10G -l mem_req=10G /home/hoge/META_VRL.sh /home/hoge/SRR10903401_1.fastq /home/hoge/SRR10903401_2.fastq /home/hoge/Testdir1
```
Please replace hoge to your username in NIG supercomputer.
Also, please replace hoge in META_VRL.sh to your username in NIG supercomputer.
The s_vmem and mem_req are depended on the complexity of the query fastq files. Usually, 10G is enough.
You need to specify an input R1 fastq file, an input R2 fastq file, and an output directory.

## Input and Output
The input files of META_VRL are Illumina paired-end fastq files.
Examples of paired-end fastq files are 
http://palaeo.nig.ac.jp/Resources/META_VRL/SRR10903401_1.fastq.gz
http://palaeo.nig.ac.jp/Resources/META_VRL/SRR10903401_2.fastq.gz

The details of the samples are described in https://www.ncbi.nlm.nih.gov/sra/SRR10903401

The output file of META_VRL is a contig FASTA file (file name is inputR1filename.final.contigs.cleaned.2000.fa).
In default, the contigs larger than 2,000 bases are outputted.

An example of an output file is https://github.com/h-mori/meta_vrl/blob/main/SRR10903401_1.fastq.final.contigs.cleaned.2000.fa


## Dependencies
META_VRL uses
### fastp
### Kraken2
### MEGAHIT
### Minimap2
### samtools
### seqkit
Since the singularity containers of all of these tools exist in NIG supercomputer, you don't need to install and specify the file direction (already each container's file direction has coded in META_VRL.sh).

