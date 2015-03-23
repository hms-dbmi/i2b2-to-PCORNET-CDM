README
======

R scripts to load and clean PMSIR raw data files.

Input files
-----------

Three input files are obtained from the registry :

* Clinical Questionnaire + Genetic test results
* Developmental Questionnaire
* Adolescent and Adults Questionnaire

The files must first be prepended with the following lines so that Excel/LibreOffice registers the correct encoding:
    <html>
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    </head>

The files contain the entirety of the data two times (headers included) that have to be removed from Excel/LibreOffice.
The files then have to be saved to the csv format (US type: separator is a comma, blocks of text surrounded by double quotes) using the following naming convention:
dataClinical.csv for the Clinical&Genetic Questionnaire
dataDevelopmental.csv for the Developmental Questionnaire
dataAdult.csv for the Adolescent and Adults Questionnaire

Three pre-mapping files must be given, one for each of the data files, with the same naming convention (eg: premapClinical.csv)
Premapping files can be modified from the current ones in the repo, or regenerated from scratch using the writePremap function.
