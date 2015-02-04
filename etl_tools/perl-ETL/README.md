Step1. 
Find distinct Patients and store in hash{source_patient_id}=patient_num
Create patient dimension records (where needed/reuse existing)
 
Step2.
Find distinct Concepts and store in hash{concept_path}=concept_cd
Create concept dimension records
 
Step3.
For each record in input file
For each concept
Find the concept_path for current column in data file and create fact records
Create fact record and keep track of some extra hashes for counts
