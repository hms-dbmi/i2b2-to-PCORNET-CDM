source("functions.R")

processHead1<-function(head1,data,premap)
{
  ##
  #head1<-"Has the patient been tested for any of the following conditions?"
  ##
  
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
  # Update indexes in the premap
  premap<-mutate(premap,ColNum=ColNum+(idx2-idx1))
  # Filter columns in data based on the updated index
  data<-data[c(1:3,premap$ColNum)]
  
  # Delete records made less than 24 hours before the next
  data$Survey.Date<-as.numeric(strptime(data$Survey.Date,format="%Y-%m-%d %H:%M:%S"))
  data<-filter(data,(lead(Survey.Date)-Survey.Date)>24*3600 | lead(Patient.ID)!=Patient.ID | Patient.ID==max(Patient.ID))
  data<-select(data,-Survey.Date)
  
  # Filter for the last line of data for each patient
  # TODO : filter for the last line with data ?
  # TODO : take account of DemoEvo to modify behavior
  data<-data %>%
    group_by(Patient.ID) %>%
    filter(row_number(desc(Survey.Session.ID))==1)
  
  # Create new data frame to contain transformed/curated data
  data2<-select(data,Patient.ID)
  
  # Reformating needed
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
  else
  {
    data2<-select(data,-Survey.Session.ID)
  }
  
  data2
}

processSubfile<-function(filename,subfile,data,premap)
{
  premap<-filter(premap,SubFile==subfile)
  
  # Create new data frame to contain transformed/curated data
  data2<-data["Patient.ID"]
  data2<-data2 %>% distinct()
  
  for (head1 in unique(premap$Head1))
  {
    data2<-merge(data2,processHead1(head1,data,premap),by="Patient.ID")
  }
  
  ontology<<-push(ontology,subfile)
  
  addMapping(paste0("output/",filename),paste0(subfile,".txt"),ontology,1,"SUBJ_ID")
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
    
    addMapping(paste0("output/",filename),paste0(subfile,".txt"),ontology,varNum,varName)
    
    while(ontoLevel>0)
    {
      ontoLevel<-ontoLevel-1
      ontology<<-pop(ontology)
    }
    
    varNum<-varNum+1
  }
  
  ontology<<-pop(ontology)
  
  write.table(data2,file=paste0("output/",filename,"/",subfile,".txt"),row.names=F,sep="\t",quote=F)
}

processFile<-function(filename)
{
  # Create dir for output, create empty mapping file and ontology object
  dir.create(paste0("output/",filename),recursive=T)
  cat("Filename\tCategory Code\tColumn Number\tData Label\n",file = paste0("output/",filename,"/mapping.txt"))
  ontology<-c("PMS DN new ETL","PMS Ontology",filename)
  
  data<-read.csv.2header(paste0("data",filename,".csv"))
  data<-data[!is.na(adult$Survey.Session.ID),]
  
  premap<-read.csv(paste0("premap",filename,".csv"),stringsAsFactors=F)
  
  for (subfile in levels(factor(premap$SubFile,exclude="")))
  {
    processSubfile(filename,subfile,data,premap)
  }
}
