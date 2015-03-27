#' Add a line to the mapping file
#' 
#' Add one new line to the mapping file object
#' 
#' Add one new line to the mapping file object by giving the data source file name, the column number,
#' the data label, and a list of levels for the ontology.
#' The levels for the ontology will have spaces replaced by underscores (_), and be concatenated with
#' a separating plus sign (+).
#' @encoding UTF-8
#' @param path Path to which create the mapping file
#' @param dataFile The data source file name
#' @param columnNum The column number from the data source file
#' @param dataLabel The desired label in the ontology
#' @param categoryCode A vector of ontology levels in the correct order
#' @return An updated mapping file object
#' @examples
#' \dontrun{mapping <- addMapping("data.txt",1,SUBJ_ID,"New ontology","Demographics")}
#' @export
addMapping <- function(dataFile,categoryCode,columnNum,dataLabel)
{
  categoryCode <- paste(categoryCode,collapse="+")
  # Revert dots to spaces
  # underscores for categoryCode
  categoryCode <- gsub("\\.","_",categoryCode)
  # spaces for variable names
  dataLabel <- gsub("\\."," ",dataLabel)
  mapping<-data.frame(Filename=dataFile,Category.Code=categoryCode,Column.Number=columnNum,Data.Label=dataLabel)
  write.table(mapping,file="output/mapping.txt",row.names=F,sep="\t",append = T,col.names=F,quote=F)
}

#' Simple push mechanism
push<-function(vector,value)
{
  vector<-c(vector,value)
  vector
}

#' Simple pop mechanism. Does not return the popped value
pop<-function(vector)
{
  if (length(vector)==1)
  {
    return(character(0))
  }
  vector<-vector[1:(length(vector)-1)]
  vector
}