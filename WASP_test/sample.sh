# environment vars

#WASP=$HOME/WASP-master
#DATA=/homes/hwheeler/Data/gEUVADIS_RNASeq
#DATA_DIR=/homes/bcoffey2/WASP-master
#SAMTOOLS=.../anaconda2/bin/samtools
#BOWTIE=.../anaconda2/bin/bowtie2
#INDEX= indexed genome ?? TBD

snp2h5 --chrom WASP-master/chromInfo.txt --format vcf --snp_index snp_index.h5 --snp_tab snp_tab.h5 --geno_prob geno_probs.h5 --haplotype haps.h5 /homes/hwheeler/Data/gEUVADIS_RNASeq/GEUVADIS.chr1.PH1PH2_465.IMPFRQFILT_BIALLELIC_PH.annotv2.genotypes.vcf.gz

# Map reads using bowtie2
bowtie2 -x index_genome/hg19 -1 /homes/hwheeler/Data/gEUVADIS_RNASeq/ERR188030_1.fastq.gz -2 /homes/hwheeler/Data/gEUVADIS_RNASeq/ERR188030_2.fastq.gz | samtools view -S -b -q 10 - > /homes/bcoffey2/ERR188030.bam

# Pull out reads that need to be remapped to check for bias
# Use the -p option for paired-end reads.
python /homes/hwheeler/WASP/mapping/find_intersecting_snps.py --is_paired_end --output_dir /homes/bcoffey2 --snp_index snp_index.h5 --haplotype haps.h5 --snp_tab snp_tab.h5 ERR188030.bam

#remap the reads 

bowtie2 -x index_genome/hg19 -1 find_intersecting_snps/ERR188030_1.remap.fq.gz -2 find_intersecting_snps/ERR188030_2.remap.fq.gz | samtools view -b -q 10 - > map2/ERR188030.bam

samtools sort -o map2/ERR188030.sort.bam map2/${SAMPLE_NAME}.bam
samtools index map2/ERR188030.sort.bam

python mapping/filter_remapped_reads.py \
       find_intersection_snps/ERR188030.to.remap.bam \
       map2/ERR188030.sort.bam \
       filter_remapped_reads/ERR188030.keep.bam

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
