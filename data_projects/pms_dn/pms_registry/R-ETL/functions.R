library(dplyr)
library(tidyr)

#' Simple push mechanism
push<-function(vector,value)
{
  vector<-c(vector,value)
  vector
}

#' Simple pop mechanism. Does not return the popped value
pop<-function(vector)
{
  vector<-vector[1:(length(vector)-1)]
  vector
}

#' Concatenate two headers and clean them
catClean<-function(header1,header2)
{
  header=paste(header1,header2,sep=" - ")
  
  # Clean the variable names
  header<-sub("^ - ","",header)
  header<-gsub("[^[:alnum:]-]","\\.",header)
  header<-gsub(".-.Responses$","",header)
  header<-gsub("\\.+","\\.",header)
  header<-gsub("-","_",header)
  header<-gsub("\\.+$","",header)
  
  header
}

#' Load a csv file with 2 header lines
#' 
#' Load a csv file with 2 header lines, the first one consisting of merged cells
#' 
#' This function loads a csv file (sep=",", quote="\"", encoding="UTF-8") with 2 header lines.
#' The first line of headers is broad categories, represented by merged cells in the original
#' excel data file.
#' The function concatenates the category with the underlying item question, separating them
#' with an hyphen. Spaces are replaced by dots, single quotes, apostrophe, commas and question marks are deleted.
#' Hyphens are deleted for questions without category.
#' @encoding UTF-8
#' @param file The csv file to load
#' @param ... Additional arguments to pass to read.csv
#' @return A dataframe with corrected column names
#' @examples
#' \dontrun{df <- read.csv.2header("data.csv")}
#' @export
read.csv.2header<-function(file,...)
{
  # Fill the first header line with values, propagating them forward
  header1<-scan(file,what=character(),nlines=1,sep=",",quote="\"")
  header2<-scan(file,what=character(),nlines=1,sep=",",quote="\"",skip=1)
  
  tmpHead<-""
  tmpHeader1<-character(0)
  for (head in header1)
  {
    if (head == "")
      head<-tmpHead
    
    tmpHeader1<-c(tmpHeader1,head)
    tmpHead<-head
  }
  
  header1<-tmpHeader1
  
  # Concatenate and clean the two header lines
  header<-catClean(header1,header2)
  
  # Read the data itself and attribute column names
  data<-read.csv(file,header = F,skip=2,stringsAsFactors=F,...)
  colnames(data)<-header
  
  data
}

#' Add a line to the mapping file
#' 
#' Add one new line to the mapping file object
#' 
#' Add one new line to the mapping file object by giving the data source file name, the column number,
#' the data label, and a list of levels for the ontology.
#' The levels for the ontology will have spaces replaced by underscores (_), and be concatenated with
#' a separating plus sign (+).
#' @encoding UTF-8
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
  categoryCode <- gsub(" ","_",categoryCode)
  mapping<-data.frame(Filename=dataFile,Category.Code=categoryCode,Column.Number=columnNum,Data.Label=dataLabel)
  write.table(mapping,file="output/mapping.txt",row.names=F,sep="\t",append = T,col.names=F,quote=F)
}