#!/usr/bin/perl

#$ARGV[0]
#Config File

#$ARGV[1]
#Debug Flag

#TODO
#Add debugging log file.

#This is to get the pathing down properly so we can run this script from another directory.
use File::Basename;
my $dirname = dirname(__FILE__);

require "$dirname/i2b2Modules/ConceptDimension.pm";
require "$dirname/i2b2Modules/PatientDimension.pm";
require "$dirname/i2b2Modules/ObservationFact.pm";
require "$dirname/i2b2Modules/i2b2.pm";
require "$dirname/i2b2Modules/ConceptCount.pm";
require "$dirname/i2b2Modules/ConceptsFoldersPatients.pm";
require "$dirname/i2b2Modules/PatientMapping.pm";

require "$dirname/i2b2Modules/PatientDimensionFile.pm";
require "$dirname/i2b2Modules/ConceptDimensionFile.pm";
require "$dirname/i2b2Modules/ObservationFactFile.pm";
require "$dirname/i2b2Modules/i2b2File.pm";

require "$dirname/i2b2Modules/ControlFiles.pm";

require "$dirname/utilityModules/configurationObject.pm";
require "$dirname/utilityModules/DatabaseConnection.pm";
require "$dirname/utilityModules/tranSMARTTextParsing.pm";

use Data::Dumper;

my $start_run = time();

print("*************************************************************\n");
print("tranSMART ETL\n");
print("*************************************************************\n");

#Create the concept object.
my $configurationObject = tranSMARTTextParsing::generateConfigObjectFromFile($ARGV[0], $ARGV[1]);

print("DEBUG - etl_main.pl : using configuration object.\n\n");

my $patientHash 			= PatientDimensionFile::generatePatientDimensionFile($configurationObject);

my @conceptReturnObjects	= ConceptDimensionFile::generateConceptDimensionFile($configurationObject);

i2b2File::generateI2b2File({CONFIGURATION_OBJECT 		=> $configurationObject,
							INDIVIDUAL_NUMERIC_CONCEPTS => $conceptReturnObjects[0], 
						   	INDIVIDUAL_TEXT_CONCEPTS 	=> $conceptReturnObjects[1]});

ObservationFactFile::generateObservationFactFile({	CONFIGURATION_OBJECT 		=> $configurationObject, 
													PATIENT_HASH 				=> $patientHash , 
													INDIVIDUAL_NUMERIC_CONCEPTS => $conceptReturnObjects[0], 
						   							INDIVIDUAL_TEXT_CONCEPTS 	=> $conceptReturnObjects[1]});

ControlFiles::generateControlFiles({	CONFIGURATION_OBJECT 		=> $configurationObject,
										PATIENT_DIMENSION_COLUMNS 	=> PatientDimension::printColumnHeadersInList(),
										CONCEPT_DIMENSION_COLUMNS 	=> ConceptDimension::printColumnHeadersInList(),
										OBSERVATION_FACT_COLUMNS  	=> ObservationFact::printColumnHeadersInList(),
										I2B2_COLUMNS			  	=> i2b2::printColumnHeadersInListForCTL(),
										CONCEPT_COUNT_COLUMNS		=> ConceptCount::printColumnHeadersInList(),
										CONCEPTS_FOLDERS_PATIENTS_COLUMNS => ConceptsFoldersPatients::printColumnHeadersInList()});
										
										
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