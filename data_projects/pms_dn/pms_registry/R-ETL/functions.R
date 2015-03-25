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
  # Clean variable names
  header1<-gsub(" \\(.*?\\)","",header1,perl = T)
  header1<-gsub("Please (enter|select) either pounds( and ounces)? or kilograms\\.","",header1,perl = T)
  header1<-gsub("Please enter either feet and inches or centimeters\\.","",header1,perl = T)
  header1<-gsub("Please answer the following questions\\.","",header1,perl = T)
  header1<-gsub("If you answer yes to any of the following questions, please select the age of occurrence\\.","",header1,perl = T)
  header1<-gsub("[^[:alnum:]]","\\.",header1, perl = T)
  
  header2<-gsub("^Responses$","",header2,perl = T)
  header2<-gsub(" - APGAR score$","",header2,perl = T)
  header2<-gsub(" - Frequency$","",header2,perl = T)
  header2<-gsub("([^\\d]) - Age at milestones?$","\\1",header2,perl = T)
  header2<-gsub("([^\\d]) - Age$","\\1",header2,perl = T)
  header2<-gsub(" - ","_",header2,perl = T)
  header2<-gsub("[^[:alnum:]_]","\\.",header2,perl = T)
    
  # Merge the two headers
  header=paste(header1,header2,sep="_")
  
  # Clean the variable names
  header<-sub("^_","",header,perl = T)
  header<-sub("_$","",header,perl = T)
  header<-gsub("\\.+","\\.",header,perl = T)
  header<-gsub("\\.+$","",header,perl = T)
  header<-gsub("\\.*_\\.*","_",header,perl = T)

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
#' @param path Path to which create the mapping file
#' @param dataFile The data source file name
#' @param columnNum The column number from the data source file
#' @param dataLabel The desired label in the ontology
#' @param categoryCode A vector of ontology levels in the correct order
#' @return An updated mapping file object
#' @examples
#' \dontrun{mapping <- addMapping("data.txt",1,SUBJ_ID,"New ontology","Demographics")}
#' @export
addMapping <- function(path,dataFile,categoryCode,columnNum,dataLabel)
{
  categoryCode <- paste(categoryCode,collapse="+")
  categoryCode <- gsub(" ","_",categoryCode)
  mapping<-data.frame(Filename=dataFile,Category.Code=categoryCode,Column.Number=columnNum,Data.Label=dataLabel)
  write.table(mapping,file=paste0(path,"/mapping.txt"),row.names=F,sep="\t",append = T,col.names=F,quote=F)
}


#' Write an empty template premapping file from the data file
#' @encoding UTF-8
#' @param datafile The data frame holding the data to premap
#' @param premapfile The premap filename to save to
writePremap <- function(datafile,premapfile)
{
  header1<-scan(datafile,what=character(),nlines=1,sep=",",quote="\"")
  header2<-scan(datafile,what=character(),nlines=1,sep=",",quote="\"",skip=1)
  
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
  
  header1<-gsub(" \\(.*?\\)","",header1,perl = T)
  header1<-gsub("Please (enter|select) either pounds( and ounces)? or kilograms\\.","",header1,perl = T)
  header1<-gsub("Please enter either feet and inches or centimeters\\.","",header1,perl = T)
  header1<-gsub("Please answer the following questions\\.","",header1,perl = T)
  header1<-gsub("If you answer yes to any of the following questions, please select the age of occurrence\\.","",header1,perl = T)
    
  header2<-gsub("^Responses$","",header2,perl = T)
  header2<-gsub(" - APGAR score$","",header2,perl = T)
  header2<-gsub(" - Frequency$","",header2,perl = T)
  header2<-gsub("([^\\d]) - Age at milestones?$","\\1",header2,perl = T)
  header2<-gsub("([^\\d]) - Age$","\\1",header2,perl = T)
  header2<-gsub("\"","",header2,perl=T)
  
  header<-paste(header1,header2,sep=" - ")
  header<-sub("^ - ","",header,perl = T)
  header<-sub(" - $","",header,perl = T)
  
  Head1<-sub("(^.*?) - .*$","\\1",header,perl=T)
  Head2<-sub("^.*? - (.*$)","\\1",header,perl=T)
  Head1[Head2==Head1]<-""

  ColNum<-1:length(Head1)
  premap<-data.frame(ColNum,Head1,Head2,stringsAsFactors=F)
  premap<-mutate(premap,SubFile="",DemoEvo="",Reformat=0,VarName=Head2,Linked="")
  premap[grepl("\\d+ -",premap$Head2),] <- premap %>%
    filter(grepl("\\d+ -",Head2)) %>%
    mutate(Linked=sub("(^\\d+) -.*","\\1",Head2)) %>%
    mutate(VarName=sub("\\d+ - (.*$)","\\1",Head2))
  premap <- mutate(premap,Header=catClean(Head1,Head2))
  
  write.table(premap,file=premapfile,row.names=F,sep=",",quote=T)
}