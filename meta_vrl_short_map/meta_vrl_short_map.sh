#!/bin/sh
#$ -S /bin/sh
#$ -cwd
# USAGE: this_shell_script input_R1 input_R2 output_dir
# input_R1=$1
# input_R2=$2
# output_dir=$3
BWAREF=/home/hoge/META_VRL/NC_045512.2.fasta
LOGFILE="$3/meta_vrl_short_map.log"
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
singularity exec /usr/local/biotools/b/bwa\:0.7.17--pl5.22.0_2 bwa index -a bwtsw $BWAREF
singularity exec /usr/local/biotools/b/bwa\:0.7.17--pl5.22.0_2 bwa mem $BWAREF $3/$DE0.qf.fastq $3/$DE1.qf.fastq > $3/$DE0.qf.fastq.sam
singularity exec /usr/local/biotools/s/samtools\:1.11--h6270b1f_0 samtools view -Sbq 10 -F 0x04 $3/$DE0.qf.fastq.sam > $3/$DE0.qf.fastq.sam.mapped.bam
singularity exec /usr/local/biotools/s/samtools\:1.11--h6270b1f_0 samtools sort $3/$DE0.qf.fastq.sam.mapped.bam > $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam
export MALLOC_ARENA_MAX=2
singularity exec /usr/local/biotools/p/picard\:2.25.0--0 picard MarkDuplicates -I $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam -O $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam -M $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.metrics.txt -REMOVE_DUPLICATES true
singularity exec /usr/local/biotools/l/lofreq\:2.1.5--py38h1bd3507_3 lofreq call $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam -f $BWAREF -o $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.vcf -C 10 -q 20 -Q 20 -a 0.001
singularity exec /usr/local/biotools/l/lofreq\:2.1.5--py38h1bd3507_3 lofreq filter -i $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.vcf -a 0.5 -o $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.0.5.vcf
mkdir $3/tmp $3/data
cp /etc/resolv.conf $3/tmp
singularity exec -B $3/tmp:/tmp -B $3/data:/usr/local/share/snpeff-5.0-0/data /usr/local/biotools/s/snpeff\:5.0--0 snpEff -no-downstream -no-upstream -no-utr -classic -formatEff NC_045512.2 $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.0.5.vcf > $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.0.5.anno.vcf
singularity exec /usr/local/biotools/b/bcftools\:1.10.2--hd2cd319_0 bcftools view $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.0.5.anno.vcf -Oz -o $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.0.5.anno.vcf.gz
singularity exec /usr/local/biotools/b/bcftools\:1.10.2--hd2cd319_0 bcftools index $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.0.5.anno.vcf.gz
singularity exec /usr/local/biotools/b/bcftools\:1.10.2--hd2cd319_0 bcftools consensus -f $BWAREF $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.0.5.anno.vcf.gz -o $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.0.5.anno.vcf.fasta
source /lustre6/public/vrl/activate_pangolin.sh
pangolin $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.0.5.anno.vcf.fasta --outfile $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.0.5.anno.vcf.fasta.csv

# make consensus FASTA for mapped region
singularity exec --no-mount tmp /usr/local/biotools/s/samtools\:1.11--h6270b1f_0 samtools index $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam
singularity exec --no-mount tmp /usr/local/biotools/n/ngsutils\:0.5.9--py27h516909a_2 bamutils expressed -ns $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam > $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.mapped.bed
singularity exec --no-mount tmp /usr/local/biotools/b/bedtools\:2.30.0--hc088bd4_0 bedtools getfasta -fi $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.0.5.anno.vcf.fasta -bed $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.mapped.bed > $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.0.5.anno.vcf.mapped.fasta

# make consensus FASTA with unmapped region masked
singularity exec --no-mount tmp /usr/local/biotools/p/pyfaidx\:0.5.9.5--pyh3252c3a_0 faidx --transform chromsizes $BWAREF > $3/reference.size
singularity exec --no-mount tmp /usr/local/biotools/b/bedtools\:2.30.0--hc088bd4_0 bedtools complement -i $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.mapped.bed -g $3/reference.size > $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.unmapped.bed
singularity exec --no-mount tmp /usr/local/biotools/b/bedtools\:2.30.0--hc088bd4_0 bedtools maskfasta -fi $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.0.5.anno.vcf.fasta -bed $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.unmapped.bed -fo $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.0.5.anno.vcf.masked.fasta

# calculate depth of coverage
singularity exec --no-mount tmp /usr/local/biotools/p/pyfaidx\:0.5.9.5--pyh3252c3a_0 faidx --transform bed $BWAREF > $3/reference.bed
singularity exec --no-mount tmp /usr/local/biotools/b/bedtools\:2.30.0--hc088bd4_0 coverageBed -d -a $3/reference.bed -b $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam | awk '$5>0{i++;sum += $5}END{print i"\t"sum"\t"sum/i}' > $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.depth_cov.txt
# calculate breadth of coverage
singularity exec --no-mount tmp /usr/local/biotools/b/bedtools\:2.30.0--hc088bd4_0 coverageBed -a $3/reference.bed -b $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam > $3/$DE0.qf.fastq.sam.mapped.bam.sort.bam.remdup.bam.breadth_cov.txt

} >> "$LOGFILE" 2>&1
