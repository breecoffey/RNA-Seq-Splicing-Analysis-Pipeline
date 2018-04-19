import argparse
import gzip
import re
parser = argparse.ArgumentParser(description='Input & Output Files') #create the argument parser

parser.add_argument('VCF', help='The VCF file to open') #variable for VCF file
args = parser.parse_args() #parse the arguments

#geno = "SNPGenotypes_" + args.VCF
#snpsloc = "SNPLoc_" + args.VCF

filtered = [] #array to store filtered snp info
loc_output = [] #array for snp chrom location output file

with gzip.open(args.VCF) as file: #open the vcf file
    for line in file:
        if line.startswith(b'##'): #strip the meta-information
            continue
        if line.startswith(b'#'): #store the header
            header = line
	    continue
        words = line.strip('\n').split('\t') #split row by tab 
	chrom_num = words[0] #grab chromosome number
	chrom_loc = words[1] #grab chromosome location
        snp_id = words[2] #grab snp id
	#loc_output.append(str(snp_id) + '\t' + "chr"+str(chrom_num) + '\t' + str(chrom_loc)) #append together for the location output file
        
	values = words[7].split(';') #grab the 7th column with GT info for each sample
	af_index = 2 #set initial allele freq to index 2
	
        if(str(values[2][0:3]) == 'AF='): #check first 3 indicies for AF info, because some snps are missing first 2 values
            af_index = 2
        if(str(values[1][0:3]) == 'AF='):
            af_index = 1
        if(str(values[0][0:3]) == 'AF='):
            af_index = 0
	

        if (float(values[af_index][3:]) >= 0.01): #check if AF is above 0.01 frequency
            unfiltered_geno = words[9:] #grab unfiltered genotype info
	    genotypes = [] #create array for all genotype values to be stored
            #unfiltered_geno = unfiltered_geno[2:]

            for i in unfiltered_geno:
                j = i.split(':') #split info by colon
                
		#append 2, 1, or 0 based on corresponding genotype
                if j[0] == '1/1' or j[0] == '1|1': 
                    genotypes.append('2')
                if j[0] == '1/0' or j[0] == '0/1' or j[0] == '0|1' or j[0] == '1|0':
                    genotypes.append('1')
                if j[0] == '0/0' or j[0] == '0|0':
                    genotypes.append('0')
                else:
                    continue
		
	    filt = str(snp_id) #convert snpid to string
	    if genotypes == []: #if no values, go to next snp
		continue
            for k in genotypes:
                filt += '\t' + str(k)
            filtered.append(filt) #append filtered GT values by tab delimited
	    loc_output.append(str(snp_id) + '\t' + "chr"+str(chrom_num) + '\t' + str(chrom_loc))
	#write to output file

geno = "SNPGenotypes_" + chrom_num
snpsloc = "SNPLoc_" + chrom_num	

with gzip.open(geno, 'w') as output_file:
    samples = header.split('\t') #sample IDs
    output_file.write('id') 
    samples = samples[9:] #remove first columns from header
    for name in samples:
	output_file.write('\t'+str(name))

    for i in filtered:
        output_file.write(str(i) + '\n') #write out filtered genotype info
with gzip.open(snpsloc, 'w') as output_file: 
    output_file.write("snp\tchr\tpos" + '\n') #concat info for chrom position 
    for snp in loc_output:
	output_file.write(snp + '\n')
