rm(list=ls())

setwd('/mnt/nfs/etl/projects/AUTISM/SSC/r_clinical/')

r_scripts_path = 'R/'

source(paste0(r_scripts_path,'getConfig.R'))
source(paste0(r_scripts_path,'toLog.R'))
source(paste0(r_scripts_path,'JDBCConnect.R'))
#config <- getConfig('config_file')

source(paste0(r_scripts_path,'conceptsUtilities.R'))
source(paste0(r_scripts_path,'columnsUtilities.R'))
source(paste0(r_scripts_path,'getPatientSubjectHash.R'))
source(paste0(r_scripts_path,'getNewIdentifiers.R'))

source(paste0(r_scripts_path,'01-createMappingFile.R'))
source(paste0(r_scripts_path,'02-PatientDimension.R'))
source(paste0(r_scripts_path,'03-ConceptDimension.R'))
source(paste0(r_scripts_path,'04-ObservationFact.R'))

require(data.table)
require(dplyr)
require(foreach)
require(doSNOW)
require(reshape2)

config <- getConfig('config_file')

# setwd(config$DATA_BASE_PATH)

createMappingFile(conf = config)

### Warning: special columns (except for SUBJECT_ID) must appear in only 1 file
### Currently: special columns are SUBJECT_ID, RACE, SEX, AGE, DOB, DEATH, FAMILY, ROLE

# extract patient list ---------
patients <- extractPatientList(config)
# ---------

# get existing patients from DB (patient_mapping) ------
patientHash <- getPatientSubjectHash()
existingPatients <- merge(as.data.frame(patients), patientHash, by.x = 'SUBJECT_ID', by.y = 'PATIENT_IDE')
# ------

# find new patients --------
dataFiles <- findNewPatients(patients,patientHash)
patients <- mergePatients(existingPatients, dataFiles$newPatients)
# ---------

# create temp dir --------
if(!file.exists('temp')){
  dir.create('temp')
}
# ---------

# save patients and write tables -------
save(patients,file='temp/patients.RData')
write.table(dataFiles$patientDimensionData,file(paste0(config$PATIENT_DIMENSION_OUT_FILE)),quote = F, sep = '\t', na = '', row.names = F)
write.table(dataFiles$patientMappingData,file(paste0(config$PATIENT_MAPPING_OUT_FILE)),quote = F, sep = '\t', na = '', row.names = F)
write.table(dataFiles$patientTrialData,file(paste0(config$PATIENT_TRIAL_OUT_FILE)),quote = F, sep = '\t', na = '', row.names = F)

# ------------

# create conceptDimension, concept counts and i2b2 -------
conceptDimension()
# --------

# create observation facts and concepts_folders -------
#rm(temp)
ObservationFact()
# --------

# create control files --------
source(paste0(r_scripts_path,'controlFiles.R'))
# ----------

source(paste0(r_scripts_path,'alterIndexes.R'))

