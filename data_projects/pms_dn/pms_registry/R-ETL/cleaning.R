source("functions-mapping.R")
source("functions-loading.R")
source("functions-genes.R")
source("process.R")

# ==== Read raw data files ====
adult         <- read.csv.2header("dataAdult.csv")
developmental <- read.csv.2header("dataDevelopmental.csv")
clinical      <- read.csv.2header("dataClinical.csv")

# Delete rows with no Survey Session ID
adult         <- adult[adult$Survey.Session.ID != "", ]
developmental <- developmental[developmental$Survey.Session.ID != "", ]
clinical      <- clinical[clinical$Survey.Session.ID != "", ]

# ==== Create dir for output, create empty mapping file and ontology object
dir.create("output", recursive = T)
cat("Filename\tCategory Code\tColumn Number\tData Label\n", file = "output/mapping.txt")
ontology <- character(0)

# ==== Demographics ====

# Extract basic demographic informations (patient ID, SEX, AGE, RACE, COUNTRY)
export_date = as.Date("2015-03-20")

adult[                    c("Patient.ID", "Birthdate", "Gender", "Ancestral.Background", "Country")] %>%
  bind_rows(clinical[     c("Patient.ID", "Birthdate", "Gender", "Ancestral.Background", "Country")]) %>%
  bind_rows(developmental[c("Patient.ID", "Birthdate", "Gender", "Ancestral.Background", "Country")]) %>%
  unique() %>%
  arrange(Patient.ID) %>%
  group_by(Patient.ID) %>%
  mutate(Birthdate = as.Date(Birthdate)) %>%
  mutate(Age = as.numeric(export_date - Birthdate) / 365.25) %>%
  mutate(Age_months = Age * 12) -> Demographics

# Write Demographics.txt
write.table(Demographics, "output/Demographics.txt", row.names = F, sep = "\t", quote = F)

# Write the mappings
ontology <- push(ontology, "Demographics")
  addMapping("Demographics.txt", ontology, 1, "SUBJ_ID")
  addMapping("Demographics.txt", ontology, 2, "BIRTHDATE")
  addMapping("Demographics.txt", ontology, 3, "SEX")
  addMapping("Demographics.txt", ontology, 4, "RACE")
  addMapping("Demographics.txt", ontology, 5, "COUNTRY")
  addMapping("Demographics.txt", ontology, 6, "AGE_IN_YEARS")
  addMapping("Demographics.txt", ontology, 7, "AGE")
ontology <- pop(ontology)

# ==== Genetic information ====
# Extract the information to an external file
# clinical[c(1,5,19:67)] %>%
#   mutate(Test.Date=gsub("/","-",Test.Date,perl=T)) %>%
#   mutate(Test.Date=gsub("^(\\d)-","0\\1-",Test.Date,perl=T)) %>%
#   mutate(Test.Date=gsub("-(\\d)-","-0\\1-",Test.Date,perl=T)) %>%
#   mutate(Test.Date=gsub("-(\\d{2})$","-20\\1",Test.Date,perl=T)) %>%
#   mutate(Test.Date=gsub("(^\\d{2}-\\d{4}$)","01-\\1",Test.Date,perl=T)) %>%
#   mutate(Test.Date=gsub("^[\\w ]+$","",Test.Date,perl=T)) %>%
#   mutate(Test.Date=as.Date(Test.Date,format="%m-%d-%Y")) %>%
#   arrange(Patient.ID,Test.Date) %>%
#   distinct -> Genetics
# write.csv(Genetics,"Genetics.csv")

###############################################
###############################################
### MANUALLY PROCESS THE FILE IF NEEDED !!! ###
###############################################
###############################################

# Read back the curated genetic data
Genetics_raw <- read.csv("Genetics.csv", stringsAsFactors = F)

# Read refGene position tables for all genome assemblies
hg17 <- read.delim("refGene.txt.hg17", stringsAsFactors = F)
hg18 <- read.delim("refGene.txt.hg18", stringsAsFactors = F)
hg19 <- read.delim("refGene.txt.hg19", stringsAsFactors = F)
hg38 <- read.delim("refGene.txt.hg38", stringsAsFactors = F)

# Call liftOver tool to translate chromosomic coordinates to a common genome build and set aside (not delete) original coordinates
Genetics_raw <- liftOver(Genetics_raw)

# Get a list of all involved genes
genes <- getGeneNames(Genetics_raw)

# Create the data frame to hold the annotated genetic data
Genetics <- data_frame(Patient.ID = unique(Genetics_raw$Patient.ID))
for (gene in genes)
  Genetics[[gene]] <- 2

# Extract the information from the raw genetic test reports into the data frame
Genetics <- extractGenes(Genetics_raw, Genetics)

# Get gene status from table browser using original genome assembly


# ==== Phenotypic information ====
processFile("Clinical")
processFile("Adult")
processFile("Developmental")
