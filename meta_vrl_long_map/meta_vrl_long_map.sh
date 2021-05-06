#!/bin/sh
#$ -S /bin/sh
#$ -cwd
# USAGE: this_shell_script inputfastq output_dir
# inputfastq=$1
# output_dir=$2
MINIMAPREF=/home/hoge/NC_045512.2.fasta
if [ ! -f $ENVFILE ]; then
  echo "No $ENVFILE file exist."
  exit 1
fi
export $(cat $ENVFILE | xargs)

LOGFILE="$2/meta_vrl.lmap.log"
if [ $# -ne 2 ]; then
  echo "you specified $# arguments." 1>&2
  echo "But this program can only use 2 arguments." 1>&2
  exit 1
fi
if [ ! -f $1 ]; then
        echo "No $1 file exist." 1>&2
        exit 1
fi
if [ ! -d $2 ]; then
        echo "$2 directory does not exist. please mkdir" 1>&2
        exit 1
fi
touch $LOGFILE
 if [ ! -f $LOGFILE ]; then
  echo "Error cannot create $LOGFILE."
  exit 1;
fi
{
DE0=`basename "$1"`
cp "$1" "$2/$DE0"
# need to specify Nanopore adapter in -g and -a, respectively. Ns are index sequence, so wildcard (N) is appropriate. Length of index is depend on your protocol.
singularity exec /usr/local/biotools/c/cutadapt\:3.2--py38h0213d0e_0 cutadapt -g ^ATTGTACTTCGTTCAGTTACGTATTGCTAANNNNNNNNNNNNNNNNNNNNNNNNNNNNNNCAGCACCT -o $2/$DE0.trim1.fastq -O 30 -e 0.3 -m 100 -M 1000 -q 1 --discard-untrimmed $2/$DE0
singularity exec /usr/local/biotools/c/cutadapt\:3.2--py38h0213d0e_0 cutadapt -a AGGTGCTGNNNNNNNNNNNNNNNNNNNNNNNNTTAACCTTAGCAATACGTAACTTA -o $2/$DE0.trim2.fastq -O 20 -e 0.3 -m 100 -q 1 --discard-untrimmed $2/$DE0.trim1.fastq
# cut ARTIC primer by 33 bases. Multi Cs are dummy sequence.
singularity exec /usr/local/biotools/c/cutadapt\:3.2--py38h0213d0e_0 cutadapt -g ^CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC -o $2/$DE0.trim3.fastq -O 50 -e 0.1 -m 100 -q 1 -u 33 $2/$DE0.trim2.fastq
singularity exec /usr/local/biotools/c/cutadapt\:3.2--py38h0213d0e_0 cutadapt -g ^CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC -o $2/$DE0.trim4.fastq -O 50 -e 0.1 -m 100 -q 1 -u -33 $2/$DE0.trim3.fastq
singularity exec /usr/local/biotools/m/minimap2\:2.17--hed695b0_3 minimap2 -ax map-ont $MINIMAPREF $2/$DE0.trim4.fastq -o $2/$DE0.sam
singularity exec /usr/local/biotools/s/samtools\:1.11--h6270b1f_0 samtools view -Sbq 10 -F 0x04 $2/$DE0.sam > $2/$DE0.sam.mapped.bam
singularity exec /usr/local/biotools/s/samtools\:1.11--h6270b1f_0 samtools sort $2/$DE0.sam.mapped.bam > $2/$DE0.sam.mapped.bam.sort.bam
singularity exec /usr/local/biotools/s/samtools\:1.11--h6270b1f_0 samtools index $2/$DE0.sam.mapped.bam.sort.bam
# need to activate conda medaka environment
source ~/activate_conda.sh
#eval "$(/home/hoge/miniconda3/bin/conda shell.bash hook)"
conda activate medaka
medaka_variant -s r941_min_high_g360 -i $2/$DE0.sam.mapped.bam.sort.bam -f $MINIMAPREF -o $2/$DE0.medaka -t 1 -m r941_min_high_g360
medaka tools annotate $2/$DE0.medaka/round_1.vcf $MINIMAPREF $2/$DE0.sam.mapped.bam.sort.bam $2/$DE0.sam.mapped.bam.sort.bam.vcf
singularity exec /usr/local/biotools/l/lofreq\:2.1.5--py38h1bd3507_3 lofreq filter -i $2/$DE0.sam.mapped.bam.sort.bam.vcf -v 30 -o $2/$DE0.sam.mapped.bam.sort.bam.filter.vcf
mkdir $2/tmp $2/data
cp /etc/resolv.conf $2/tmp
singularity exec -B $2/tmp:/tmp -B $2/data:/usr/local/share/snpeff-5.0-0/data /usr/local/biotools/s/snpeff\:5.0--0 snpEff -no-downstream -no-upstream -no-utr -classic -formatEff NC_045512.2 $2/$DE0.sam.mapped.bam.sort.bam.filter.vcf > $2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf
singularity exec /usr/local/biotools/b/bcftools\:1.10.2--hd2cd319_0 bcftools view $2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf -Oz -o $2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.gz
singularity exec /usr/local/biotools/b/bcftools\:1.10.2--hd2cd319_0 bcftools index $2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.gz
singularity exec /usr/local/biotools/b/bcftools\:1.10.2--hd2cd319_0 bcftools consensus -f $MINIMAPREF $2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.gz -o $2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.fasta
# need to activate conda pangolin environment
source /lustre6/public/vrl/activate_pangolin.sh
pangolin $2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.fasta --outfile $2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.fasta.csv

# calculate depth/breadth of coverage 
# Format: total_length, mapped_length, sum_depth, mean_depth1(sum_depth/total_length), mean_depth2(sum_depth/mapped_length) coverage(mapped_length/total_length)
singularity exec --no-mount tmp /usr/local/biotools/p/pyfaidx\:0.5.9.5--pyh3252c3a_0 faidx --transform bed $MINIMAPREF > $2/reference.size.bed
singularity exec --no-mount tmp /usr/local/biotools/b/bedtools\:2.30.0--hc088bd4_0 coverageBed -d -a $2/reference.size.bed -b $2/$DE0.sam.mapped.bam.sort.bam | awk '$5>0{mapped++;sum += $5}END{print NR"\t"mapped"\t"sum"\t"sum/NR"\t"sum/mapped"\t"mapped/NR}' > $2/$DE0.sam.mapped.bam.sort.bam.coverage.txt
CONSENSUS=$2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.fasta
DIR_MAP2CONSENSUS=$2/map2consensus
mkdir -p $DIR_MAP2CONSENSUS
singularity exec /usr/local/biotools/m/minimap2\:2.17--hed695b0_3 minimap2 -ax map-ont $CONSENSUS $2/$DE0.trim4.fastq -o $DIR_MAP2CONSENSUS/$DE0.sam
singularity exec /usr/local/biotools/s/samtools\:1.11--h6270b1f_0 samtools view -Sbq 10 -F 0x04 $DIR_MAP2CONSENSUS/$DE0.sam > $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam
singularity exec /usr/local/biotools/s/samtools\:1.11--h6270b1f_0 samtools sort $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam > $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam
singularity exec /usr/local/biotools/s/samtools\:1.11--h6270b1f_0 samtools index $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam
# make consensus FASTA for mapped region
singularity exec --no-mount tmp /usr/local/biotools/n/ngsutils\:0.5.9--py27h516909a_2 bamutils expressed -ns $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam > $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam.bed
singularity exec --no-mount tmp /usr/local/biotools/b/bedtools\:2.30.0--hc088bd4_0 bedtools getfasta -fi $CONSENSUS -bed $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam.bed > $2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.mapped.fasta
# make consensus FASTA with unmapped region masked
singularity exec --no-mount tmp /usr/local/biotools/p/pyfaidx\:0.5.9.5--pyh3252c3a_0 faidx --transform chromsizes $CONSENSUS > $DIR_MAP2CONSENSUS/consensus.size
singularity exec --no-mount tmp /usr/local/biotools/b/bedtools\:2.30.0--hc088bd4_0 bedtools complement -i $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam.bed -g $DIR_MAP2CONSENSUS/consensus.size > $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam.bed.unmapped.bed
singularity exec --no-mount tmp /usr/local/biotools/b/bedtools\:2.30.0--hc088bd4_0 bedtools maskfasta -fi $CONSENSUS -bed $DIR_MAP2CONSENSUS/$DE0.sam.mapped.bam.sort.bam.bed.unmapped.bed -fo $2/tmp.masked.fasta
singularity exec --no-mount tmp /usr/local/biotools/s/seqkit\:0.15.0--0 seqkit replace -is -p "^n+|n+$" -r "" $2/tmp.masked.fasta > $2/$DE0.sam.mapped.bam.sort.bam.filter.anno.vcf.masked.fasta
rm -f $2/tmp.masked.fasta
} >> "$LOGFILE" 2>&1
