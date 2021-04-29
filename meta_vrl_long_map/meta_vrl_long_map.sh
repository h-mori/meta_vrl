#!/bin/sh
#$ -S /bin/sh
#$ -cwd
# USAGE: this_shell_script input_R1 input_R2 output_dir
# input_R1=$1
# input_R2=$2
# output_dir=$3
#BWAREF=/home/hoge/META_VRL/NC_045512.2.fasta
if [ ! -f $ENVFILE ]; then
  echo "No $ENVFILE file exist."
  exit 1
fi
export $(cat $ENVFILE | xargs)

LOGFILE="$3/meta_vrl.lmap.log"
if [ $# -ne 3 ]; then
  echo "you specified $# arguments." 1>&2
  echo "But this program can only use 3 arguments." 1>&2
  exit 1
fi
if [ ! -f $1 ]; then
	echo "No $1 file exist." 1>&2
	exit 1
fi
if [ ! -d $2 ]; then
	echo "$2 directory does not exist." 1>&2
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
cp -fr "$2" "$3/$DE1"
singularity exec /usr/local/biotools/n/nanopolish\:0.13.2--he3b7ca5_2 nanopolish index -d $3/$DE1 $3/$DE0
singularity exec /usr/local/biotools/m/minimap2\:2.17--hed695b0_3 minimap2 -ax map-ont $BWAREF $3/$DE0 -o $3/$DE0.sam
singularity exec /usr/local/biotools/s/samtools\:1.11--h6270b1f_0 samtools view -Sbq 10 -F 0x04 $3/$DE0.sam > $3/$DE0.sam.mapped.bam
singularity exec /usr/local/biotools/s/samtools\:1.11--h6270b1f_0 samtools sort $3/$DE0.sam.mapped.bam > $3/$DE0.sam.mapped.bam.sort.bam
singularity exec /usr/local/biotools/s/samtools\:1.11--h6270b1f_0 samtools index $3/$DE0.sam.mapped.bam.sort.bam
singularity exec /usr/local/biotools/n/nanopolish\:0.13.2--he3b7ca5_2 nanopolish variants --consensus -o $3/$DE0.sam.mapped.bam.sort.bam.vcf -r $3/$DE0 -b $3/$DE0.sam.mapped.bam.sort.bam -g $BWAREF
sed -e "s/TotalReads/DP/g" -e "s/SupportFraction/AF/g" $3/$DE0.sam.mapped.bam.sort.bam.vcf > $3/$DE0.sam.mapped.bam.sort.bam.2.vcf
singularity exec /usr/local/biotools/l/lofreq\:2.1.5--py38h1bd3507_3 lofreq filter -i $3/$DE0.sam.mapped.bam.sort.bam.2.vcf -a 0.5 -v 3 -o $3/$DE0.sam.mapped.bam.sort.bam.2.filter.vcf
mkdir $3/tmp $3/data
cp /etc/resolv.conf $3/tmp
singularity exec -B $3/tmp:/tmp -B $3/data:/usr/local/share/snpeff-5.0-0/data /usr/local/biotools/s/snpeff\:5.0--0 snpEff -no-downstream -no-upstream -no-utr -classic -formatEff NC_045512.2 $3/$DE0.sam.mapped.bam.sort.bam.2.filter.vcf > $3/$DE0.sam.mapped.bam.sort.bam.2.filter.anno.vcf
singularity exec /usr/local/biotools/b/bcftools\:1.10.2--hd2cd319_0 bcftools view $3/$DE0.sam.mapped.bam.sort.bam.2.filter.anno.vcf -Oz -o $3/$DE0.sam.mapped.bam.sort.bam.2.filter.anno.vcf.gz
singularity exec /usr/local/biotools/b/bcftools\:1.10.2--hd2cd319_0 bcftools index $3/$DE0.sam.mapped.bam.sort.bam.2.filter.anno.vcf.gz
singularity exec /usr/local/biotools/b/bcftools\:1.10.2--hd2cd319_0 bcftools consensus -f $BWAREF $3/$DE0.sam.mapped.bam.sort.bam.2.filter.anno.vcf.gz -o $3/$DE0.sam.mapped.bam.sort.bam.2.filter.anno.vcf.fasta
source /lustre6/public/vrl/activate_pangolin.sh
pangolin $3/$DE0.sam.mapped.bam.sort.bam.2.filter.anno.vcf.fasta --outfile $3/$DE0.sam.mapped.bam.sort.bam.2.filter.anno.vcf.fasta.csv

# make consensus FASTA for mapped region
singularity exec --no-mount tmp /usr/local/biotools/n/ngsutils\:0.5.9--py27h516909a_2 bamutils expressed -ns $3/$DE0.sam.mapped.bam.sort.bam > $3/$DE0.sam.mapped.bam.sort.bam.bed
singularity exec --no-mount tmp /usr/local/biotools/b/bedtools\:2.30.0--hc088bd4_0 bedtools getfasta -fi $3/$DE0.sam.mapped.bam.sort.bam.2.filter.anno.vcf.fasta -bed $3/$DE0.sam.mapped.bam.sort.bam.bed >$3/$DE0.sam.mapped.bam.sort.bam.2.filter.anno.vcf.mapped.fasta

# make consensus FASTA with unmapped region masked
singularity exec --no-mount tmp /usr/local/biotools/p/pyfaidx\:0.5.9.5--pyh3252c3a_0 faidx --transform chromsizes $BWAREF > $3/reference.size
singularity exec --no-mount tmp /usr/local/biotools/b/bedtools\:2.30.0--hc088bd4_0 bedtools complement -i $3/$DE0.sam.mapped.bam.sort.bam.bed -g $3/reference.size > $3/$DE0.sam.mapped.bam.sort.bam.bed.unmapped.bed
singularity exec --no-mount tmp /usr/local/biotools/b/bedtools\:2.30.0--hc088bd4_0 bedtools maskfasta -fi $3/$DE0.sam.mapped.bam.sort.bam.2.filter.anno.vcf.fasta -bed $3/$DE0.sam.mapped.bam.sort.bam.bed.unmapped.bed -fo $3/$DE0.sam.mapped.bam.sort.bam.2.filter.anno.vcf.fasta.masked.fasta

# calculate depth of coverage
singularity exec --no-mount tmp /usr/local/biotools/p/pyfaidx\:0.5.9.5--pyh3252c3a_0 faidx --transform bed $BWAREF > $3/reference.bed
singularity exec --no-mount tmp /usr/local/biotools/b/bedtools\:2.30.0--hc088bd4_0 coverageBed -d -a $3/reference.bed -b $3/$DE0.sam.mapped.bam.sort.bam | awk '$5>0{i++;sum += $5}END{print i"\t"sum"\t"sum/i}' >$3/$DE0.sam.mapped.bam.sort.bam.depth_cov.txt
# calculate breadth of coverage
singularity exec --no-mount tmp /usr/local/biotools/b/bedtools\:2.30.0--hc088bd4_0 coverageBed -a $3/reference.bed -b $3/$DE0.sam.mapped.bam.sort.bam > $3/$DE0.sam.mapped.bam.sort.bam.breadth_cov.txt

} >> "$LOGFILE" 2>&1
