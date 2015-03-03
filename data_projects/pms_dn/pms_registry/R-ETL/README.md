README
======

R scripts to load and clean PMSIR raw data files.

Input files
-----------

Three input files are obtained from the registry :

* Clinical Questionnaire + Genetic test results
* Developmental Questionnaire
* Adolescent and Adults Questionnaire

The files have to be loaded in Excel or LibreOffice using the UTF-8 character encoding and saved to the csv format (US type: separator is a comma, blocks of text surrounded by double quotes) using the following naming convention:
dataClinical.csv for the Clinical&Genetic Questionnaire
dataDevelopmental.csv for the Developmental Questionnaire
dataAdult.csv for the Adolescent and Adults Questionnaire

Three pre-mapping files must be given, one for each of the data files, with the same naming convention (eg: premapClinical.csv)
Premapping files can be modified from the current ones in the repo.

The format for the files is the following:
