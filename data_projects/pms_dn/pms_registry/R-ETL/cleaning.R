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

# Create dir for output, create empty mapping file and ontology object
dir.create("output")
cat("Filename\tCategory Code\tColumn Number\tData Label\n",file = "output/mapping.txt")
ontology<-c("PMS DN","PMS Ontology")

# ==== Extract basic demographic informations (patient ID, SEX, AGE, RACE, COUNTRY) ====
adult[c("Patient.ID","Birthdate","Gender","Ancestral.Background","Country")] %>%
  bind_rows(clinical[c("Patient.ID","Birthdate","Gender","Ancestral.Background","Country")]) %>%
  bind_rows(developmental[c("Patient.ID","Birthdate","Gender")]) %>%
  unique() %>%
  arrange(Patient.ID) %>%
  group_by(Patient.ID) %>%
  filter(!is.na(Ancestral.Background)) %>%
  filter(!is.na(Country)) %>%
  mutate(Birthdate = as.Date(Birthdate,format="%m/%d/%Y")) %>%
  mutate(Age = as.numeric(Sys.Date() - Birthdate)/365.25) %>%
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
processFile(clinical,"premapClinical.csv")
#processFile(adult,"premapAdult.csv")
#processFile(developmental,"premapDevelopmental.csv")