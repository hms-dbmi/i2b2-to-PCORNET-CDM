library(dplyr)
library(tidyr)

# Anchor-based filtering of data from the mapping file
anchorFilter <- function(premap,data)
{
  # Find the index of the first variable by name in the data file
  idx1 <- premap$ColNum[1] #premap's index of the variable
  idx2 <- which(names(data) == premap$Header[1]) #data's index of the variable
  # Throw a warning if variable not found in the data
  if (length(idx2) == 0)
  {
    warning("Variable not found: \"", premap$Header[1], "\" in data file at ontology level \"", paste(ontology, collapse = "+"), "\"")
    return()
  }
  # If real homonyms at first position of head1, use an heuristic (pick the nearest one in position)
  if (length(idx2) > 1)
    idx2 <- idx2[order(abs(idx2 - idx1))[1]]

  # Update indexes in the premap
  premap <- mutate(premap, ColNum = ColNum + (idx2 - idx1))

  # Filter columns in data based on the updated index
  data[c(which(names(data) %in% c("Patient.ID", "Survey.Date", "Birthdate")), premap$ColNum)]
}

# Reformat function to refactor spread pieces of data
refactor <- function(data, premap)
{
  # Create new data frame to contain transformed/curated data
  data2 <- select(data, Patient.ID, Survey.Date, Birthdate)

  # new vars prefix
  varPre <- levels(factor(unlist(data[premap$Header[premap$Reformat == "refactor"]]), exclude = c("", "No")))
  # new vars suffix
  varSuff <- levels(factor(premap$VarName[premap$Linked != ""]))
  # Create new vars after transform
  for (pre in varPre)
    for (suff in varSuff)
      data2[[paste(pre, suff, sep = "_")]] <- NA

  #Effectively reformat the variable, keeping linked variables together
  for (row in 1:nrow(data2))
  {
    for (link in levels(factor(premap$Linked, exclude = "")))
    {
      pre <- data[row, premap$Header[premap$Linked == link & premap$Reformat == "refactor"]]
      if (pre == "" | pre == "No")
        next
      for (suff in varSuff)
      {
        if (premap$Reformat[premap$Linked == link & premap$VarName == suff] == "refactor")
        {
          data2[row, paste(pre, suff, sep = "_")] <- "Yes"
        }
        else
        {
          data2[row, paste(pre, suff, sep = "_")] <- data[row, premap$Header[premap$Linked == link & premap$VarName == suff]]
        }
      }
    }
  }

  # Rename variables
  for (varName in names(data2))
    data2[[varName]] <- unlist(data2[[varName]])

  varnames <- names(data2)
  varnames[-(1:3)] <- paste(premap$Head1[1], varnames[-(1:3)], sep = "_")
  varnames <- gsub("^_", "", varnames)

  colnames(data2) <- varnames

  data2
}

weight <- function(data, premap)
{
  weight_map <- matrix(c(
    "1 - 5 lbs",     "0.45 - 2.27 kg",
    "5 - 9 lbs",     "2.27 - 4.08 kg",
    "10 - 14 lbs",   "4.54 - 6.35 kg",
    "15 - 19 lbs",   "6.80 - 8.62 kg",
    "20 - 24 lbs",   "9.07 - 10.89 kg",
    "25 - 29 lbs",   "11.34 - 13.15 kg",
    "30 - 34 lbs",   "13.60 - 15.42 kg",
    "35 - 39 lbs",   "15.88 - 17.69 kg",
    "40 - 44 lbs",   "18.14 - 19.96 kg",
    "45 - 49 lbs",   "20.41 - 22.23 kg",
    "50 - 55 lbs",   "22.68 - 24.95 kg",
    "56 - 59 lbs",   "25.40 - 26.76 kg",
    "60 - 64 lbs",   "27.22 - 29.03 kg",
    "65 - 69 lbs",   "29.48 - 31.30 kg",
    "70 - 74 lbs",   "31.75 - 33.57 kg",
    "75 - 79 lbs",   "34.02 - 35.83 kg",
    "80 - 84 lbs",   "36.29 - 38.10 kg",
    "85 - 89 lbs",   "38.56 - 40.37 kg",
    "90 - 94 lbs",   "40.82 - 42.64 kg",
    "95 - 99 lbs",   "43.09 - 44.91kg",
    "100 - 109 lbs", "45.36 - 49.44 kg",
    "110 - 119 lbs", "49.9 - 53.98 kg",
    "120 - 129 lbs", "54.43 - 58.51 kg",
    "130 - 139 lbs", "58.97 - 63.05 kg",
    "140 - 149 lbs", "63.5 - 67.59 kg",
    "150 - 159 lbs", "68.04 - 72.12 kg",
    "160 - 169 lbs", "72.57 - 76.66 kg",
    "170 - 179 lbs", "77.11 - 81.19 kg",
    "180 - 189 lbs", "81.65 - 85.73 kg",
    "190 - 199 lbs", "86.18 - 90.26 kg",
    "200 + lbs",     "91 kg or more"),ncol = 2, byrow = T)

  # Create new data frame to contain transformed/curated data
  data2 <- select(data, Patient.ID, Survey.Date, Birthdate)

  # Create new var
  varname <- unique(premap$Head1)
  pounds    <- data[[premap$Header[grepl("Pounds$",    premap$Head2)]]]
  kilograms <- data[[premap$Header[grepl("Kilograms$", premap$Head2)]]]
  data2[[varname]] <- kilograms

  for (row in 1:nrow(data2))
    if ((kilograms[row] == "") & (pounds[row] != ""))
      data2[row, varname] <- weight_map[which(weight_map == pounds[row]), 2]

  data2
}

height <- function(data, premap)
{
  conv_foot <- 30.48
  conv_inch <- 2.54

  # Create new data frame to contain transformed/curated data
  data2 <- select(data, Patient.ID, Survey.Date, Birthdate)

  # Create new var
  data2[[premap$Head1]] <- NA

  data2
}

head_circum <- function(data, premap)
{
  head_circum_map <- matrix(c(
    "10 inches",    "25.4",
    "10.25 inches", "26.04",
    "10.50 inches", "26.67",
    "10.75 inches", "27.31",
    "11 inches",    "27.94",
    "11.25 inches", "28.58",
    "11.50 inches", "29.21",
    "11.75 inches", "29.85",
    "12 inches",    "30.48",
    "12.25 inches", "31.12",
    "12.50 inches", "31.75",
    "12.75 inches", "32.39",
    "13 inches",    "33.02",
    "13.25 inches", "33.66",
    "13.50 inches", "34.29",
    "13.75 inches", "34.93",
    "14 inches",    "35.56",
    "14.25 inches", "36.2",
    "14.50 inches", "36.83",
    "14.75 inches", "37.47",
    "15 inches",    "38.1",
    "15.25 inches", "38.74",
    "15.50 inches", "39.37",
    "15.75 inches", "40.01",
    "16 inches",    "40.64",
    "16.25 inches", "41.28",
    "16.50 inches", "41.91",
    "16.75 inches", "42.55",
    "17 inches",    "43.18",
    "17.25 inches", "43.82",
    "17.50 inches", "44.45",
    "17.75 inches", "45.09",
    "18 inches",    "45.72",
    "18.25 inches", "46.36",
    "18.50 inches", "46.99",
    "18.75 inches", "47.63",
    "19 inches",    "48.26",
    "19.25 inches", "48.9",
    "19.50 inches", "49.53",
    "19.75 inches", "50.17",
    "20 inches",    "50.8",
    "20.25 inches", "51.44",
    "20.50 inches", "52.07",
    "20.75 inches", "52.71",
    "21 inches",    "53.34",
    "21.25 inches", "53.98",
    "21.50 inches", "54.61",
    "21.75 inches", "55.25",
    "22 inches",    "55.88",
    "22.25 inches", "56.52",
    "22.50 inches", "57.15",
    "22.75 inches", "57.79",
    "23 inches",    "58.42",
    "23.25 inches", "59.06",
    "23.50 inches", "59.69",
    "23.75 inches", "60.33",
    "24 inches",    "60.96",
    "24.25 inches", "61.6",
    "24.50 inches", "62.23",
    "24.75 inches", "62.87",
    "25 inches",    "63.5",
    "25.25 inches", "64.14",
    "25.50 inches", "64.77",
    "25.75 inches", "65.41",
    "26 inches",    "66.04",
    "26.25 inches", "66.68",
    "26.50 inches", "67.31",
    "26.75 inches", "67.95",
    "27 inches",    "68.58",
    "27.25 inches", "69.22",
    "27.50 inches", "69.85",
    "27.75 inches", "70.49",
    "28 inches",    "71.12",
    "28.25 inches", "71.76",
    "28.50 inches", "72.39",
    "28.75 inches", "73.03",
    "29 inches",    "73.66",
    "29.25 inches", "74.3",
    "29.50 inches", "74.93",
    "29.75 inches", "75.67",
    "30 inches +",  "76.20 +"), ncol = 2, byrow = T)

  # Create new data frame to contain transformed/curated data
  data2 <- select(data, Patient.ID, Survey.Date, Birthdate)

  # Create new var
  varname <- unique(premap$Head1)
  inches      <- data[[premap$Header[grepl("Inches$",      premap$Head2)]]]
  centimeters <- data[[premap$Header[grepl("Centimeters$", premap$Head2)]]]
  data2[[varname]] <- centimeters

  for (row in 1:nrow(data2))
    if ((centimeters[row] == "") & (inches[row] != ""))
      data2[row, varname] <- head_circum_map[which(head_circum_map == inches[row]), 2]

  data2
}

weight_neo <- function(data, premap)
{
  weight_neo_map <- matrix(c(
    "0 lb",   "0 kg",
    "1 lb",   "0.45 kg",
    "2 lbs",  "0.91 kg",
    "3 lbs",  "1.36 kg",
    "4 lbs",  "1.81 kg",
    "5 lbs",  "2.27 kg",
    "6 lbs",  "2.72 kg",
    "7 lbs",  "3.18 kg",
    "8 lbs",  "3.63 kg",
    "9 lbs",  "4.08 kg",
    "10 lbs", "4.54 kg",
    "11 lbs", "4.99 kg",
    "12 lbs", "5.44 kg",
    "More than 12 lbs",	"More than 5.44 kg"), ncol = 2, byrow = T)

  # Create new data frame to contain transformed/curated data
  data2 <- select(data, Patient.ID, Survey.Date, Birthdate)

  # Create new var
  varname <- unique(premap$Head1)
  pounds    <- data[[premap$Header[grepl("Pounds$",    premap$Head2)]]]
  kilograms <- data[[premap$Header[grepl("Kilograms$", premap$Head2)]]]
  data2[[varname]] <- kilograms

  for (row in 1:nrow(data2))
    if ((kilograms[row] == "") & (pounds[row] != ""))
      data2[row, varname] <- weight_neo_map[which(weight_neo_map == pounds[row]), 2]

  data2
}

height_neo <- function(data, premap)
{
  height_neo_map <- matrix(c(
    "10 inches",    "25.40",
    "10.25 inches", "26.04",
    "10.50 inches", "26.67",
    "10.75 inches", "27.31",
    "11 inches",    "27.94",
    "11.25 inches", "28.58",
    "11.50 inches", "29.21",
    "11.75 inches", "29.85",
    "12 inches",    "30.48",
    "12.25 inches", "31.12",
    "12.50 inches", "31.75",
    "12.75 inches", "32.39",
    "13 inches",    "33.02",
    "13.25 inches", "33.66",
    "13.50 inches", "34.29",
    "13.75 inches", "34.93",
    "14 inches",    "35.56",
    "14.25inches",  "36.20",
    "14.50 inches", "36.83",
    "14.75 inches", "37.47",
    "15 inches",    "38.10",
    "15.25 inches", "38.74",
    "15.50 inches", "39.37",
    "15.75 inches", "40.01",
    "16 inches",    "40.64",
    "16.25 inches", "41.28",
    "16.50 inches", "41.91",
    "16.75 inches", "42.55",
    "17 inches",    "43.18",
    "17.25 inches", "43.82",
    "17.50 inches", "44.45",
    "17.75 inches", "45.09",
    "18 inches",    "45.72",
    "18.25 inches", "46.36",
    "18.50 inches", "46.99",
    "18.75 inches", "47.63",
    "19 inches",    "48.26",
    "19.25 inches", "48.90",
    "19.50 inches", "49.53",
    "19.75 inches", "50.17",
    "20 inches",    "50.80",
    "20.25 inches", "51.44",
    "20.50 inches", "52.07",
    "20.75 inches", "52.71",
    "21 inches",    "53.34",
    "21.25 inches", "53.98",
    "21.50 inches", "54.61",
    "21.75 inches", "55.25",
    "22 inches",    "55.88",
    "22.25 inches", "56.52",
    "22.50 inches", "57.15",
    "22.75 inches", "57.79",
    "23 inches",    "58.42",
    "23.25 inches", "59.06",
    "23.50 inches", "59.69",
    "23.75 inches", "60.33",
    "24 inches",    "60.96",
    "24.25 inches", "61.60",
    "24.50 inches", "62.23",
    "24.75 inches", "62.87",
    "25 inches",    "63.50",
    "25.25 inches", "64.14",
    "25.50 inches", "64.77",
    "25.75 inches", "65.41",
    "Greater than 25.75 inches", "Greater than 65.41 centimeters"), ncol = 2, byrow = T)

  # Create new data frame to contain transformed/curated data
  data2 <- select(data, Patient.ID, Survey.Date, Birthdate)

  # Create new var
  data2[[premap$Head1]] <- NA

  data2
}

# Copy content of "Other.Value" into either "Other" column or variable
otherValue <- function(data)
{
  colOtherValue <- grep("_Other.Value$", names(data))

  if (any(grepl("_Other$", names(data)))) # When there is an 'Other' column
  {
    colOther <- grep("_Other$", names(data))
    data[data[colOther] == "1", colOther] <- data[data[colOther] == "1", colOtherValue]
  }
  else if (length(data) == 5) # When there are only two columns (+3 for Patient.ID,Survey.Date,Birthdate)
  {
    colOther <- grep("_Other.Value", names(data[-(1:3)]), invert = T) + 3
    data[data[colOther] == "Other", colOther] <- data[data[colOther] == "Other", colOtherValue]
  }

  select(data, -ends_with("_Other.Value"))
}

# Fill missing values in checkbox-type variables
checkboxes <- function(data)
{
  ## Set "_Other" column aside
  if (any(grepl("_Other$", names(data))))
  {
    colOther <- grep("_Other$", names(data))
    varOther <- data[[colOther]]
    data[varOther != "", colOther] <- "1"
  }

  ## Create helping columns
  colSpe  <- grep("_(Unsure|Not applicable|No(ne.*| intervention)?)", names(data))
  colData <- grep("_(Unsure|Not applicable|No(ne.*| intervention)?)", names(data[-(1:3)]), invert = T) + 3
  sumSpe  <- apply(data[colSpe],  1, function(x){sum(as.integer(x), na.rm = T)})
  sumData <- apply(data[colData], 1, function(x){sum(as.integer(x), na.rm = T)})

  ## Replace noise with empty data
  # Multiple special (No/Unsure/Not applicable) columns checked at the same time
  data[sumSpe > 1, colData] <- ""
  # Data column(s) and special column(s) checked at the same time
  data[sumData > 0 & sumSpe > 0, colData] <- ""

  ## Only one special column checked
  for (col in colSpe)
    data[data[col] == "1", col] <- gsub("\\.", " ", sub(".*_([^_]+)$", "\\1", names(data[col])))

  varSpe <- apply(data[colSpe], 1, paste, collapse = "")
  varSpe <- sub("No(ne.*| intervention)?", "No", varSpe)
  data[sumSpe == 1 & sumData == 0, colData] <- varSpe[sumSpe == 1 & sumData == 0]

  ## Normal case
  for (col in colData)
    data[sumData > 0 & sumSpe == 0, col] <- ifelse(data[sumData > 0 & sumSpe == 0, col] == "1", "Yes", "No (by imputation)")

  ## Re-fill "Other" columns with its values
  if (any(grepl("_Other$", names(data))))
    data[data[colOther] == "Yes", colOther] <- varOther[data[colOther] == "Yes"]

  ## Remove special columns
  select(data, -matches("_(Unsure|Not applicable|No(ne.*| intervention)?)"))
}

# Create at age X/current variables for evolutive variables
evolutive <- function(data)
{
  data$Birthdate <- as.numeric(strptime(data$Birthdate, format = "%Y-%m-%d"))
  data <- mutate(data, Age = as.integer((Survey.Date - Birthdate) / (365.25 * 24 * 3600))) %>%
    group_by(Patient.ID, Age) %>%
    filter(Survey.Date == last(Survey.Date)) %>%
    ungroup

  data2 <- data %>%
    group_by(Patient.ID) %>%
    filter(Survey.Date == last(Survey.Date)) %>%
    select(-Age, -Survey.Date, -Birthdate) %>%
    ungroup
  varnames <- names(data2)
  varnames[-1] <- paste0(varnames[-1], "_ currently")
  names(data2) <- varnames

  for (var in names(data[-c(1:3, length(data))]))
  {
    data3 <- spread_(data[c("Patient.ID", "Age", var)], "Age", var, fill = "")
    varnames <- names(data3)
    varnames <- sub("^(\\d)$", "0\\1", varnames)
    varnames <- sub("^00$", "<1", varnames)
    varnames[-1] <- paste0(var, "_at age ", varnames[-1])
    names(data3) <- varnames
    data2 <- merge(data2, data3)
  }

  data2
}

#
historical <- function(data)
{
  data %>%
    group_by(Patient.ID) %>%
    filter(Survey.Date == last(Survey.Date)) %>%
    select(-Survey.Date, -Birthdate) %>%
    ungroup
}