library(dplyr)

# Load a csv file with 2 header rows
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

# Create a template premapping file from a data file
writePremap <- function(datafile,premapfile)
{
  headers<-read2headers(datafile)
  
  # Concatenate and clean the two header lines
  header<-catClean(headers[[1]],headers[[2]])
  
  # Re-split the header for the mapping file
  Head1<-sub("(^.*?)_.*$","\\1",header,perl=T)
  Head2<-sub("^.*?_(.*$)","\\1",header,perl=T)
  
  # If only one header, put it in first header
  Head2[Head2==Head1]<-""

  # Create all columns for mapping file
  ColNum<-1:length(Head1)
  premap<-data.frame(ColNum,Head1,Head2,stringsAsFactors=F)
  premap<-mutate(premap,SubFile="",HistEvo="",Reformat=0,VarName="",Linked="")
  premap[grepl("\\d+_",premap$Head2),] <- premap %>%
    filter(grepl("\\d+_",Head2)) %>%
    mutate(Linked=sub("(^\\d+)_.*","\\1",Head2)) %>%
    mutate(VarName=sub("\\d+_(.*$)","\\1",Head2))
  premap <- mutate(premap,Header=header)
  
  write.table(premap,file=premapfile,row.names=F,sep=",",quote=T)
}

# Clean and concatenate two headers
catClean<-function(header1,header2)
{
  # Clean variable names
  header1<-cleanHeader1(header1)
  header2<-cleanHeader2(header2)
  
  # Merge the two headers
  header=paste(header1,header2,sep="_")
  
  # Clean the merging (trailing "_")
  header<-sub("^_","",header,perl = T)
  header<-sub("_$","",header,perl = T)
  
  # Replace spaces with dots
  header<-gsub(" +",".",header,perl = T)
    
  header
}

# Clean the first header
cleanHeader1<-function(header1)
{
  header1<-gsub(" \\(.*?\\)","",header1,perl = T)
  header1<-gsub("Please (enter|select) either pounds( and ounces)? or kilograms\\.","",header1,perl = T)
  header1<-gsub("Please enter either feet and inches or centimeters\\.","",header1,perl = T)
  header1<-gsub("Please answer the following questions\\.","",header1,perl = T)
  header1<-gsub("If you answer yes to any of the following questions, please select the age of occurrence\\.","",header1,perl = T)
  
  header1
}

# Clean the second header
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

# Read headers from a two headers file and propagate the first one to all corresponding columns
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