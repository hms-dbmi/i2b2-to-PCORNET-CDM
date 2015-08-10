rm(list=ls())

setwd('/opt/etl/projects/AUTISM/SSC/Clinical/r_etl/')
r_scripts_path = 'R/'

append = T

require(data.table)
require(dplyr)

source(paste0(r_scripts_path,'getConfig.R'))
source(paste0(r_scripts_path,'conceptsUtilities.R'))
source(paste0(r_scripts_path,'columnsUtilities.R'))
source(paste0(r_scripts_path,'getNewIdentifiers.R'))
source(paste0(r_scripts_path,'JDBCConnect.R'))
source(paste0(r_scripts_path,'toLog.R'))

load('temp/patients.RData')

config <- getConfig('config_file')

# keep only non proband patients (relations will be defined from probands) --------
probands <- patients[patients$ROLE == 'p1',]
parents <- patients[patients$ROLE != 'p1',]
# ----------

# concepts definitions ----------
roles <- levels(as.factor(parents$ROLE))


roles_name_short <- c(paste0('is_',roles,'_of'))


roles_path <- paste0(config$MAPPING_BASE_PATH,'01-Relations\\',roles_name_short,'\\')

# manual override of roles_names
roles_name <- c('Is_Father_of','Is_Mother_of', 'Is_Twin_of','Is_sibling1_of', 'Is_sibling2_of','Is_sibling3_of','Is_sibling4_of','Is_sibling5_of','Is_sibling6_of')
roles_name <- c(roles_name,'01-Relations')
roles_name_short <- c(roles_name_short,'01-Relations')

roles_path <- gsub('\\\\\\\\','\\\\',roles_path)
roles_parent <- paste0(config$MAPPING_BASE_PATH,'01-Relations\\')
roles_parent <- gsub('\\\\\\\\','\\\\',roles_parent)

# -----------

# create concepts tables ---------
ConceptDimension <- data.frame(CONCEPT_CD = 0 ,
                              CONCEPT_PATH = c(roles_path,roles_parent),
                              NAME_CHAR = roles_name_short,
                              CONCEPT_BLOB = '',
                              UPDATE_DATE = Sys.time(),
                              DOWNLOAD_DATE = Sys.time(),
                              IMPORT_DATE= Sys.time(),
                              SOURCESYSTEM_CD= config$SOURCESYSTEM,
                              UPLOAD_ID= '',
                              TABLE_NAME= '', stringsAsFactors=F)


# 27464321 -> 27464329

i2b2 <- data.frame(C_HLEVEL = 3,
                               C_FULLNAME = c(roles_path,roles_parent),
                               C_NAME = roles_name,
                               C_SYNONYM_CD = 'N',
                               C_VISUALATTRIBUTES = 'LA',
                               C_TOTALNUM = '',
                               C_BASECODE = 0,
                               C_METADATAXML = '',
                               C_FACTTABLECOLUMN= 'CONCEPT_CD',
                               C_TABLENAME= 'CONCEPT_DIMENSION',
                               C_COLUMNNAME= 'CONCEPT_PATH',
                               C_COLUMNDATATYPE= 'T',
                               C_OPERATOR= 'LIKE',
                               C_DIMCODE= c(roles_path,roles_parent),
                               C_COMMENT= config$STUDY_ID,
                               C_TOOLTIP= c(roles_path,roles_parent),
                               UPDATE_DATE= Sys.time(),
                               DOWNLOAD_DATE=Sys.time(),
                               IMPORT_DATE=Sys.time(),
                               SOURCESYSTEM_CD= config$STUDY_ID,
                               VALUETYPE_CD= '',
                               I2B2_ID= 0,
                               M_APPLIED_PATH= '',
                               M_EXCLUSION_CD= '',
                               C_PATH= '',
                               C_SYMBOL= '', stringsAsFactors=F)

i2b2$C_HLEVEL[i2b2$C_NAME == '01-Relations'] <- 2
i2b2$C_VISUALATTRIBUTES[i2b2$C_NAME == '01-Relations'] <- 'FA'

# 26051101 -> 26051109

ConceptDimension$CONCEPT_CD <- getNewIdentifiers(nrow(ConceptDimension), "I2B2DEMODATA.CONCEPT_ID")
i2b2$I2B2_ID <- getNewIdentifiers(nrow(i2b2), 'I2B2METADATA.I2B2_ID_SEQ')
i2b2$C_BASECODE <- ConceptDimension$CONCEPT_CD
# -----------

# create facts tables -----------

concept_cds <- unlist(lapply(parents$ROLE, function(x) ConceptDimension$CONCEPT_CD[grep(x,ConceptDimension$NAME_CHAR)]))
concepts_paths <- as.character(unlist(lapply(parents$ROLE, function(x) ConceptDimension$CONCEPT_PATH[grep(x,ConceptDimension$NAME_CHAR)])))
tval <- unlist(lapply(parents$FAMILY, function(x) (probands$PATIENT_NUM[probands$SOURCESYSTEM_CD == paste0(x,'.p1')])[1]))
encounters <- getNewIdentifiers(numberOfIdsToGet = nrow(parents), "I2B2DEMODATA.SQ_UP_ENCDIM_ENCOUNTERNUM",config )

obs <- data.frame(ENCOUNTER_NUM = encounters,
                  PATIENT_NUM = parents$PATIENT_NUM,
                  CONCEPT_CD = concept_cds,
                  PROVIDER_ID = '@',
                  START_DATE = NA,
                  MODIFIER_CD = '@',
                  VALTYPE_CD = 'T',
                  TVAL_CHAR = tval,
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
                  SOURCESYSTEM_CD = config$FACT_SET,
                  UPLOAD_ID = NA,
                  OBSERVATION_BLOB = NA,
                  INSTANCE_NUM = 1, stringsAsFactors=F)



patientFolder <- data.frame(PATIENT_NUM = parents$PATIENT_NUM,
                            CONCEPT_PATH = concepts_paths, stringsAsFactors = F)

patientFolder <- rbind(patientFolder, data.frame(PATIENT_NUM = parents$PATIENT_NUM,
                                                  CONCEPT_PATH = '\\Autism\\SFARI_Simplex_Collection_v15\\01-Relations\\'),stringsAsFactors = F)

# --------

# compute concept_counts ------
patientFolder$PATIENT_COUNT <- 1
conceptCount <- aggregate(PATIENT_COUNT ~ CONCEPT_PATH, data = patientFolder, FUN =sum )
conceptCount$PARENT_CONCEPT_PATH <- gsub('[^\\]+[\\]$','',conceptCount$CONCEPT_PATH)
conceptCount <- conceptCount[grepl(config$MAPPING_BASE_PATH,conceptCount$CONCEPT_PATH),]
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
  write.table(i2b2, file = paste0(config$I2B2_OUT_FILE), sep = '\t', na = "", append=F, col.names = F,row.names=T, quote = F,fileEncoding = 'latin1')
  write.table(obs, file = config$OBSERVATION_FACT_OUT_FILE, sep = '\t', na = "", append=F, col.names = F,row.names=T, quote = F,fileEncoding= 'latin1')
  write.table(patientFolder, file = config$CONCEPTS_FOLDERS_PATIENTS_OUT_FILE, sep = '\t', na = "", append=F, col.names = T,row.names=F, quote = F,fileEncoding= 'latin1')

}


