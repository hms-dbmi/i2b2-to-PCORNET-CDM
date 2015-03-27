library(dplyr)
library(tidyr)

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
  headers<-read2headers(file)
  
  # Concatenate and clean the two header lines
  header<-catClean(headers[[1]],headers[[2]])
  
  # Read the data itself and attribute column names
  data<-read.csv(file,header = F,skip=2,stringsAsFactors=F,...)
  colnames(data)<-header
  
  data
}

#' Write an empty template premapping file from the data file
#' @encoding UTF-8
#' @param datafile The data frame holding the data to premap
#' @param premapfile The premap filename to save to
writePremap <- function(datafile,premapfile)
{
  headers<-read2headers(datafile)
  
  # Concatenate and clean the two header lines
  header<-catClean(headers[[1]],headers[[2]])
  
  # Re-split the header for the mapping file
  Head1<-sub("(^.*?)_.*$","\\1",header,perl=T)
  Head2<-sub("^.*?_(.*$)","\\1",header,perl=T)
  Head2[Head2==Head1]<-""

  # Create all columns for mapping file
  ColNum<-1:length(Head1)
  premap<-data.frame(ColNum,Head1,Head2,stringsAsFactors=F)
  premap<-mutate(premap,SubFile="",DemoEvo="",Reformat=0,VarName="",Linked="")
  premap[grepl("\\d+_",premap$Head2),] <- premap %>%
    filter(grepl("\\d+_",Head2)) %>%
    mutate(Linked=sub("(^\\d+)_.*","\\1",Head2)) %>%
    mutate(VarName=sub("\\d+_(.*$)","\\1",Head2))
  premap <- mutate(premap,Header=header)
  
  write.table(premap,file=premapfile,row.names=F,sep=",",quote=T)
}

#' Concatenate two headers and clean them
catClean<-function(header1,header2)
{
  # Clean variable names
  header1<-cleanHeader1(header1)
  header2<-cleanHeader2(header2)
  
  # Merge the two headers
  header=paste(header1,header2,sep="_")
  
  # Clean the merging
  header<-sub("^_","",header,perl = T)
  header<-sub("_$","",header,perl = T)
  
  # Replace spaces with dots
  header<-gsub(" +",".",header,perl = T)
    
  header
}

cleanHeader1<-function(header1)
{
  header1<-gsub(" \\(.*?\\)","",header1,perl = T)
  header1<-gsub("Please (enter|select) either pounds( and ounces)? or kilograms\\.","",header1,perl = T)
  header1<-gsub("Please enter either feet and inches or centimeters\\.","",header1,perl = T)
  header1<-gsub("Please answer the following questions\\.","",header1,perl = T)
  header1<-gsub("If you answer yes to any of the following questions, please select the age of occurrence\\.","",header1,perl = T)
  
  header1
}

cleanHeader2<-function(header2)
{
  header2<-gsub("^Responses$","",header2,perl = T)
  header2<-gsub(" - APGAR score$","",header2,perl = T)
  header2<-gsub(" - Frequency$","",header2,perl = T)
  header2<-gsub("([^\\d]) - Age( at milestones?)?$","\\1",header2,perl = T)
  header2<-gsub(" - ","_",header2,perl = T)
  header2<-gsub("\"","",header2,perl=T)
  
  header2
}

#' Read headers from a two headers file and propagate the first one
read2headers<-function(file)
{
  header1<-scan(file,what=character(),nlines=1,sep=",",quote="\"")
  header2<-scan(file,what=character(),nlines=1,sep=",",quote="\"",skip=1)
  
  # Fill the first header line with values, propagating them forward
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
  
  # Return the two headers as a list
  headers<-list(header1,header2)
  
  headers
}