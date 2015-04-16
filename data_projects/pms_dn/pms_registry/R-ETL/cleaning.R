source("functions-mapping.R")
source("functions-loading.R")
source("process.R")

# ==== Read raw data files ====
adult<-read.csv.2header("dataAdult.csv")
developmental<-read.csv.2header("dataDevelopmental.csv")
clinical<-read.csv.2header("dataClinical.csv")

# Delete rows with no Survey Session ID
adult <- adult[adult$Survey.Session.ID!="",]
developmental <- developmental[developmental$Survey.Session.ID!="",]
clinical <- clinical[clinical$Survey.Session.ID!="",]

# ==== Create dir for output, create empty mapping file and ontology object
dir.create("output",recursive=T)
cat("Filename\tCategory Code\tColumn Number\tData Label\n",file = "output/mapping.txt")
ontology<-character(0)

# ==== Demographics ====

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
  mutate(Age_months = Age*12) -> Demographics

# Write Demographics.txt
write.table(Demographics,"output/Demographics.txt",row.names = F,sep="\t",quote=F)

# Write the mappings
ontology<-push(ontology,"Demographics")
  addMapping("Demographics.txt",ontology,1,"SUBJ_ID")
  addMapping("Demographics.txt",ontology,2,"BIRTHDATE")
  addMapping("Demographics.txt",ontology,3,"SEX")
  addMapping("Demographics.txt",ontology,4,"RACE")
  addMapping("Demographics.txt",ontology,5,"COUNTRY")
  addMapping("Demographics.txt",ontology,6,"AGE_IN_YEARS")
  addMapping("Demographics.txt",ontology,7,"AGE")
ontology<-pop(ontology)

# ==== Genetic information ====




# ==== Phenotypic information ====
processFile("Clinical")
processFile("Adult")
processFile("Developmental")
