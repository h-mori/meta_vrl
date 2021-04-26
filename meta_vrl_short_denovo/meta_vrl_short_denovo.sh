#!/bin/sh
#$ -S /bin/sh
#$ -cwd
# USAGE: this_shell_script input_R1 input_R2 output_dir
# input_R1=$1
# input_R2=$2
# output_dir=$3
KRAKEN2REF=/home/hoge/META_VRL/GRCh38.Wuhan
MINIMAP2REF=/home/hoge/META_VRL/WuHan.fasta
LOGFILE="$3/meta_vrl.log"
if [ $# -ne 3 ]; then
  echo "you specified $# arguments." 1>&2
  echo "But this program can only use 3 arguments." 1>&2
  exit 1
fi
if [ ! -f $1 ]; then
	echo "No $1 file exist." 1>&2
	exit 1
fi
if [ ! -f $2 ]; then
	echo "No $2 file exist." 1>&2
	exit 1
fi
if [ ! -d $3 ]; then
	echo "$3 directory does not exist. please mkdir" 1>&2
	exit 1
fi
touch $LOGFILE
 if [ ! -f $LOGFILE ]; then
  echo "Error cannot create $LOGFILE."
  exit 1;
fi
{
DE0=`basename "$1"`
DE1=`basename "$2"`
cp "$1" "$3/$DE0"
cp "$2" "$3/$DE1"
singularity exec /usr/local/biotools/f/fastp\:0.20.1--h8b12597_0 fastp -i $3/$DE0 -o $3/$DE0.qf.fastq -I $3/$DE1 -O $3/$DE1.qf.fastq -3 -n 1 -l 50 -w 1 -x
singularity exec /usr/local/biotools/k/kraken2\:2.1.1--pl526hc9558a2_0 kraken2 --db $KRAKEN2REF --paired --classified-out $3/cseqs#.fq $3/$DE0.qf.fastq $3/$DE1.qf.fastq
grep -A 3 "2697049$" $3/cseqs_1.fq | grep -v "^--" | sed -e 's/kraken:taxid|2697049//g' > $3/cseqs_1.virus2.fq
grep -A 3 "2697049$" $3/cseqs_2.fq | grep -v "^--" | sed -e 's/kraken:taxid|2697049//g' > $3/cseqs_2.virus2.fq
singularity exec /usr/local/biotools/m/megahit\:1.2.9--h8b12597_0 megahit -m 0.5 -t 1 --k-max 101 -1 $3/cseqs_1.virus2.fq -2 $3/cseqs_2.virus2.fq -o $3/Assemble.MEGAHIT
singularity exec /usr/local/biotools/m/minimap2\:2.17--hed695b0_3 minimap2 -ax map-pb $MINIMAP2REF  $3/Assemble.MEGAHIT/final.contigs.fa > $3/$DE0.final.contigs.fa.sam
singularity exec /usr/local/biotools/s/samtools\:1.11--h6270b1f_0 samtools view -Sbq 10 -F 0x04 $3/$DE0.final.contigs.fa.sam > $3/$DE0.final.contigs.fa.sam.mapped.bam
singularity exec /usr/local/biotools/s/samtools\:1.11--h6270b1f_0 samtools sort $3/$DE0.final.contigs.fa.sam.mapped.bam > $3/$DE0.final.contigs.fa.sam.mapped.bam.sort.bam
singularity exec /usr/local/biotools/s/samtools\:1.11--h6270b1f_0 samtools fasta -n -F 0x900 $3/$DE0.final.contigs.fa.sam.mapped.bam > $3/$DE0.final.contigs.cleaned.fa
singularity exec /usr/local/biotools/s/seqkit\:0.13.2--0 seqkit seq $3/$DE0.final.contigs.cleaned.fa -m 2000 > $3/$DE0.final.contigs.cleaned.2000.fa
source /lustre6/public/vrl/activate_pangolin.sh
pangolin $3/$DE0.final.contigs.cleaned.2000.fa --outfile $3/$DE0.final.contigs.cleaned.2000.fa.csv

rm -fr $3/Assemble.MEGAHIT
rm -f $3/$DE0 $3/$DE1 $3/$DE0.qf.fastq $3/$DE1.qf.fastq $3/cseqs_1.fq $3/cseqs_2.fq $3/cseqs_1.virus2.fq $3/cseqs_2.virus2.fq $3/$DE0.final.contigs.fa.sam $3/$DE0.final.contigs.fa.sam.mapped.bam $3/$DE0.final.contigs.fa.sam.mapped.bam.sort.bam $3/$DE0.final.contigs.cleaned.fa
} >> "$LOGFILE" 2>&1
