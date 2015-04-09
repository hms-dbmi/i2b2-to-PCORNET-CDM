source("functions-mapping.R")
source("functions-reformatting.R")

# Process at the file level
processFile<-function(questionnaire)
{
  # Add the questionnaire level to the ontology
  ontology<<-push(ontology,questionnaire)
  
  # Read the data and premapping files
  data<-read.csv.2header(paste0("data",questionnaire,".csv"))
  data<-data[data$Survey.Session.ID!="",]
  
  premap<-read.csv(paste0("premap",questionnaire,".csv"),stringsAsFactors=F,colClasses="character")
  premap$ColNum<-as.integer(premap$ColNum)
  
  # Process each SubFile level (excluding the empty SubFile level->Demographics)
  for (subfile in levels(factor(premap$SubFile,exclude="")))
  {
    processSubfile(questionnaire,subfile,data,premap)
  }
  
  ontology<<-pop(ontology)
}

# Process at the SubFile level
processSubfile<-function(questionnaire,subfile,data,premap)
{
  # Add the SubFile level to the ontology
  ontology<<-push(ontology,subfile)
  
  # Subset the premapping file with only the current SubFile
  premap<-filter(premap,SubFile==subfile)
  
  # Create new data frame to contain transformed/curated data
  data2<-data["Patient.ID"]
  data2<-data2 %>% distinct()
  
  # Process each Head1 level and merge resulting data
  for (head1 in unique(premap$Head1))
  {
    data2<-merge(data2,processHead1(head1,data,premap),by="Patient.ID")
  }
  
  # Parse resulting var names and write mappings
  addMappings(questionnaire,subfile,ontology,data2)
  
  # Write the $SubFile.txt
  write.table(data2,file=paste0("output/",questionnaire,"-",subfile,".txt"),row.names=F,sep="\t",quote=F,na="")
  
  ontology<<-pop(ontology)
}

# Process at the Head1 level
processHead1<-function(head1,data,premap)
{
  # Subset the premapping file with only the current Head1
  premap<-filter(premap,Head1==head1)
  
  # Anchor-based filtering of variables from the data file
  data<-anchorFilter(premap,data)
  
  # Sort by Survey Date
  data$Survey.Date<-as.numeric(strptime(data$Survey.Date,format="%Y-%m-%d %H:%M:%S"))
  data<-arrange(data,Patient.ID,Survey.Date)
  
  # Delete records made less than 24 hours before the next
  data<-filter(data,(lead(Survey.Date)-Survey.Date)>24*3600 | lead(Patient.ID)!=Patient.ID | Patient.ID==max(Patient.ID))
  
 # Reformatting needed. Execute the function given in the premap file for the reformatting
  if (any(premap$Reformat!=""))
  {
    funcname<-levels(factor(premap$Reformat,exclude=""))
    eval(parse(text=paste0("data<-",funcname,"(data,premap)")))
  }
 
  # Manage 'Other Value' columns
  if (any(grepl("_Other.Value$",names(data))))
    data<-otherValue(data)
  
  # Manage "checkbox" items
  if (any(grepl("_Unsure$",names(data))))
    data<-checkboxes(data)
 
  # Manage longitudinal data
  if (any(premap$Evo=="1"))
    data<-evolutive(data)
  else
    data<-historical(data)
  
  data
}