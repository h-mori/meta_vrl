# META_VRL_Long_Map
A viral genome reconstruction tool from metagenomic and metatranscriptomic sequencing data.
META_VRL_Long_Map is a pipeline for the analysis of Oxford Nanopore fastq reads.
This pipeline conducts a reference-based consensus sequence generation and a SNV calling analysis.

## Reference data
For MINIMAPREF, please download and use a RefSeq version of genome sequence data of Wuhan-Hu-1 (NC_045512.2)
https://www.ncbi.nlm.nih.gov/nuccore/1798174254?report=fasta
Since snpEff uses the RefSeq version of Wuhan-Hu-1 genome for the snpEff reference database, we use NC_045512.2 not MN908947.3 in the SNP reference.

You need to specify the places of MINIMAPREF in NIG supercomputer in the meta_vrl_long_map.sh file.

## Usage
```bash
mkdir Testdir3
qsub -l s_vmem=50G -l mem_req=50G /home/hoge/META_VRL/meta_vrl_long_map.sh /home/hoge/Nanopore_Sample1.fastq /home/hoge/Testdir3
```
Please replace hoge to your username in NIG supercomputer.
Also, please replace hoge in meta_vrl_long_map.sh to your username in NIG supercomputer.
The s_vmem and mem_req are depended on the complexity of the query fastq files. Usually, 50G is enough (medaka, bcftools, pangolin use more than 16GB RAM).
You need to specify an input fastq file and an output directory.

## Input and Output
The input files of META_VRL_Long_Map is an Oxford Nanopore fastq file.
Examples of a fastq file is ... 

The details of the samples are described in ...

The output files of META_VRL_Long_Map are same as META_VRL_Short_Map.
See https://github.com/h-mori/meta_vrl/tree/main/meta_vrl_short_map


## Dependencies
META_VRL_Long_Map uses
### medaka
### Minimap2
### Cutadapt
### samtools
### bedtools
### ngsutils
### pyfaidx
### LoFreq
### snpEff
### bcftools
### Pangolin

Since the singularity containers of most of these tools exist in NIG supercomputer, you don't need to install and specify the file direction (already each container's file direction has coded in meta_vrl_long_map.sh). medaka and pangolin are exceptions.
