#!/usr/bin/perl

use i2b2Modules::ConceptDimension;
use i2b2Modules::PatientDimension;
use i2b2Modules::ObservationFact;
use i2b2Modules::PatientDimensionFile;
use i2b2Modules::ConceptDimensionFile;
use i2b2Modules::ObservationFactFile;
use ANNOVARModules::VariantFieldMapping;

use Data::Dumper;

my $baseDirectory = "/Users/mmcduffie/src/tranSMART/ETL/annovar2transmart/";

print("DEBUG - annovar_to_transmart.pl : Base Directory set to $baseDirectory\n");

my $patientHash = PatientDimensionFile::generatePatientDimensionFile({BASE_DIRECTORY => $baseDirectory});
my @conceptReturnObjects = ConceptDimensionFile::generateConceptDimensionFile({BASE_DIRECTORY => $baseDirectory});

my $conceptList = $conceptReturnObjects[0];
my $conceptHash = $conceptReturnObjects[1];

ObservationFactFile::generateObservationFactFile({BASE_DIRECTORY => $baseDirectory, PATIENT_HASH => $patientHash , CONCEPT_HASH => $conceptHash, CONCEPT_LIST => $conceptList});

