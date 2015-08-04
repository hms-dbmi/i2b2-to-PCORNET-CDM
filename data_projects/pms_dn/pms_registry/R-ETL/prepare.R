html2csv <- function(filename)
{
  # Open file as raw UTF-8 text
  file <- file(paste0(filename,".xls"), encoding = "UTF-8")
  html <- readLines(file)
  close(file)

  # Concatenate all lines and preserve newlines
  html <- paste(html,sep = "", collapse = "\n")

  # Keep only one sample of the data (it appears twice in the file)
  html <-  sub(".*?<table border=0>(.*?)</table>.*", "\\1",  html)

  # Process th's with colspan attribute (first header row)
  while (length(grep("<th.*?colspan=(\\d+).*?>.*?</th>", html)) > 0)
  {
    m <- regexpr("[[:space:]]*<th.*?colspan=(\\d+).*?>[[:space:]]*(.*?)[[:space:]]*</th>[[:space:]]*(?s)", html, perl = T)
    nb <- as.numeric(substr(html, attr(m,"capture.start")[1], attr(m,"capture.start")[1] + attr(m,"capture.length")[1] - 1))
    str <- substr(html, attr(m,"capture.start")[2], attr(m,"capture.start")[2] + attr(m,"capture.length")[2] - 1)
    str <- paste0("|", str, "|", ",")
    html <- sub("[[:space:]]*<th.*?colspan=(\\d+).*?>[[:space:]]*(.*?)[[:space:]]*</th>[[:space:]]*(?s)", paste0(rep(str, nb), collapse = ""), html, perl = T)
  }

  # Process second header row
  html <- gsub("[[:space:]]*</th>[[:space:]]*<th.*?>[[:space:]]*", '|,|', html)
  html <- gsub("[[:space:]]*</?th.*?>[[:space:]]*",                '|',   html)

  # Process body of the table
  html <- gsub("[[:space:]]*</td>[[:space:]]*<td.*?>[[:space:]]*", '|,|', html)
  html <- gsub("[[:space:]]*</?td.*?>[[:space:]]*",                '|',   html)

  # Create the correct newlines
  html <- gsub("[[:space:]]*<tr.*?>[[:space:]]*",                  "",    html)
  html <- gsub("[[:space:]]*</tr>[[:space:]]*",                    "\n",  html)

  # Get rid of other tags
  html <- gsub("<.*?>",                                            "",    html)

  # Unescape quotes
  html <- gsub('\\\\+',                                            '',    html)

  # Get rid of trailing commas
  html <- gsub(',\n',                                              '\n',  html, perl = T)

  # Write final csv file
  cat(html,file = paste0(filename, ".csv"))
}

html2csv("dataClinical")
html2csv("dataDevelopmental")
html2csv("dataAdult")
