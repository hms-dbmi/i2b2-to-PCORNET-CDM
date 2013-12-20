#!/usr/bin/perl

use i2b2Modules::ConceptDimension;
use i2b2Modules::PatientDimension;
use i2b2Modules::ObservationFact;
use i2b2Modules::i2b2;

use i2b2Modules::PatientDimensionFile;
use i2b2Modules::ConceptDimensionFile;
use i2b2Modules::ObservationFactFile;
use i2b2Modules::i2b2File;

use i2b2Modules::ControlFiles;

use ANNOVARModules::VariantFieldMapping;

use utilityModules::DatabaseConnection;
use utilityModules::tranSMARTTextParsing;

use Data::Dumper;

my $start_run = time();

my $baseDirectory = "/Users/mmcduffie/src/tranSMART/ETL/annovar2transmart/";

print("*************************************************************\n");
print("annovar_to_transmart.pl\n");
print("*************************************************************\n");
print("DEBUG - annovar_to_transmart.pl : Base Directory set to $baseDirectory\n\n");

my $patientHash = PatientDimensionFile::generatePatientDimensionFile({BASE_DIRECTORY => $baseDirectory});

my @conceptReturnObjects = ConceptDimensionFile::generateConceptDimensionFile({BASE_DIRECTORY => $baseDirectory, STUDY_ID => 'WES_LOADING'});

i2b2File::generateI2b2File({BASE_DIRECTORY 				=> $baseDirectory,
							INDIVIDUAL_NUMERIC_CONCEPTS => $conceptReturnObjects[0], 
						   	VARIANT_NUMERIC_CONCEPTS 	=> $conceptReturnObjects[1],
						   	INDIVIDUAL_TEXT_CONCEPTS 	=> $conceptReturnObjects[2],
						   	VARIANT_TEXT_CONCEPTS 		=> $conceptReturnObjects[3]});

ObservationFactFile::generateObservationFactFile({	BASE_DIRECTORY 				=> $baseDirectory, 
													PATIENT_HASH 				=> $patientHash , 
													INDIVIDUAL_NUMERIC_CONCEPTS => $conceptReturnObjects[0], 
													VARIANT_NUMERIC_CONCEPTS 	=> $conceptReturnObjects[1],
						   							INDIVIDUAL_TEXT_CONCEPTS 	=> $conceptReturnObjects[2],
						   							VARIANT_TEXT_CONCEPTS 		=> $conceptReturnObjects[3]});

ControlFiles::generateControlFiles({	BASE_DIRECTORY 				=> $baseDirectory,
										PATIENT_DIMENSION_COLUMNS 	=> PatientDimension::printColumnHeadersInList(),
										CONCEPT_DIMENSION_COLUMNS 	=> ConceptDimension::printColumnHeadersInList(),
										OBSERVATION_FACT_COLUMNS  	=> ObservationFact::printColumnHeadersInList(),
										I2B2_COLUMNS			  	=> i2b2::printColumnHeadersInListForCTL()});
										
										
my $end_run = time();
my $run_time = $end_run - $start_run;
print "Generating files took $run_time seconds\n";

#We need to disable an index.
#ALTER INDEX i2b2DemoData.OF_CTX_BLOB UNUSABLE;
#ALTER INDEX i2b2DemoData.OF_CTX_BLOB REBUILD;

$start_run = time();

#my $script1 = `./load_patient_data.sh`;
#my $script2 = `./load_concept_data.sh`;
#my $script3 = `./load_fact_data.sh`;
#my $script4 = `./load_i2b2_data.sh`;

$end_run = time();
$run_time = $end_run - $start_run;
print "Inserting data took $run_time seconds\n";