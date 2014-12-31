##Microarray data QC and normalization##
# see http://barcwiki.wi.mit.edu/wiki/SOPs/normalize_ma

source("http://bioconductor.org/biocLite.R")
biocLite("simpleaffy",lib="/home/mtm22/R/library/")
biocLite("arrayQualityMetrics",lib="/home/mtm22/R/library/") # for all metrics!

library("simpleaffy", lib="/home/mtm22/R/library/");
library("arrayQualityMetrics", lib="/home/mtm22/R/library/");

SSC_U133p2 = ReadAffy(); #reads all the CEL files in your current directory
SSC_U133p2.gcRMA = justGCRMA() #normalizes by gcRMA
write.exprs(SSC_U133p2.gcRMA,file="all_U133p2_gcRMA_matrix.txt",quote=F, sep="\t") #reports result

#get factors for the QC report
sampleInfo <- read.table("sampleInfo4R_U133p2_207arrays.txt", sep="\t");
sampleInfo <- sampleInfo[order(sampleInfo$V4),]

pData(SSC_U133p2)$individual = sampleInfo[,1]
pData(SSC_U133p2)$condition = sampleInfo[,2]
pData(SSC_U133p2)$gender =sampleInfo[,3]

pData(SSC_U133p2.gcRMA)$individual = sampleInfo[,1]
pData(SSC_U133p2.gcRMA)$condition = sampleInfo[,2]
pData(SSC_U133p2.gcRMA)$gender =sampleInfo[,3]

##creates a dir with an HTML file including all possible QC metrics
arrayQualityMetrics(SSC_U133p2, outdir = "preNormalization_QC_report_all_U133p2_207arrays", force = TRUE, do.logtransform = TRUE, intgroup=c("condition","gender")); #pre-normalization

arrayQualityMetrics(SSC_U133p2.gcRMA, outdir = "postNormalization_QC_U133p2_all_gcRMA_207arrays", force = TRUE, intgroup=c("condition","gender")); #post-normalization
