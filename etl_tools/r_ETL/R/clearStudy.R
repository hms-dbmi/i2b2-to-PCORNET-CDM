r_scripts_path = 'r_etl/R/'
source(paste0(r_scripts_path,'SendQueries.R'))

min_patient_num = 252379
max_patient_num = 252461
sourcesystem_cd = "'SVIP_1Q21'"
base_path = "'\\Autism\\SVIP_1Q21\\%'"


deleteStudyFromDb <- function(min_patient_num, max_patient_num, sourcesystem_cd, base_path) {
  queries <- c(paste('delete',
                     'from I2B2DEMODATA.CONCEPT_DIMENSION',
                     'WHERE sourcesystem_cd =', sourcesystem_cd),
               paste('delete',
                     'from I2B2DEMODATA.OBSERVATION_FACT',
                     'WHERE sourcesystem_cd = ',sourcesystem_cd),
               paste('delete',
                     'from I2B2DEMODATA.CONCEPT_COUNTS',
                     'WHERE concept_path like ', base_path),
               paste('delete',
                     'from I2B2METADATA.I2B2',
                     'WHERE C_FULLNAME like ', base_path),
               paste('delete',
                     'from I2B2DEMODATA.CONCEPTS_FOLDERS_PATIENTS',
                     'where CONCEPT_PATH like', base_path),
               paste('delete',
                     'from I2B2DEMODATA.PATIENT_DIMENSION ',
                     'where patient_num >=', min_patient_num,
                     'and patient_num <= ', max_patient_num),
               paste('delete', 
                     'from I2B2DEMODATA.PATIENT_MAPPING' ,
                     'where patient_num >=', min_patient_num,
                     'and patient_num <= ', max_patient_num),
               paste('delete',
                     'from I2B2DEMODATA.PATIENT_TRIAL',
                     'where patient_num >=', min_patient_num,
                     'and patient_num <= ', max_patient_num)
  )
  SendQueries(config, queries )
}

deleteStudyFromDb(min_patient_num, max_patient_num, sourcesystem_cd, base_path)

