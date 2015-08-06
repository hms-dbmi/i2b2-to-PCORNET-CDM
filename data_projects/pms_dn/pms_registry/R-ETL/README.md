README
======

R scripts to load and clean PMSIR raw data files.

This diagram is an overview of the process. On the left are the data manipulated by each steps. On the right are the R scripts called for each step.
Each step is detailed after the diagram.

![](Data integration pipeline.png)

Step 0
------

Get the files from PMSIR.
Three input files are obtained from the registry:

* Clinical Questionnaire + Genetic test results
* Developmental Questionnaire
* Adolescent and Adults Questionnaire

These three files are HTML tables in .xls files.
**Do not open these files with excel !**

They must first be renamed as following:
* dataClinical.xls
* dataDevelopmental.xls
* dataAdult.xls
and placed in the scripts folder.

Step 1
------

The files must be converted to the csv format.
This is done using the first script: *01_prepare_files.sh*
This script calls the *01_prepare.R* R script.
Three new files are created:
* dataClinical.csv
* dataDevelopmental.csv
* dataAdult.csv

These files are UTF-8 encoded, comma (,) separated, with pipes (|) as quotes to delimit text fields.
You can check the csv files by opening them in LibreOffice (excel doesn't accept pipes as text delimiters)

![](libreoffice.png)

**In case this step fails**, it can still be done manually using the following procedure:
The files must first be prepended with the following lines so that Excel/LibreOffice registers the correct encoding:
```html
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</head>
```
Open the files in a text editor, add these 4 lines at the beginning of the file and save it.
Open the files in Excel/LibreOffice.
The files contain the entirety of the data two times (headers included) that have to be removed.
Save the files to the csv format (US type: separator is a comma (,), blocks of text surrounded by pipes (|)) using the following naming convention:
dataClinical.csv for the Clinical&Genetic Questionnaire
dataDevelopmental.csv for the Developmental Questionnaire
dataAdult.csv for the Adolescent and Adults Questionnaire

Step 2 (run once)
-----------------

The genetic data must be extracted from the dataClinical file.
To do so, run the second script: *02_once_extract_genetics.sh*
This script calls the *02_once_extract_genetics.R* R script, and creates the *dataGenetic.csv* file.
This file must be reviewed manually. This process is detailed in a dedicated section of this readme.

Step 3 (optional)
-----------------


