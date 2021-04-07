# meta_vrl
A viral genome reconstruction tool from metagenomic and metatranscriptomic sequencing data.


For MINIMAP2REF, please download and use a genome sequence data of Wuhan-Hu-1 (MN908947.3)
https://www.ncbi.nlm.nih.gov/nuccore/MN908947.3?report=fasta

## Usage
```bash
mkdir Testdir1
qsub -l s_vmem=10G -l mem_req=10G /home/hoge/META_VRL.sh /home/hoge/SRR10903401_1.fastq /home/hoge/SRR10903401_2.fastq /home/hoge/Testdir1
```
Please replace hoge to your username in NIG supercomputer.
The s_vmem and mem_req are depend on the complexity of the query fastq files. Usually, 10G is enough.
