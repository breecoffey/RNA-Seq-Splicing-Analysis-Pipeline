
'''
This script reorders the pipeline parser output to correpsond with leafcutter for Matrix eQTL
'''
import pandas as pd
import argparse 

parser = argparse.ArgumentParser(description='Input SNP Genotype')
parser.add_argument('SNPGeno', help='The VCF file to open') #variable for SNP genotype file
parser.add_argument('GeneExp', help='The gene expression file from leafcutter')
#parser.add_argument('outFile', help='name of the output file') 
args = parser.parse_args() #parse the arguments

data = pd.read_csv(args.SNPGeno, compression='gzip', sep= '\t', header=0) #read genotype file into DF

with open(args.GeneExp) as f:
    sample_names = f.readline() #grab header from Gene Exp file

sample_names = sample_names.split('\t') #split sample names by tab
trimmed_names = []

for i in range(1, len(sample_names)):
    trimmed_names.append(sample_names[i][0:7]) #grab first 7 chars (BAM FILE NAME, CHANGE IF YOUR FILE NAMES ARE DIFFEREND)

trimmed_names.insert(0, 'id') #add column to trimmed names for snp id

data.filter(items=trimmed_names) #filter out all samples not included in the GeneExp output

data = data[trimmed_names] #order the samples corresponding to the geneExp output

#this script needs to be in the same directory as the SNP Genotype file otherwise output name won't work. 
outfile = "Reordered" + args.SNPGeno
#write to outfile
with open(outfile, 'w') as out:
    data.to_csv(path_or_buf = out, sep='\t',index=False, compression = 'gzip')
