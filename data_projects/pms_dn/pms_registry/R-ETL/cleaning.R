source("functions.R")
source("process.R")

# ==== Read raw data files ====
adult<-read.csv.2header("dataAdult.csv")
developmental<-read.csv.2header("dataDevelopmental.csv")
clinical<-read.csv.2header("dataClinical.csv")

# Delete rows with no SurveySessionID
adult <- adult[!is.na(adult$Survey.Session.ID),]
developmental <- developmental[!is.na(developmental$Survey.Session.ID),]
clinical <- clinical[!is.na(clinical$Survey.Session.ID),]

# ==== Demographics ====

# Create dir for output, create empty mapping file and ontology object
dir.create("output",recursive=T)
cat("Filename\tCategory Code\tColumn Number\tData Label\n",file = "output/mapping.txt")
ontology<-c("DBMI","PMS_DN","01 PMS Registry (Patient Reported Outcomes)","01 PMS Patient Reported Outcomes")

# Extract basic demographic informations (patient ID, SEX, AGE, RACE, COUNTRY)
export_date=as.Date("2015-03-20")

adult[c("Patient.ID","Birthdate","Gender","Ancestral.Background","Country")] %>%
  bind_rows(clinical[c("Patient.ID","Birthdate","Gender","Ancestral.Background","Country")]) %>%
  bind_rows(developmental[c("Patient.ID","Birthdate","Gender","Ancestral.Background","Country")]) %>%
  unique() %>%
  arrange(Patient.ID) %>%
  group_by(Patient.ID) %>%
  mutate(Birthdate = as.Date(Birthdate)) %>%
  mutate(Age = as.numeric(export_date - Birthdate)/365.25) %>%
  select(-Birthdate) -> Demographics

write.table(Demographics,"output/Demographics.txt",row.names = F,sep="\t",quote=F)
ontology<-push(ontology,"Demographics")
  addMapping("Demographics.txt",ontology,1,"SUBJ_ID")
  addMapping("Demographics.txt",ontology,2,"SEX")
  addMapping("Demographics.txt",ontology,3,"RACE")
  addMapping("Demographics.txt",ontology,4,"COUNTRY")
  addMapping("Demographics.txt",ontology,5,"AGE")
ontology<-pop(ontology)

# ==== Genetic information ====


# ==== Phenotypic information ====
processFile("Clinical")
processFile("Adult")
processFile("Developmental")
