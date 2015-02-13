
#source('../MyPheWAS/R/getConfig.R')
#config <- getConfig('config_file')

# source('../MyPheWAS/R/JDBCConnect.R')
# source('../MyPheWAS/R/toLog.R')

getNewIdentifiers <- function(numberOfIdsToGet, nameOfSequence, conf = config) {
  con <- JDBCConnect(conf)
  query <- dbSendQuery(con, paste0('select ',nameOfSequence,'.nextval from dual connect by level<= ',numberOfIdsToGet))
  result <- dbFetch(query)
  dbDisconnect(con)
  toLog(paste0('Retrieved ', numberOfIdsToGet,' new identifiers from ',nameOfSequence, '(',result$NEXTVAL[1],' to ',last(result$NEXTVAL),')'))
  return(result$NEXTVAL)
}


