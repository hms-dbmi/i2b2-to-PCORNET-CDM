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

my $baseDirectory = "/Users/mmcduffie/src/tranSMART/ETL/annovar2transmart/";

print("DEBUG - annovar_to_transmart.pl : Base Directory set to $baseDirectory\n\n");

my $patientHash = PatientDimensionFile::generatePatientDimensionFile({BASE_DIRECTORY => $baseDirectory});

my @conceptReturnObjects = ConceptDimensionFile::generateConceptDimensionFile({BASE_DIRECTORY => $baseDirectory});

i2b2File::generateI2b2File({BASE_DIRECTORY => $baseDirectory,
							INDIVIDUAL_CONCEPTS => $conceptReturnObjects[0], 
						   	VARIANT_CONCEPTS => $conceptReturnObjects[1]});

#ObservationFactFile::generateObservationFactFile({	BASE_DIRECTORY => $baseDirectory, 
#													PATIENT_HASH => $patientHash , 
#													INDIVIDUAL_CONCEPTS => $conceptReturnObjects[0], 
#													VARIANT_CONCEPTS => $conceptReturnObjects[1]});

ControlFiles::generateControlFiles({	BASE_DIRECTORY => $baseDirectory,
										PATIENT_DIMENSION_COLUMNS => PatientDimension::printColumnHeadersInList(),
										CONCEPT_DIMENSION_COLUMNS => ConceptDimension::printColumnHeadersInList(),
										OBSERVATION_FACT_COLUMNS  => ObservationFact::printColumnHeadersInList()})
