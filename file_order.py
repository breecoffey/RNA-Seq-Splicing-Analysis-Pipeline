import pandas as pd

data = pd.read_csv('SNPGenotypes_test.vcf.gz', compression='gzip', sep= '\t', header=0)

with open('/homes/rschubert1/bamData/Gene_expression_chr1') as f:
    sample_names = f.readline()

sample_names = sample_names.split('\t')
trimmed_names = []

for i in range(1, len(sample_names)):
    trimmed_names.append(sample_names[i][0:7])

trimmed_names.insert(0, 'id')
print(trimmed_names)
data.filter(items=trimmed_names)

data = data[trimmed_names]

with open('filtered_output_genotype.gz', 'w') as out:
    data.to_csv(path_or_buf = out, sep='\t', compression = 'gzip')
print(data)
