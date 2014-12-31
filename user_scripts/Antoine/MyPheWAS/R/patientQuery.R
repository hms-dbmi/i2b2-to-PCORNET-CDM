#'patientQuery
#'
#'Create a data.frame containing patients characteristics selected by a specific query in an i2b2 datacenter
#'
#'@param connexion : db connexion
#'@param query : string containing a selection criteria (e.g. "PATIENT_NUM = 1233405")
#'@param aggregation : "patient" or "encounter"
#'@return patient data.frame
#'@export
patientQuery <- function(connexion, query, aggregation="patient") {
  require(RJDBC)
  if (aggregation == "encounter"){
    PATIENT <- dbGetQuery(connexion, paste("select CAST(p.PATIENT_NUM as varchar2(100)) as PATIENT_CHAR, CAST(v.ENCOUNTER_NUM as varchar2(100)) as ENCOUNTER_CHAR, p.BIRTH_DATE, extract(year from p.BIRTH_DATE) as BIRTH_YEAR, p.DEATH_DATE, p.SEX_CD",
                                         "FROM I2B2DEMODATA.PATIENT_DIMENSION p, I2B2DEMODATA.VISIT_DIMENSION v",
                                         "WHERE v.PATIENT_NUM = p.PATIENT_NUM", 
                                         "AND v.ENCOUNTER_NUM in (", 
                                         "select distinct ENCOUNTER_NUM",
                                         "FROM I2B2DEMODATA.OBSERVATION_FACT o ",
                                         "WHERE ",query,")"))
  }else{
    p.query <- paste("(",
                     "select distinct o.PATIENT_NUM",
                     "FROM I2B2DEMODATA.OBSERVATION_FACT o ",
                     "WHERE ",query,")")
    PATIENT <- dbGetQuery(connexion, paste("select p.PATIENT_NUM, p.BIRTH_DATE,p.RACE_CD, extract(year from p.BIRTH_DATE) as BIRTH_YEAR, p.DEATH_DATE, p.SEX_CD, p.SOURCESYSTEM_CD",
                                         "FROM I2B2DEMODATA.PATIENT_DIMENSION p",
                                         "WHERE p.PATIENT_NUM in ",p.query))
    
  }
  
  return(PATIENT)
}
