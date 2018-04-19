# RNA Seq Splicing Analysis Pipeline

## Overview 
This splicing analysis pipeline is a novel compilation of computational biology tools that quantifies RNA splicing and performs sQTL mapping.

## Software Requirements
* Linux
* Python 3.x
  * The pandas module should also be installed.
* R

### Programs which should be in your PATH
* [LeafCutter](https://github.com/davidaknowles/leafcutter)
* [Matrix eQTL](http://www.bios.unc.edu/research/genomic_software/Matrix_eQTL/)

## Scripts
* pipelineparser.py
  * Extracts the genotype values from a VCF files to a new file in the format necessary for Matrix eQTL. It also creates a table of information regarding the chromosomal location for each SNP.
* leaf-command
  * Calls LeafCutter to generate gene expression and gene location information from .bam files in the form of qqnorm outputs. 
* qqnormparser.py
  * Separates the qqnorm files into gene location and gene expression files necessary for input to Matrix eQTL.
* file_reorder.py 
  * Reorders the samples within the Genotype file to match the output from LeafCutter's gene expression files.
* matrix_eQTL_parse.R
  * Tests for association between SNPs and the introns to find which are associated with splicing
* AntHill
  * Runs all scripts in correct order and outputs intron excision ratios and sQTLs
  
