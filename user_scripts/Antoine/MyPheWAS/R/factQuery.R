#'factQuery
#'
#'Create a data.frame containing facts from a patient list in an i2b2 datacenter
#'
#'@param connexion : db connexion
#'@param patient.list : vector of patient_nums
#'@param restriction : string containing a SQL condition regarding the facts to return
#'@param aggregation : "patient" or "encounter"
#'@return fact data.frame
#'@export
factQuery <- function(connexion,patient.list,restriction = "", aggregation="patient"){
  if (aggregation =='encounter'){
    ag = 'o.ENCOUNTER_NUM'
  } else {
    ag = 'o.PATIENT_NUM'
  }
  if (restriction != "") {
    restriction <- paste(restriction, "and")
  }
  init = 1
  end = 50
  max = length(patient.list)
  while(end < max ) {
    TEMP <- dbGetQuery(connexion, paste("select o.PATIENT_NUM, o.ENCOUNTER_NUM, o.concept_cd,c.name_char, c.concept_path, o.provider_id, o.tval_char,o.nval_num,o.valueflag_cd,o.quantity_num,o.units_cd,o.modifier_cd,o.start_date, o.end_date , o.observation_blob",
                                        "FROM I2B2DEMODATA.OBSERVATION_FACT o, I2B2DEMODATA.CONCEPT_DIMENSION c",
                                        "WHERE o.concept_cd = c.concept_cd and",restriction,
                                        ag," in (",paste(patient.list[init:end], collapse=','),")"))
    if (init == 1) {
     FACT <- TEMP 
    } else {
      FACT <- rbind(FACT,TEMP)
    }
      
    
    init <- init + 50
    end <- min(max, end + 50)
    print(paste(as.character(round(100 * init/max, digits=2)),"%"))
  }
  
  
  
  return(FACT)
}