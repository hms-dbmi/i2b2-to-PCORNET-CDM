rm(list=ls())

setwd('/opt/etl/projects/AUTISM/SSC/Clinical/r_etl/')
r_scripts_path = 'R/'

append =T

library(data.table)
library(dplyr)

source(paste0(r_scripts_path,'getConfig.R'))
source(paste0(r_scripts_path,'conceptsUtilities.R'))
source(paste0(r_scripts_path,'columnsUtilities.R'))
source(paste0(r_scripts_path,'getNewIdentifiers.R'))
source(paste0(r_scripts_path,'JDBCConnect.R'))
source(paste0(r_scripts_path,'toLog.R'))

library(reshape2)

config <- getConfig('config_file')

# start from a base path one level up ------
basePath <- "\\DBMI\\Autism\\SSC_wigler_mutations\\"
# ---------------

# load patients ----------
load('temp/patients.RData')
# -----------

# load mutations ----------
mut <- read.delim('wigler_denovo_mutations_filtered.txt',sep='\t',header=T,stringsAsFactors=F)

# ----------

# keep only proband patients --------
probands <- patients[patients$ROLE == 'p1',]
# ----------

# create genes list ------
genes <- levels(as.factor(mut$effectGene))
# ---------


# create mutations dataframe with patient_num and mutations -------
mutations <- dcast(familyId ~effectGene , data = mut)
mutations <- merge(subset(probands,select=c('FAMILY','PATIENT_NUM')), mutations, by.x = 'FAMILY', by.y = 'familyId', all.x=T,stringsAsFactors=F)
mutations[is.na(mutations)] <- 0

mutations <- melt(mutations, c('PATIENT_NUM','FAMILY'),stringsAsFactors=F)
mutations$GENE <- as.character(paste(mutations$variable))
mutations$value <- ifelse(mutations$value == 0, 'no','yes')
# ------------

# create concepts -------------
concept_paths <- c(basePath,paste0(basePath,genes,'\\'),
                   paste0(basePath,c(paste0(genes,'\\yes\\'),paste0(genes,'\\no\\'))))
concept_levels <- c(2,rep(3,length(genes)),rep(4,(2*length(genes))))
visual_attributes <- c('FA',rep('FA',length(genes)),rep('LA',(2*length(genes))) )
concept_genes <- c('',genes,genes,genes)
concept_values <- c('SSC_wigler_mutations',genes,rep('yes',length(genes)),rep('no',length(genes)))
concept_parent <- gsub('[^\\]+[\\]$','',concept_paths)

concepts <- data.frame(CONCEPT_PATH = concept_paths,
                       CONCEPT_NAME= concept_genes,
                       CONCEPT_VALUE = concept_values,
                       PARENT_CONCEPT_PATH=concept_parent,
                       VISUAL_ATTRIBUTE = visual_attributes,
                       CONCEPT_LEVELS = concept_levels,
                       stringsAsFactors=F)
concepts <- concepts[order(concepts$CONCEPT_PATH),]
# ------------


# create concepts tables ---------
ConceptDimension <- data.frame(CONCEPT_CD = 0 ,
                              CONCEPT_PATH =concepts$CONCEPT_PATH,
                              NAME_CHAR = concepts$CONCEPT_VALUE,
                              CONCEPT_BLOB = '',
                              UPDATE_DATE = Sys.time(),
                              DOWNLOAD_DATE = Sys.time(),
                              IMPORT_DATE= Sys.time(),
                              SOURCESYSTEM_CD= config$STUDY_ID,
                              UPLOAD_ID= '',
                              TABLE_NAME= '', stringsAsFactors=F)


# 27464321 -> 27464329

i2b2 <- data.frame(C_HLEVEL = concepts$CONCEPT_LEVELS,
                               C_FULLNAME = concepts$CONCEPT_PATH,
                               C_NAME = concepts$CONCEPT_VALUE,
                               C_SYNONYM_CD = 'N',
                               C_VISUALATTRIBUTES = concepts$VISUAL_ATTRIBUTE,
                               C_TOTALNUM = '',
                               C_BASECODE = 0,
                               C_METADATAXML = '',
                               C_FACTTABLECOLUMN= 'CONCEPT_CD',
                               C_TABLENAME= 'CONCEPT_DIMENSION',
                               C_COLUMNNAME= 'CONCEPT_PATH',
                               C_COLUMNDATATYPE= 'T',
                               C_OPERATOR= 'LIKE',
                               C_DIMCODE= concepts$CONCEPT_PATH,
                               C_COMMENT= config$STUDY_ID,
                               C_TOOLTIP= concepts$CONCEPT_VALUE,
                               UPDATE_DATE= Sys.time(),
                               DOWNLOAD_DATE=Sys.time(),
                               IMPORT_DATE=Sys.time(),
                               SOURCESYSTEM_CD= config$STUDY_ID,
                               VALUETYPE_CD= '',
                               I2B2_ID= 0,
                               M_APPLIED_PATH= '',
                               M_EXCLUSION_CD= '',
                               C_PATH= '',
                               C_SYMBOL= '', stringsAsFactors=F, row.names=c())

ConceptDimension$CONCEPT_CD <- getNewIdentifiers(nrow(ConceptDimension), "I2B2DEMODATA.CONCEPT_ID")
i2b2$I2B2_ID <- getNewIdentifiers(nrow(i2b2), 'I2B2METADATA.I2B2_ID_SEQ')
i2b2$C_BASECODE <- ConceptDimension$CONCEPT_CD
# -----------

mutations$CONCEPT_PATH <- sapply(1:nrow(mutations), function(x) {
  concepts$CONCEPT_PATH[grepl(mutations$GENE[x],concepts$CONCEPT_NAME) &
                          grepl(mutations$value[x],concepts$CONCEPT_VALUE)]
})

mutations$CONCEPT_CD <- unlist(lapply(1:nrow(mutations), function(x) {
  ConceptDimension$CONCEPT_CD[mutations$CONCEPT_PATH[x] == ConceptDimension$CONCEPT_PATH]
}))

# create facts tables -----------

#concept_cds <- unlist(lapply(parents$ROLE, function(x) ConceptDimension$CONCEPT_CD[grep(x,ConceptDimension$NAME_CHAR)]))
#concepts_paths <- as.character(unlist(lapply(parents$ROLE, function(x) ConceptDimension$CONCEPT_PATH[grep(x,ConceptDimension$NAME_CHAR)])))
#tval <- unlist(lapply(parents$FAMILY, function(x) (probands$PATIENT_NUM[probands$SOURCESYSTEM_CD == paste0(x,'.p1')])[1]))
encounters <- getNewIdentifiers(numberOfIdsToGet = nrow(mutations), "I2B2DEMODATA.SQ_UP_ENCDIM_ENCOUNTERNUM",config )

obs <- data.frame(ENCOUNTER_NUM = encounters,
                  PATIENT_NUM = mutations$PATIENT_NUM,
                  CONCEPT_CD = mutations$CONCEPT_CD,
                  PROVIDER_ID = '@',
                  START_DATE = NA,
                  MODIFIER_CD = '@',
                  VALTYPE_CD = 'T',
                  TVAL_CHAR = mutations$value,
                  NVAL_NUM = NA,
                  VALUEFLAG_CD = NA,
                  QUANTITY_NUM = NA,
                  UNITS_CD = NA,
                  END_DATE = NA,
                  LOCATION_CD = NA,
                  CONFIDENCE_NUM = NA,
                  UPDATE_DATE = Sys.time(),
                  DOWNLOAD_DATE = Sys.time(),
                  IMPORT_DATE = Sys.time(),
                  SOURCESYSTEM_CD = config$STUDY_ID,
                  UPLOAD_ID = NA,
                  OBSERVATION_BLOB = NA,
                  INSTANCE_NUM = 1, stringsAsFactors=F)



patientFolder <- data.frame(PATIENT_NUM = mutations$PATIENT_NUM,
                            CONCEPT_PATH = mutations$CONCEPT_PATH, stringsAsFactors = F)

patientFolder <- rbind(patientFolder, data.frame(PATIENT_NUM = mutations$PATIENT_NUM,
                                                 CONCEPT_PATH = gsub('[^\\]+[\\]$','',mutations$CONCEPT_PATH),stringsAsFactors = F))


patientFolder <- rbind(patientFolder, data.frame(PATIENT_NUM = mutations$PATIENT_NUM,
                                                 CONCEPT_PATH = "\\Autism\\SSC_wigler_mutations\\",stringsAsFactors = F))

# --------

# compute concept_counts ------
patientFolder$PATIENT_COUNT <- 1
conceptCount <- aggregate(PATIENT_COUNT ~ CONCEPT_PATH, data = patientFolder, FUN =sum )
conceptCount <- merge(conceptCount,subset(concepts,select=c('CONCEPT_PATH','PARENT_CONCEPT_PATH')))

conceptCount <- conceptCount[,c('CONCEPT_PATH','PARENT_CONCEPT_PATH','PATIENT_COUNT')]
patientFolder$PATIENT_COUNT <- c()
# ----------

# write tables ---------
if (append) {
  write.table(ConceptDimension, file = paste0(config$CONCEPT_DIMENSION_OUT_FILE), sep = '\t', na = "", append=T,col.names = F,row.names=F, quote = F,fileEncoding = 'latin1')
  write.table(conceptCount, file = paste0(config$CONCEPT_COUNT_OUT_FILE), sep = '\t', na = "", append=T, col.names = F,row.names=F, quote = F,fileEncoding = 'latin1')
  write.table(i2b2, file = paste0(config$I2B2_OUT_FILE), sep = '\t', na = "", append=T, col.names = F,row.names=F, quote = F,fileEncoding = 'latin1')
  write.table(obs, file = config$OBSERVATION_FACT_OUT_FILE, sep = '\t', na = "", append=T, col.names = F,row.names=F, quote = F,fileEncoding= 'latin1')
  write.table(patientFolder, file = config$CONCEPTS_FOLDERS_PATIENTS_OUT_FILE, sep = '\t', na = "", append=T, col.names = F,row.names=F, quote = F,fileEncoding= 'latin1')

} else {
  write.table(ConceptDimension, file = paste0(config$CONCEPT_DIMENSION_OUT_FILE), sep = '\t', na = "", append=F,col.names = T,row.names=F, quote = F,fileEncoding = 'latin1')
  write.table(conceptCount, file = paste0(config$CONCEPT_COUNT_OUT_FILE), sep = '\t', na = "", append=F, col.names = T,row.names=F, quote = F,fileEncoding = 'latin1')
  write.table(i2b2, file = paste0(config$I2B2_OUT_FILE), sep = '\t', na = "", append=F, col.names = T,row.names=F, quote = F,fileEncoding = 'latin1')
  write.table(obs, file = config$OBSERVATION_FACT_OUT_FILE, sep = '\t', na = "", append=F, col.names = T,row.names=F, quote = F,fileEncoding= 'latin1')
  write.table(patientFolder, file = config$CONCEPTS_FOLDERS_PATIENTS_OUT_FILE, sep = '\t', na = "", append=F, col.names = T,row.names=F, quote = F,fileEncoding= 'latin1')
}




