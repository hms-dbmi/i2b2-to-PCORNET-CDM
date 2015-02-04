<h1>Summary</h1>

This code represents the Perl based ETL tool for tranSMART. This will create files that mimic the basic i2b2 tables (observation_fact,i2b2,concept_dimension,patient_dimension) and some tranSMART specific tables (concept_counts,concept_folders_patients).

<h1>Usage</h1>

./etl_main "/path/to/config/" debugFlag

The debug flag is a 1 or 0. 1 for debug, 0 for production. Debug mode will prevent the generation of new numbers from the sequence to prevent us from running out of IDs.

<h1>Pseudo-Code</h1>

<h2>Step1.</h2>
Find distinct Patients and store in hash{source_patient_id}=patient_num
Create patient dimension records (where needed/reuse existing)
 
<h2>Step2.</h2>
Find distinct Concepts and store in hash{concept_path}=concept_cd
Create concept dimension records
 
<h2>Step3.</h2>
For each record in input file
For each concept
Find the concept_path for current column in data file and create fact records
Create fact record and keep track of some extra hashes for counts
