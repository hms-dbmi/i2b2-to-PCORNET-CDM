source("functions-process.R")

export_date = as.Date("2015-07-27")

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