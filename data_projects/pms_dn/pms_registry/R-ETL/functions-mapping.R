# Add mappings for a subfile
addMappings<-function(questionnaire,subfile,ontology,data)
{
  addMapping(paste0(questionnaire,"-",subfile,".txt"),ontology,1,"SUBJ_ID")
  varNum<-2
  ontoLevel<-0
  for (varName in names(data[-1]))
  {
    while(grepl("_",varName))
    {
      ontoLevel<-ontoLevel+1
      ontology<-push(ontology,sub("_.*$","",varName))
      
      varName<-sub("^.*?_","",varName)
    }
    
    addMapping(paste0(questionnaire,"-",subfile,".txt"),ontology,varNum,varName)
    
    while(ontoLevel>0)
    {
      ontoLevel<-ontoLevel-1
      ontology<-pop(ontology)
    }
    
    varNum<-varNum+1
  }
}

# Add a line to the mapping file
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

# Simple push mechanism
push<-function(vector,value)
{
  vector<-c(vector,value)
  vector
}

# Simple pop mechanism. Does not return the popped value but the modified vector
pop<-function(vector)
{
  if (length(vector)==1)
  {
    return(character(0))
  }
  vector<-vector[1:(length(vector)-1)]
  vector
}