#!/usr/bin/perl

#This is to get the pathing down properly so we can run this script from another directory.
use File::Basename;
my $dirname = dirname(__FILE__);

require "$dirname/i2b2Modules/ConceptDimension.pm";
require "$dirname/i2b2Modules/PatientDimension.pm";
require "$dirname/i2b2Modules/ObservationFact.pm";
require "$dirname/i2b2Modules/i2b2.pm";

require "$dirname/i2b2Modules/PatientDimensionFile.pm";
require "$dirname/i2b2Modules/ConceptDimensionFile.pm";
require "$dirname/i2b2Modules/ObservationFactFile.pm";
require "$dirname/i2b2Modules/i2b2File.pm";

require "$dirname/i2b2Modules/ControlFiles.pm";

require "$dirname/ANNOVARModules/VariantFieldMapping.pm";
require "$dirname/ANNOVARModules/configurationObject.pm";

require "$dirname/utilityModules/DatabaseConnection.pm";
require "$dirname/utilityModules/tranSMARTTextParsing.pm";

use Data::Dumper;

my $start_run = time();

print("*************************************************************\n");
print("annovar_to_transmart.pl\n");
print("*************************************************************\n");

print($ARGV[0]);

#Create the concept object.
my $configurationObject = tranSMARTTextParsing::generateConfigObjectFromFile($ARGV[0]);

print("DEBUG - annovar_to_transmart.pl : using configuration object.\n\n");

print(Dumper($configurationObject));


my $patientHash 			= PatientDimensionFile::generatePatientDimensionFile($configurationObject);
my @conceptReturnObjects	= ConceptDimensionFile::generateConceptDimensionFile($configurationObject);

i2b2File::generateI2b2File({CONFIGURATION_OBJECT 		=> $configurationObject,
							INDIVIDUAL_NUMERIC_CONCEPTS => $conceptReturnObjects[0], 
						   	VARIANT_NUMERIC_CONCEPTS 	=> $conceptReturnObjects[1],
						   	INDIVIDUAL_TEXT_CONCEPTS 	=> $conceptReturnObjects[2],
						   	VARIANT_TEXT_CONCEPTS 		=> $conceptReturnObjects[3]});

ObservationFactFile::generateObservationFactFile({	CONFIGURATION_OBJECT 		=> $configurationObject, 
													PATIENT_HASH 				=> $patientHash , 
													INDIVIDUAL_NUMERIC_CONCEPTS => $conceptReturnObjects[0], 
													VARIANT_NUMERIC_CONCEPTS 	=> $conceptReturnObjects[1],
						   							INDIVIDUAL_TEXT_CONCEPTS 	=> $conceptReturnObjects[2],
						   							VARIANT_TEXT_CONCEPTS 		=> $conceptReturnObjects[3]});

ControlFiles::generateControlFiles({	CONFIGURATION_OBJECT 		=> $configurationObject,
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