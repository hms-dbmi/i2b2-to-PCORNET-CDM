library(dplyr)
library(tidyr)

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

# Reformat function to refactor spread pieces of data
refactor<-function(data,premap)
{
  # Create new data frame to contain transformed/curated data
  data2<-select(data,Patient.ID,Survey.Date,Birthdate)
  
  # new vars prefix
  varPre<-levels(factor(unlist(data[premap$Header[premap$Reformat=="refactor"]]),exclude=c("","No")))
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
      pre<-data[row,premap$Header[premap$Linked==link & premap$Reformat=="refactor"]]
      if (pre=="" | pre=="No")
        next
      for (suff in varSuff)
      {
        if (premap$Reformat[premap$Linked==link & premap$VarName==suff]=="refactor")
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

# Copy content of "Other.Value" into either "Other" column or variable
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

# Fill missing values in checkbox-type variables
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
