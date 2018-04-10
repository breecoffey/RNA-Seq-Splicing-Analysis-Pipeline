import argparse
import gzip
import re
parser = argparse.ArgumentParser(description='Input & Output Files') #create the argument parser

parser.add_argument('VCF', help='The VCF file to open') #variable for VCF file
args = parser.parse_args() #parse the arguments

geno = "SNPGenotypes_" + args.VCF
snpsloc = "SNPLoc_" + args.VCF

filtered = []
loc_output = []
with gzip.open(args.VCF) as file: #open the vcf file
    for line in file:
        if line.startswith(b'##'): #strip the meta-information
            continue
        if line.startswith(b'#'):
            header = line
	    continue
        words = line.strip('\n').split('\t')
	chrom_num = words[0]
	chrom_loc = words[1]
        snp_id = words[2]
	loc_output.append(str(snp_id) + '\t' + "chr"+str(chrom_num) + '\t' + str(chrom_loc))
        
	values = words[7].split(';')
	af_index = 2
	
        if(str(values[2][0:3]) == 'AF='):
            af_index = 2
        if(str(values[1][0:3]) == 'AF='):
            af_index = 1
        if(str(values[0][0:3]) == 'AF='):
            af_index = 0
	

        if (float(values[af_index][3:]) >= 0.01):
            unfiltered_geno = words[9:]
	    genotypes = []
            #unfiltered_geno = unfiltered_geno[2:]

            for i in unfiltered_geno:
                j = i.split(':')
                #print(j[0])
                if j[0] == '1/1' or j[0] == '1|1':
                    genotypes.append('2')
                if j[0] == '1/0' or j[0] == '0/1' or j[0] == '0|1' or j[0] == '1|0':
                    genotypes.append('1')
                if j[0] == '0/0' or j[0] == '0|0':
                    genotypes.append('0')
                else:
                    continue
	    filt = str(snp_id)
	    if genotypes == []:
		continue
            for k in genotypes:
                filt += '\t' + str(k)
            filtered.append(filt)

with gzip.open(geno, 'w') as output_file:
    samples = header.split('\t')
    output_file.write('id')
    samples = samples[9:]
    for name in samples:
	output_file.write('\t'+str(name))

    for i in filtered:
        output_file.write(str(i) + '\n')
with gzip.open(snpsloc, 'w') as output_file:
    output_file.write("snp\tchr\tpos" + '\n')
    for snp in loc_output:
	output_file.write(snp + '\n')
