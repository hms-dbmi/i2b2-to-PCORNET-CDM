##Microarray data QC and normalization##
# see http://barcwiki.wi.mit.edu/wiki/SOPs/normalize_ma
#options("BioC_mirror" = "http://www.bioconductor.org")
#source("http://bioconductor.org/biocLite.R")
#biocLite("simpleaffy",lib="/home/mtm22/R/library")
#biocLite("arrayQualityMetrics",lib="/home/mtm22/R/library") # for all metrics!
#biocLite("oligo",lib="~/R/library")
#biocLite("pd.hugene.1.0.st.v1",lib="/home/mtm22/R/library")

library(simpleaffy, lib="/home/mtm22/R/library");
library(arrayQualityMetrics, lib="/home/mtm22/R/library");
library(oligo, lib="/home/mtm22/R/library");
library(pd.hugene.1.0.st.v1, lib="/home/mtm22/R/library");

geneCELs =list.celfiles(full.names = TRUE)
SSC_GeneST1 = read.celfiles(geneCELs)

sampleInfoGeneST <- read.table("sampleInfo4R_GeneST1_619arrays.txt", sep="\t");
sampleInfoGeneST <- sampleInfoGeneST[order(sampleInfoGeneST$V4),]

#e.g.
#11128.p1       ASD     male    HAR 1164.01.072208.CEL
#11404.p1       ASD     male    HAR 1165-01.120408.CEL
pData(SSC_GeneST1)$individual = sampleInfoGeneST[,1]
pData(SSC_GeneST1)$condition = sampleInfoGeneST[,2]
pData(SSC_GeneST1)$gender =sampleInfoGeneST[,3]

##pre-normalization QC
arrayQualityMetrics(expressionset = SSC_GeneST1, outdir = "preNormalization_QC_report_GeneST1_619arrays", force = TRUE, do.logtransform = TRUE, intgroup="condition");

## RMA normalization
SSC_GeneST1.oligoGeneCore = rma(SSC_GeneST1, target = "core")

## results reporting
write.exprs(SSC_GeneST1.oligoGeneCore,file="GeneST1_RMAmatrix_619arrays.txt",quote=F, sep="\t")

##post-normalization QC
arrayQualityMetrics(SSC_GeneST1.oligoGeneCore, outdir="postNormalization_QC_report_GeneST1_619arrays", force=TRUE)
