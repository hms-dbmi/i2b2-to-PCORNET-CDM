SendQueries <- function(conf = config, query_list) {
  con <- JDBCConnect(conf)
  for(query in query_list) {
    cat(paste0(query,'...'))
    dbSendUpdate(con,query)
    cat('Done\n')
  }
  dbDisconnect(con)
}