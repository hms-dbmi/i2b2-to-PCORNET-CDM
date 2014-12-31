#'getConfig
#'
#'Load configuration parameters for DB connection
#'This file is a tab separated txt file of the form: 
#'
#'driver_type     VALUE
#'
#'driver_path     VALUE
#'
#'db_user VALUE
#'
#'db_pass VALUE
#'
#'db_host VALUE
#'
#'db_port VALUE
#'
#'db_name VALUE
#'
#'@param file_path Path to the config file
#'@return config environment for DB connection
#'@export


getConfig <- function(file_path)
{
  # TODO: check that config_file exists
  
  t <- read.table(file_path, sep = '\t', header = F, as.is=T)
  config <- new.env()
  
  for (i in 1:nrow(t)) 
  {
    config[[t[i,1]]] <- t[i,2]
  }
  return(config)
}