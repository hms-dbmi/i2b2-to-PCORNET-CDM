source("functions.R")
source("functions-mapping.R")

# Process at the file level
processFile<-function(questionnaire)
{
  # Add the questionnaire level to the ontology
  ontology<<-push(ontology,questionnaire)
  
  # Read the data and premapping files
  data<-read.csv.2header(paste0("data",questionnaire,".csv"))
  data<-data[!is.na(data$Survey.Session.ID),]
  
  premap<-read.csv(paste0("premap",questionnaire,".csv"),stringsAsFactors=F)
  
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
  addMapping(paste0(questionnaire,"-",subfile,".txt"),ontology,1,"SUBJ_ID")
  varNum<-2
  ontoLevel<-0
  for (varName in names(data2[-1]))
  {
    while(grepl("_",varName))
    {
      ontoLevel<-ontoLevel+1
      ontology<<-push(ontology,sub("_.*$","",varName))
      
      varName<-sub("^.*?_","",varName)
    }
    
    addMapping(paste0(questionnaire,"-",subfile,".txt"),ontology,varNum,varName)
    
    while(ontoLevel>0)
    {
      ontoLevel<-ontoLevel-1
      ontology<<-pop(ontology)
    }
    
    varNum<-varNum+1
  }
  
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
  # Find the index of the first variable by name in the data file
  idx1<-premap$ColNum[1] #premap's index of the variable
  idx2<-which(names(data)==premap$Header[1]) #data's index of the variable
  # Throw a warning if variable not found in the data
  if (length(idx2)==0)
  {
    warning("Variable not found: \"",premap$Header[1],"\" in data file at ontology level \"",paste(ontology,collapse="+"),"\"")
    return()
  }
  # If real homonyms at first position of head1, use an heuristic (pick the nearest one in position)
  if (length(idx2)>1)
  {
    idx2<-idx2[order(abs(idx2-idx1))[1]]
  }
  
  # Update indexes in the premap
  premap<-mutate(premap,ColNum=ColNum+(idx2-idx1))
  # Filter columns in data based on the updated index
  data<-data[c(1:3,premap$ColNum)]
  
  # Sort by Survey Date
  data$Survey.Date<-as.numeric(strptime(data$Survey.Date,format="%Y-%m-%d %H:%M:%S"))
  data<-arrange(data,Patient.ID,Survey.Date)
  
  # Delete records made less than 24 hours before the next
  data<-filter(data,(lead(Survey.Date)-Survey.Date)>24*3600 | lead(Patient.ID)!=Patient.ID | Patient.ID==max(Patient.ID))
  data<-select(data,-Survey.Date)
  
  # Filter for the last line of data for each patient
  # TODO : take account of HistEvo to modify behavior
  data<-data %>%
    group_by(Patient.ID) %>%
    filter(row_number(desc(Survey.Session.ID))==1)
  
  # Create new data frame to contain transformed/curated data
  data2<-select(data,Patient.ID)
  
  # Reformatting needed
  if (any(premap$Reformat==1))
  {
    # new vars prefix
    varPre<-levels(factor(unlist(data[premap$Header[premap$Reformat==1]]),exclude=""))
    # new vars suffix
    varSuff<-levels(factor(premap$VarName[!is.na(premap$Linked)]))
    # Create new vars after transform
    for (pre in varPre)
    {
      for (suff in varSuff)
      {
        data2[[paste(pre,suff,sep="_")]]<-NA
      }
    }
    
    #Effectively reformat the variable, keeping linked variables together
    for (patient in data2$Patient.ID)
    {
      for (link in levels(factor(premap$Linked)))
      {
        pre<-data[data$Patient.ID==patient,premap$Header[premap$Linked==link & premap$Reformat=="1"]]
        for (post in levels(factor(premap[premap$Linked==link,]$VarName)))
        {
          if (premap$Reformat[premap$Linked==link & premap$VarName==post])
          {
            data2[data2$Patient.ID==patient,][[paste(pre,post,sep="_")]]<-"Yes"
          }
          else
          {
            data2[data2$Patient.ID==patient,][[paste(pre,post,sep="_")]]<-data[data$Patient.ID==patient,premap$Header[premap$Linked==link & premap$VarName==post]]
          }
        }
      }
    }
    
    for (varName in names(data2))
    {
      data2[[varName]]<-unlist(data2[[varName]])
    }
    
    varnames<-names(data2)
    varnames[-1]<-paste(head1,varnames[-1],sep="_")
    varnames<-gsub("^_","",varnames)
    
    colnames(data2)<-varnames
  }
  else # Reformatting not needed
  {
    data2<-select(data,-Survey.Session.ID)
  }
  
  data2<-ungroup(data2)
  
  # Manage 'Other Value' columns
  if (length(select(data2,ends_with("_Other.Value"))) != 0)
  {
    # When there is an 'Other' column
    if (length(select(data2,ends_with("_Other"))) != 0)
    {
      varNameOther<-names(select(data2,ends_with("_Other")))
      varNameOtherValue<-names(select(data2,ends_with("_Other.Value")))
      data2[[varNameOther]][!is.na(data2[[varNameOther]])]<-data2[[varNameOtherValue]][!is.na(data2[[varNameOther]])]
    } # When there are only two columns (+1 for Patient.ID)
    else if (length(data2)==3)
    {
      varNameOther<-names(select(data2,-Patient.ID,-ends_with("_Other.Value")))
      varNameOtherValue<-names(select(data2,ends_with("_Other.Value")))
      data2[[varNameOther]][data2[[varNameOther]]=="Other"]<-data2[[varNameOtherValue]][data2[[varNameOther]]=="Other"]
    }
    data2<-select(data2,-ends_with("_Other.Value"))
  }
  
  data2
}