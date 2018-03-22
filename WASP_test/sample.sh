# environment vars

WASP=$HOME/WASP-master
DATA_DIR=/homes/hwheeler/Data/gEUVADIS
SAMTOOLS=.../anaconda2/bin/samtools
BOWTIE=.../anaconda2/bin/bowtie2
INDEX= indexed genome ?? TBD

#create needed files 
$WASP/snp2h5/snp2h5 --chrom $DATA_DIR/chromInfo.hg19.txt \ 
		    --format vcf \ > 
		    --snp_index $DATA_DIR/genotypes/snp_index.h5 \
		    --geno_prob $DATA_DIR/genotypes/geno_probs.h5 \
		    --snp_tab $DATA_DIR/genotypes/snp_tab.h5 \
		    --haplotype $DATA_DIR/genotypes/haps.h5 \
		    --samples $DATA_DIR/genotypes/YRI_samples.txt \
		    $DATA_DIR/genotypes/chr*.hg19.impute2.gz \
		    $DATA_DIR/genotypes/chr*.hg19.impute2_haps.gz 
#list of chromosomes for relevant genome assembly; chr name and chr length
#needs to contain genotype likelihoods for geno_prob output
# this is where VCF goes
# first, we need to un-map the reads to FASTQ
#iterate through each bam file and map to FASTQ

samtools bam2fq x.bam > x.fastq

# Map reads using bowtie2 (or another mapping tool of your choice)
bowtie2 -x $INDEX -1 $DATA_DIR/sim_pe_reads1.fastq.gz \
	-2 $DATA_DIR/sim_pe_reads2.fastq.gz \
    | samtools view -S -b -q 10 - > $DATA_DIR/sim_pe_reads.bam

# Pull out reads that need to be remapped to check for bias
# Use the -p option for paired-end reads.
python $WASP/mapping/find_intersecting_snps.py \
       --is_paired_end \
       --output_dir $DATA_DIR  \
       --snp_index $DATA_DIR/genotypes/snp_index.h5 \
       --snp_tab $DATA_DIR/genotypes/snp_tab.h5 \
       --haplotype $DATA_DIR/genotypes/haps.h5 \
       --samples $DATA_DIR/H3K27ac/samples.txt \
       $DATA_DIR/sim_pe_reads.bam <bam file to test

#remap the reads 

bowtie2 -x bowtie2_index/hg37 \
               -1 find_intersecting_snps/${SAMPLE_NAME}_1.remap.fq.gz \
               -2 find_intersecting_snps/${SAMPLE_NAME}_2.remap.fq.gz \
           | samtools view -b -q 10 - > map2/${SAMPLE_NAME}.bam
     samtools sort -o map2/${SAMPLE_NAME}.sort.bam map2/${SAMPLE_NAME}.bam
     samtools index map2/${SAMPLE_NAME}.sort.bam

python mapping/filter_remapped_reads.py \
       find_intersection_snps/${SAMPLE_NAME}.to.remap.bam \
       map2/${SAMPLE_NAME}.sort.bam \
       filter_remapped_reads/${SAMPLE_NAME}.keep.bam

samtools merge merge/${SAMPLE_NAME}.keep.merge.bam \
              filter_remapped_reads/${SAMPLE_NAME}.keep.bam  \
              find_intersecting_snps/${SAMPLE_NAME}.keep.bam
samtools sort -o  merge/${SAMPLE_NAME}.keep.merge.sort.bam \
              merge/${SAMPLE_NAME}.keep.merge.bam 
samtools index ${SAMPLE_NAME}.keep.merged.sort.bam

# for single end reads:
python rmdup.py <sorted.input.bam> <output.bam>
# for paired-end reads:
python rmdup_pe.py <sorted.input.bam> <output.bam>
