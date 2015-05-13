source("functions-genes.R")
source("process.R")

export_date = as.Date("2015-03-20")

# Create dir for output, create empty mapping file and ontology object
dir.create("output", recursive = T)
cat("Filename\tCategory Code\tColumn Number\tData Label\n", file = "output/mapping.txt")
ontology <- character(0)

# ==== Demographics ====
processDemographics()

# ==== Phenotypic information ====
processFile("Clinical")
processFile("Adult")
processFile("Developmental")

# ==== Genetic information ====
# Extract the information to an external file
# clinical      <- read.csv.2header("dataClinical.csv")
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

# Download external files
#downloadKEGGFiles()
#downloadRefGeneFiles()
#downloadLiftOverFiles()

# Read back the curated genetic data
Genetics <- read.csv("Genetics.csv", stringsAsFactors = F)

# Read refGene position tables for all genome assemblies
hg17 <- read.delim("refGene.txt.hg17", stringsAsFactors = F)
hg18 <- read.delim("refGene.txt.hg18", stringsAsFactors = F)
hg19 <- read.delim("refGene.txt.hg19", stringsAsFactors = F)
hg38 <- read.delim("refGene.txt.hg38", stringsAsFactors = F)

# ==== Deletions ====
Genetics_deletions <- filter(Genetics, Gain.Loss == "Loss", Chr.Gene == "22") %>% select(Patient.ID, Genome.Browser.Build, Start, End)

# Call liftOver tool to translate chromosomic coordinates to a common genome build and set aside (not delete) original coordinates
Genetics_deletions <- liftOver(Genetics_deletions)

# Get a list of all involved genes
genes <- getGeneNames(Genetics_raw)

# Enrich genes with pathways annotation
genes <- getPathways(genes)

# Create the data frame to hold the annotated genetic data
Genetics_genes <- data_frame(Patient.ID = unique(Genetics_raw$Patient.ID))
for (gene in genes$genes)
  Genetics_genes[[gene]] <- 2

# Extract the information from the raw genetic test reports into the data frame
Genetics_genes <- extractGenes(Genetics_raw, Genetics_genes)

# Genes modified in at least 5 patients
which(apply(Genetics_genes, 2, function(x){summary(factor(x))["2"] <= nrow(Genetics_genes) - 5}))