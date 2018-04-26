# RNA Seq Splicing Analysis Pipeline

## Overview 
This splicing analysis pipeline is a novel compilation of computational biology tools that quantifies RNA splicing by providing intron excision ratios and maps sQTLs by performing analysis of SNP statistical significance.

## Software Requirements
* __Linux__
* [Python 3.x](https://www.python.org/downloads/)
  * The [Pandas](https://pandas.pydata.org/) module also should be installed. 
* [R 3.3.3](https://cran.r-project.org/bin/macosx/)
* [LeafCutter](https://github.com/davidaknowles/leafcutter)
* [Matrix eQTL](http://www.bios.unc.edu/research/genomic_software/Matrix_eQTL/)

## Scripts
* `pipelineparser.py`
  * Extracts the genotype values from a VCF files to a new file in the format necessary for Matrix eQTL. It also creates a table of information regarding the chromosomal location for each SNP.
  * ```
       Input: chrX.vcf.gz 
       Output: SNPGenotypes_chrX, SNPLoc_chrX
    ```
* `leaf-command`
  * Calls LeafCutter to generate gene expression and gene location information from .bam files in the form of qqnorm outputs.
  * ```
       Input: /path/to/bamfiles/
       Output: sampleName.gz.qqnorm_chrX
    ```
* `qqnormparser.py`
  * Separates the qqnorm files into gene location and gene expression files necessary for input to Matrix eQTL.
  * ```
       Input: sampleName.gz.qqnorm_chrX
       Output: Gene_expression_chrX, Gene_location_chrX 
       ```
* `file_reorder.py `
  * Reorders the samples within the Genotype file to match the output from LeafCutter's gene expression files.
  * ```Input: SNPGenotypes_chrX, Gene_expression_chrX
       Output: ReorderedSNPGenotypes_chrX
    ```
* `matrix_eQTL_parse.R`
  * Tests for association between SNPs and the introns to find which are associated with splicing
  * ```
  Input: /path/to/test_data/ finalSNPGenotypes_chrX SNPLoc_chrX Gene_expression_chrX Gene_location_chrX
  Output: cis_eQTLs_X.txt, trans_eQTLs_X.txt, Cis_trans_hist_X.pdf
  ```
* `AntHill`
  * Runs all scripts in correct order for all 23 chromosomes and outputs intron excision ratios and maps sQTLs.
  
## Downloading the project
Open a terminal session and enter the following:
```
git clone https://github.com/breecoffey/RNA_Seq_Splicing-Analysis-Pipeline.git
```
## Input Files
### `.vcf.gz`,`.bam`
Make sure your files are in the same directory. You can do this by making a new directory like:
```
   mkdir anthill_files
   cd anthill_files
```
And keep all scripts and files together here.

## Example
To see a worked out example, head to the test_example directory and follow the worked out example guide there. 
