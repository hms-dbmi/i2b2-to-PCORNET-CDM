source("functions-process.R")

#==== Genetic information ====
#Extract the information to an external file
clinical <- read.csv.2header("dataClinical.csv")
clinical[c(1,5,19:67)] %>%
  mutate(Test.Date = gsub("/", "-",                      Test.Date, perl = T)) %>%
  mutate(Test.Date = gsub("^(\\d)-", "0\\1-",            Test.Date, perl = T)) %>%
  mutate(Test.Date = gsub("-(\\d)-", "-0\\1-",           Test.Date, perl = T)) %>%
  mutate(Test.Date = gsub("-(\\d{2})$", "-20\\1",        Test.Date, perl = T)) %>%
  mutate(Test.Date = gsub("(^\\d{2}-\\d{4}$)", "01-\\1", Test.Date, perl = T)) %>%
  mutate(Test.Date = gsub("^[\\w ]+$", "",               Test.Date, perl = T)) %>%
  mutate(Test.Date = as.Date(Test.Date, format = "%m-%d-%Y")) %>%
  arrange(Patient.ID, Test.Date) %>%
  distinct -> Genetics
write.csv(Genetics, "dataGenetics.csv")
