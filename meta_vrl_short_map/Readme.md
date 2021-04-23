# META_VRL_Short_Map
A viral genome reconstruction tool from metagenomic and metatranscriptomic sequencing data.
META_VRL_Short_Map is a pipeline for the analysis of paired-end short reads.
This pipeline conducts a reference-based consensus sequence generation and a SNV calling analysis.

## Reference data (Be careful! This section is a copy-pasted description from META_VRL's description and yet under development)
For MINIMAP2REF, please download and use a genome sequence data of Wuhan-Hu-1 (MN908947.3)
https://www.ncbi.nlm.nih.gov/nuccore/MN908947.3?report=fasta
or
http://palaeo.nig.ac.jp/Resources/META_VRL/Wuhan-Hu-1.fasta

For KRAKEN2REF, please download and tar -zxvf from following web link.
http://palaeo.nig.ac.jp/Resources/META_VRL/GRCh38.Wuhan.tar.gz

You need to specify the places of MINIMAP2REF and KRAKEN2REF in NIG supercomputer in the META_VRL.sh file.

## Usage
```bash
mkdir Testdir2
qsub -l s_vmem=32G -l mem_req=32G /home/hoge/META_VRL/meta_vrl_short_map.sh /home/hoge/SRR10903401_1.fastq /home/hoge/SRR10903401_2.fastq /home/hoge/Testdir2
```
Please replace hoge to your username in NIG supercomputer.
Also, please replace hoge in meta_vrl_short_map.sh to your username in NIG supercomputer.
The s_vmem and mem_req are depended on the complexity of the query fastq files. Usually, 32G is enough.
You need to specify an input R1 fastq file, an input R2 fastq file, and an output directory.

## Input and Output
The input files of META_VRL_Short_Map are Illumina paired-end fastq files.
Examples of paired-end fastq files are 
http://palaeo.nig.ac.jp/Resources/META_VRL/SRR10903401_1.fastq.gz
http://palaeo.nig.ac.jp/Resources/META_VRL/SRR10903401_2.fastq.gz

The details of the samples are described in https://www.ncbi.nlm.nih.gov/sra/SRR10903401

The output file of META_VRL_Short_Map is a consensus FASTA file (file name is inputR1filename.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.0.5.anno.vcf.fasta).
and ...
An example of an output file is ...


## Dependencies
META_VRL uses
### fastp
### BWA
### samtools
### Picard
### lofreq
### snpEff
### bcftools

Since the singularity containers of all of these tools exist in NIG supercomputer, you don't need to install and specify the file direction (already each container's file direction has coded in meta_vrl_short_map.sh).
