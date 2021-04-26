# META_VRL_Long_Map
A viral genome reconstruction tool from metagenomic and metatranscriptomic sequencing data.
META_VRL_Long_Map is a pipeline for the analysis of Oxford Nanopore fast5 and fastq reads.
This pipeline conducts a reference-based consensus sequence generation and a SNV calling analysis.

## Reference data
For BWAREF, please download and use a RefSeq version of genome sequence data of Wuhan-Hu-1 (NC_045512.2)
https://www.ncbi.nlm.nih.gov/nuccore/1798174254?report=fasta
Since snpEff uses the RefSeq version of Wuhan-Hu-1 genome for the snpEff reference database, we use NC_045512.2 not MN908947.3 in the SNP reference.

You need to specify the places of BWAREF in NIG supercomputer in the meta_vrl_long_map.sh file.

## Usage
```bash
mkdir Testdir3
qsub -l s_vmem=32G -l mem_req=32G /home/hoge/META_VRL/meta_vrl_long_map.sh /home/hoge/Nanopore_Sample1.fastq /home/hoge/Nanopore_Sample1_fast5_directory /home/hoge/Testdir3
```
Please replace hoge to your username in NIG supercomputer.
Also, please replace hoge in meta_vrl_long_map.sh to your username in NIG supercomputer.
The s_vmem and mem_req are depended on the complexity of the query fastq files. Usually, 32G is enough (bcftools and pangolin use more than 16GB RAM).
You need to specify an input fastq file, an input fast5 direcotry, and an output directory.

## Input and Output
The input files of META_VRL_Long_Map are Oxford Nanopore fast5 and fastq files.
Examples of fast5 and fastq files are ... 

The details of the samples are described in ...

The output files of META_VRL_Long_Map are same as META_VRL_Short_Map.
See https://github.com/h-mori/meta_vrl/tree/main/meta_vrl_short_map


## Dependencies
META_VRL_Long_Map uses
### Nanopolish
### Minimap2
### samtools
### bedtools
### ngsutils
### pyfaidx
### LoFreq
### snpEff
### bcftools
### Pangolin

Since the singularity containers of all of these tools exist in NIG supercomputer, you don't need to install and specify the file direction (already each container's file direction has coded in meta_vrl_long_map.sh).
