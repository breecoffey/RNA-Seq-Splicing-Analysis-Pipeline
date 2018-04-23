#argument 1 is always SNP genotype data
#argument 2 is always SNP location
#argument 3 is always Gene expression data (in this case intron excision ratios)
#argument 4 is always Gene location (intron start and stop)
arguments <- commandArgs(trailingOnly = T)
# source("Matrix_eQTL_R/Matrix_eQTL_engine.r");
library(MatrixEQTL)

## Location of the package with the data files.
base.dir = setwd ("/homes/" );

#for when other things start working
#setBaseDir <- function()
#{ 
#  n <- readline(prompt="Please enter the path to your base directory")
#}

#base.dir = setwd (n)
if (nchar(arguments[4]) == 18 ){
  CHRnum <- substr(arguments[4], 15, 18)
} else if (nchar(arguments[4] == 19)) {
  CHRnum <- substr(arguments[4], 15, 19)
}
## Settings
# Linear model to use, modelANOVA, modelLINEAR, or modelLINEAR_CROSS
useModel = modelLINEAR; # modelANOVA, modelLINEAR, or modelLINEAR_CROSS

# Genotype file name
SNP_file_name = arguments[1];
snps_location_file_name = arguments[2];

# Gene expression file name
expression_file_name = arguments[3];
gene_location_file_name = arguments[4];

# Covariates file name
# Set to character() for no covariates
covariates_file_name = character();

# Output file name
output_file_name_cis = tempfile();
output_file_name_tra = tempfile();

# Only associations significant at this level will be saved
pvOutputThreshold_cis = 2e-2;
pvOutputThreshold_tra = 1e-2;

# Error covariance matrix
# Set to numeric() for identity.
errorCovariance = numeric();
# errorCovariance = read.table("Sample_Data/errorCovariance.txt");

# Distance for local gene-SNP pairs
cisDist = 1e6;

## Load genotype data
snps = SlicedData$new();
snps$fileDelimiter = "\t"; # the TAB character
snps$fileOmitCharacters = "NA"; # denote missing values;
snps$fileSkipRows = 1; # one row of column labels
snps$fileSkipColumns = 1; # one column of row labels
snps$fileSliceSize = 2000; # read file in slices of 2,000 rows
snps$LoadFile(SNP_file_name);

## Load gene expression data
gene = SlicedData$new();
gene$fileDelimiter = "\t"; # the TAB character
gene$fileOmitCharacters = "NA"; # denote missing values;
gene$fileSkipRows = 1; # one row of column labels
gene$fileSkipColumns = 1; # one column of row labels
gene$fileSliceSize = 2000; # read file in slices of 2,000 rows
gene$LoadFile(expression_file_name);

## Load covariates
cvrt = SlicedData$new();
cvrt$fileDelimiter = "\t"; # the TAB character
cvrt$fileOmitCharacters = "NA"; # denote missing values;
cvrt$fileSkipRows = 1; # one row of column labels
cvrt$fileSkipColumns = 1; # one column of row labels
if(length(covariates_file_name)>0) {
  cvrt$LoadFile(covariates_file_name);
}

## Run the analysis
snpspos = read.table(snps_location_file_name, header = TRUE, stringsAsFactors = FALSE);
genepos = read.csv(gene_location_file_name, header = TRUE, sep='', stringsAsFactors = FALSE);
me = Matrix_eQTL_main(
  snps = snps,
  gene = gene,
  cvrt = cvrt,
  output_file_name = output_file_name_tra,
  pvOutputThreshold = pvOutputThreshold_tra,
  useModel = useModel,
  errorCovariance = errorCovariance,
  verbose = TRUE,
  output_file_name.cis = output_file_name_cis,
  pvOutputThreshold.cis = pvOutputThreshold_cis,
  snpspos = snpspos,
  genepos = genepos,
  cisDist = cisDist,
  pvalue.hist = TRUE,
  min.pv.by.genesnp = FALSE,
  noFDRsaveMemory = FALSE);
unlink(output_file_name_tra);
unlink(output_file_name_cis);
library(data.table)

## Results:
CisOutput<- paste("./cis_eQTLs_", CHRnum, ".txt", sep = "")
cat('Analysis done in: ', me$time.in.sec, ' seconds', '\n');
cat('Detected local eQTLs:', '\n');
fwrite(me$cis$eqtls, CisOutput, sep = '\t')

TransOutput <- paste("./trans_eQTLs_", CHRnum, ".txt", sep = "") #must hardcode output path for this to work
cat('Analysis done in: ', me$time.in.sec, ' seconds', '\n');
cat('Detected distant eQTLs:', '\n');
fwrite(me$trans$eqtls, TransOutput, sep = '\t')

## Malske the histogram of local and distant p-values
PlotOutput = paste("./Cis_trans_hist_", CHRnum, ".pdf", sep = "") #must hardcode path here as well
pdf(PlotOutput)
plot(me)
dev.off()
