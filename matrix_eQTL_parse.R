#!/usr/bin/env Rscript


suppressPackageStartupMessages(library("argparse"))

pathwd<-sub("/matrix_eQTL_prac.R"
setwd(pathwd)

#create parse object
parser<-ArgumentParser()


#specify options
parser$add_argument("s", "SNP_Geno", action="storetrue", default=TRUE, 
	help="Please enter the name of the SNP file")
parser$add_argument("l", "SNP_Loc", action="storetrue", default=TRUE,
	help="Please enter the name of the SNP location file")
parser$add_argument("e", "Gene_Exp", action="storetrue", default=TRUE,
	help="Please enter the name of the Gene expression file")
parser$add_arguemnt("g", "Gene_Loc", action="storetrue", default=TRUE,
	help="Please enter the name of the Gene location file")


#get command line options with help options available
#if opt not on command line, then set to default

#parse args
args<-parser$parse_args()

