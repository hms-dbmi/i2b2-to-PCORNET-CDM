source("functions-loading.R")
source("functions-mapping.R")
source("functions-reformatting.R")
source("functions-genes.R")

# Process at the file level
processFile <- function(questionnaire, noOutput = F)
{
  # Add the questionnaire level to the ontology
  if (!noOutput)
    ontology <<- push(ontology, questionnaire)

  # Read the data and premapping files
  data <- read.csv.2header(paste0("data", questionnaire, ".csv"))
  data <- data[data$Survey.Session.ID != "", ]

  premap <- read.csv(paste0("premap", questionnaire, ".csv"), stringsAsFactors = F, colClasses = "character")
  premap$ColNum <- as.integer(premap$ColNum)

  data2 <- data["Patient.ID"] %>% distinct()

  # Process each SubFile level (excluding the empty SubFile level->Demographics)
  for (subfile in levels(factor(premap$SubFile, exclude = "")))
    data2 <- merge(data2, processSubfile(questionnaire, subfile, data, premap, noOutput = noOutput), by = "Patient.ID")

  if (!noOutput)
    ontology <<- pop(ontology)

  if (noOutput)
    return(data2)
}

# Process at the SubFile level
processSubfile <- function(questionnaire, subfile, data, premap, noOutput)
{
  # Add the SubFile level to the ontology
  if (!noOutput)
    ontology <<- push(ontology, subfile)

  # Subset the premapping file with only the current SubFile
  premap <- filter(premap, SubFile == subfile)

  # Create new data frame to contain transformed/curated data
  data2 <- data["Patient.ID"] %>% distinct()

  # Process each Head1 level and merge resulting data
  for (head1 in unique(premap$Head1))
    data2 <- merge(data2, processHead1(head1, data, premap), by = "Patient.ID")

  # Parse resulting var names and write mappings
  if (!noOutput)
  {
    addMappings(questionnaire, subfile, ontology, data2)

    # Write the $SubFile.txt
    write.table(data2, file = paste0("output/", questionnaire, "-", subfile, ".txt"), row.names = F, sep = "\t", quote = F, na = "")

    ontology <<- pop(ontology)
  }

  data2
}

# Process at the Head1 level
processHead1 <- function(head1, data, premap)
{
  # Subset the premapping file with only the current Head1
  premap <- filter(premap, Head1 == head1)

  # Anchor-based filtering of variables from the data file
  data <- anchorFilter(premap, data)

  # Sort by Survey Date
  data$Survey.Date <- as.numeric(strptime(data$Survey.Date, format = "%Y-%m-%d %H:%M:%S"))
  data <- arrange(data, Patient.ID, Survey.Date)

  # Delete records made less than 24 hours before the next
  data <- filter(data, (lead(Survey.Date) - Survey.Date) > 24 * 3600 | lead(Patient.ID) != Patient.ID | Patient.ID == max(Patient.ID))

 # Reformatting needed. Execute the function given in the premap file for the reformatting
  if (any(premap$Reformat != ""))
  {
    funcname <- levels(factor(premap$Reformat, exclude = ""))
    eval(parse(text = paste0("data <- ", funcname, "(data, premap)")))
  }

  # Manage 'Other Value' columns
  if (any(grepl("_Other.Value$", names(data))))
    data <- otherValue(data)

  # Manage "checkbox" items
  if (any(grepl("_Unsure$", names(data))))
    data <- checkboxes(data)

  # Manage longitudinal data
  if (any(premap$Evo == "1"))
    data <- evolutive(data)
  else
    data <- historical(data)

  data
}

processDemographics <- function(noOutput = F)
{
  # Read raw data files
  adult         <- read.csv.2header("dataAdult.csv")
  developmental <- read.csv.2header("dataDevelopmental.csv")
  clinical      <- read.csv.2header("dataClinical.csv")

  # Delete rows with no Survey Session ID
  adult         <- adult[adult$Survey.Session.ID != "", ]
  developmental <- developmental[developmental$Survey.Session.ID != "", ]
  clinical      <- clinical[clinical$Survey.Session.ID != "", ]

  # Extract basic demographic informations (patient ID, SEX, AGE, RACE, COUNTRY)
  adult[                    c("Patient.ID", "Birthdate", "Gender", "Ancestral.Background", "Country")] %>%
    bind_rows(clinical[     c("Patient.ID", "Birthdate", "Gender", "Ancestral.Background", "Country")]) %>%
    bind_rows(developmental[c("Patient.ID", "Birthdate", "Gender", "Ancestral.Background", "Country")]) %>%
    unique() %>%
    arrange(Patient.ID) %>%
    group_by(Patient.ID) %>%
    mutate(Birthdate = as.Date(Birthdate)) %>%
    mutate(Age = as.numeric(export_date - Birthdate) / 365.25) %>%
    mutate(Age_months = Age * 12) -> Demographics

  if (!noOutput)
  {
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
  }

  if (noOutput)
    return(Demographics)
}

processGenes <- function(genetics)
{
  # Get a list of all involved genes
  genes <- getGeneNames(genetics)

  # Create the data frame to hold the annotated genetic data
  Genetics_genes <- data_frame(Patient.ID = unique(genetics$Patient.ID))
  Demographics <- processDemographics(noOutput = T)
  Demographics$Patient.ID <- as.numeric(Demographics$Patient.ID)
  Genetics_genes <- left_join(Genetics_genes, Demographics[c("Patient.ID", "Gender")])
  for (gene in genes$name)
  {
    if (genes$chrom[genes$name == gene] == "Y")
    {
      Genetics_genes[[gene]][Genetics_genes$Gender == "Male"] <- 1
      Genetics_genes[[gene]][Genetics_genes$Gender == "Female"] <- 0
    }
    else if (genes$chrom[genes$name == gene] == "X")
    {
      Genetics_genes[[gene]][Genetics_genes$Gender == "Male"] <- 1
      Genetics_genes[[gene]][Genetics_genes$Gender == "Female"] <- 2
    }
    else
      Genetics_genes[[gene]] <- 2
  }

  # Extract the information from the raw genetic test reports into the data frame
  Genetics_genes <- extractGenes(genetics, Genetics_genes)

  Genetics_genes
}

processRanges <- function(genetics)
{
  genetics <- select(genetics, Patient.ID, Genome.Browser.Build, Result.type, Gain.Loss, Chr.Gene, Start, End)
  for (i in 1:nrow(genetics))
  {
    if (genetics$Result.type[i] == "gene")
    {
      genetics$Genome.Browser.Build[i] <- "GRCh38/hg38"
      genetics$Start[i]                <-                hg38$txStart[hg38$name2 == genetics$Chr.Gene[i]][1]
      genetics$End[i]                  <-                hg38$txEnd  [hg38$name2 == genetics$Chr.Gene[i]][1]
      genetics$Chr.Gene[i]             <- sub("chr", "", hg38$chrom  [hg38$name2 == genetics$Chr.Gene[i]][1])
    }
    else if (genetics$Result.type[i] == "mutation")
    {
      genetics$Genome.Browser.Build[i] <- "GRCh38/hg38"
      genetics$Start[i]                <- genetics$Start[i] + hg38$txStart[hg38$name2 == genetics$Chr.Gene[i]][1]
      genetics$End[i]                  <- genetics$End[i]   + hg38$txStart[hg38$name2 == genetics$Chr.Gene[i]][1]
      genetics$Chr.Gene[i]             <- sub("chr", "", hg38$chrom  [hg38$name2 == genetics$Chr.Gene[i]][1])
    }
  }

  liftOver(genetics)
}