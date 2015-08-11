source("functions-loading.R")
require(lubridate)

# Extract the genetic test results fields from the clinical file, only where there are results
# Parse the dates
clinical <- read.csv.2header("dataClinical.csv")
clinical[c(1,5,19:67)] %>%
  filter(Genetic.Status != "No Results Received") %>%
  mutate(Test.Date = gsub("/", "-",                      Test.Date, perl = T)) %>%
  mutate(Test.Date = gsub("^(\\d)-", "0\\1-",            Test.Date, perl = T)) %>%
  mutate(Test.Date = gsub("-(\\d)-", "-0\\1-",           Test.Date, perl = T)) %>%
  mutate(Test.Date = gsub("-(\\d{2})$", "-20\\1",        Test.Date, perl = T)) %>%
  mutate(Test.Date = gsub("(^\\d{2}-\\d{4}$)", "01-\\1", Test.Date, perl = T)) %>%
  mutate(Test.Date = gsub("^[\\w ]+$", "",               Test.Date, perl = T)) %>%
  mutate(Test.Date = mdy(Test.Date)) %>%
  distinct -> Genetics

# Correct test dates in the 20th century
Genetics$Test.Date[which(Genetics$Test.Date > now())] <- Genetics$Test.Date[which(Genetics$Test.Date > now())] - years(100)

# Sort by patient and date
Genetics <- arrange(Genetics, Patient.ID, Test.Date)

# Create empty new variables and reorder the columns
Genetics <- mutate(Genetics, Result.type = "", Gain.Loss = "", Chr.Gene = "", Start = "", End = "")
Genetics <- select(Genetics, 1, 3, 2, 13, 52:56, 5, 14:17, 37:40, 42:45, 47:50, 19:21, 36, 34, 35, everything())

# Insert empty lines to facilitate editing
fill <- Genetics %>% select(Patient.ID) %>% distinct
fill$Test.Date <- ymd("1900-01-01")
Genetics <- full_join(Genetics,fill) %>% arrange(Patient.ID,Test.Date)
Genetics[is.na(Genetics$Genetic.Status),1:2] <- NA
rm(fill)

write.csv(Genetics, "dataGenetics.csv")
