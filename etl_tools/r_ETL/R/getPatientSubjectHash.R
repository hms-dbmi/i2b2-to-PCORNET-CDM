
#source('../MyPheWAS/R/getConfig.R')
#config <- getConfig('config_file')

# source('../MyPheWAS/R/JDBCConnect.R')
# source('../MyPheWAS/R/toLog.R')

getPatientSubjectHash <- function(conf = config) {
  con <- JDBCConnect(conf)
  query <- dbSendQuery(con, paste0('select PATIENT_NUM,PATIENT_IDE from PATIENT_MAPPING'))
  result <- dbFetch(query)
  dbDisconnect(con)
  toLog(paste0('Retrieved ', nrow(result),' patient IDs from PATIENT_MAPPING'))
  return(result)
}


