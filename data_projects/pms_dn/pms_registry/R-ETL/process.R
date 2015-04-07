source("functions.R")
source("functions-mapping.R")

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
  
  # Filter for the last line of data for each patient
  # TODO : take account of Evo to modify behavior
  data<-data %>%
    group_by(Patient.ID) %>%
    filter(Survey.Date==last(Survey.Date))
  data<-ungroup(data)
  
  # Reformatting needed
  if (any(premap$Reformat!=""))
    if (any(premap$Reformat=="1"))
      data<-reformat(data,premap)
    
  # Manage 'Other Value' columns
  if (any(grepl("_Other.Value$",names(data))))
    data<-otherValue(data)
  
  # Manage "checkbox" items
  if (any(grepl("_Unsure$",names(data))))
    data<-checkboxes(data)
  
  select(data,-Survey.Date,-Birthdate)
}

# Anchor-based filtering of data from the mapping file
anchorFilter<-function(premap,data)
{
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
    idx2<-idx2[order(abs(idx2-idx1))[1]]

  # Update indexes in the premap
  premap<-mutate(premap,ColNum=ColNum+(idx2-idx1))

  # Filter columns in data based on the updated index
  data[c(which(names(data) %in% c("Patient.ID","Survey.Date","Birthdate")),premap$ColNum)]
}

reformat<-function(data,premap)
{
  # Create new data frame to contain transformed/curated data
  data2<-select(data,Patient.ID,Survey.Date,Birthdate)
  
  # new vars prefix
  varPre<-levels(factor(unlist(data[premap$Header[premap$Reformat=="1"]]),exclude=c("","No")))
  # new vars suffix
  varSuff<-levels(factor(premap$VarName[premap$Linked!=""]))
  # Create new vars after transform
  for (pre in varPre)
    for (suff in varSuff)
      data2[[paste(pre,suff,sep="_")]]<-NA
  
  #Effectively reformat the variable, keeping linked variables together
  for (row in 1:nrow(data2))
  {
    for (link in levels(factor(premap$Linked,exclude="")))
    {
      pre<-data[row,premap$Header[premap$Linked==link & premap$Reformat=="1"]]
      if (pre=="" | pre=="No")
        next
      for (suff in varSuff)
      {
        if (premap$Reformat[premap$Linked==link & premap$VarName==suff]=="1")
        {
          data2[row,paste(pre,suff,sep="_")]<-"Yes"
        }
        else
        {
          data2[row,paste(pre,suff,sep="_")]<-data[row,premap$Header[premap$Linked==link & premap$VarName==suff]]
        }
      }
    }
  }
  
  # Rename variables
  for (varName in names(data2))
    data2[[varName]]<-unlist(data2[[varName]])
  
  varnames<-names(data2)
  varnames[-(1:3)]<-paste(premap$Head1[1],varnames[-(1:3)],sep="_")
  varnames<-gsub("^_","",varnames)
  
  colnames(data2)<-varnames
  
  data2
}

otherValue<-function(data)
{
  colOtherValue<-grep("_Other.Value$",names(data))
  
  if (any(grepl("_Other$",names(data)))) # When there is an 'Other' column
  {
    colOther<-grep("_Other$",names(data))
    data[data[colOther]=="1",colOther]<-data[data[colOther]=="1",colOtherValue]
  }
  else if (length(data)==5) # When there are only two columns (+3 for Patient.ID,Survey.Date,Birthdate)
  {
    colOther<-grep("_Other.Value",names(data[-(1:3)]),invert=T)+3
    data[data[colOther]=="Other",colOther]<-data[data[colOther]=="Other",colOtherValue]
  }
  
  select(data,-ends_with("_Other.Value"))
}

checkboxes<-function(data)
{
  ## Set "_Other" column aside
  if (any(grepl("_Other$",names(data))))
  {
    colOther<-grep("_Other$",names(data))
    varOther<-data[[colOther]]
    data[varOther!="",colOther]<-"1"
  }
  
  ## Create helping columns
  colSpe<-grep("_(Unsure|Not applicable|No(ne.*| intervention)?)",names(data))
  colData<-grep("_(Unsure|Not applicable|No(ne.*| intervention)?)",names(data[-(1:3)]),invert=T)+3
  sumSpe<-apply(data[colSpe],1,function(x){sum(as.integer(x),na.rm=T)})
  sumData<-apply(data[colData],1,function(x){sum(as.integer(x),na.rm=T)})
  
  ## Replace noise with empty data
  # Multiple special (No/Unsure/Not applicable) columns checked at the same time
  data[sumSpe>1,colData]<-""
  # Data column(s) and special column(s) checked at the same time
  data[sumData>0 & sumSpe>0,colData]<-""
    
  ## Only one special column checked
  for (col in colSpe)
    data[data[col]=="1",col]<-gsub("\\."," ",sub(".*_([^_]+)$","\\1",names(data[col])))
  
  varSpe<-apply(data[colSpe],1,paste,collapse="")
  varSpe<-sub("No(ne.*| intervention)?","No",varSpe)
  data[sumSpe==1 & sumData==0,colData]<-varSpe[sumSpe==1 & sumData==0]
  
  ## Normal case
  for (col in colData)
      data[sumData>0 & sumSpe==0,col]<-ifelse(data[sumData>0 & sumSpe==0,col]=="1","Yes","No")
    
  ## Re-fill "Other" columns with its values
  if (any(grepl("_Other$",names(data))))
    data[data[colOther]=="Yes",colOther]<-varOther[data[colOther]=="Yes"]
  
  ## Remove special columns
  select(data,-matches("_(Unsure|Not applicable|No(ne.*| intervention)?)"))
}