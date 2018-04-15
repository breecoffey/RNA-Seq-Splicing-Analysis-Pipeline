import gzip
import argparse as ap

parser = ap.ArgumentParser()
parser.add_argument('qqnorminput', help = 'file path of the target qqnorm file to be parsed')

args = parser.parse_args()

gene_loc = []
gene_exp = []
with open(args.qqnorminput, 'r') as qq:
	columns = []
	for line in qq:
		columns = line.split('\t')
		loc_line = '\t'.join([columns[3],'chr'+columns[0],columns[1],columns[2]])
		gene_loc.append(loc_line)
		exp_line = '\t'.join(columns[3:])
		gene_exp.append(exp_line)			

CHR = args.qqnorminput[args.qqnorminput.rfind('_'):]
            
location_name = 'Gene_location' + CHR
expression_name = 'Gene_expression' + CHR
with open(location_name, 'w') as output_file:
    #write out
    for line in gene_loc:
        output_file.write((line + '\n').encode('utf-8'))

with open(expression_name, 'w') as output_file:
    #write out
    for line in gene_exp:
        output_file.write((line).encode('utf-8'))

