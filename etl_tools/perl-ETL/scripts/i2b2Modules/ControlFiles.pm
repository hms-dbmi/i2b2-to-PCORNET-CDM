#!/usr/bin/perl

package ControlFiles;

use strict;
use warnings;
use Carp;

my $basePath;

sub generateControlFiles
{
	my ($params) = @_;
	
	my $configurationObject = $params->{CONFIGURATION_OBJECT};
	
	$basePath = $configurationObject->{BASE_PATH};
	
	#This is so ugly but I didn't take the time to figure out inheritance in perl.
	generatePatientDimensionControlFile({PATIENT_DIMENSION_COLUMNS => $params->{PATIENT_DIMENSION_COLUMNS}});
	generateConceptDimensionControlFile({CONCEPT_DIMENSION_COLUMNS => $params->{CONCEPT_DIMENSION_COLUMNS}});
	generateObservationFactControlFile({OBSERVATION_FACT_COLUMNS => $params->{OBSERVATION_FACT_COLUMNS}});
	generateI2b2ControlFile({I2B2_COLUMNS => $params->{I2B2_COLUMNS}});
	generateConceptCountControlFile({CONCEPT_COUNT_COLUMNS => $params->{CONCEPT_COUNT_COLUMNS}});
	generateConceptsFoldersPatientsControlFile({CONCEPTS_FOLDERS_PATIENTS_COLUMNS => $params->{CONCEPTS_FOLDERS_PATIENTS_COLUMNS}});
	generatePatientMappingControlFile({PATIENT_MAPPING_COLUMNS => $params->{PATIENT_MAPPING_COLUMNS}});
	
	generateMasterScripts($configurationObject->{SQLLDR_LOGIN_STRING});
}

sub generateMasterScripts
{

	my $sqlLdrString = shift;

	open (patientMasterScript,'>',"$basePath/scripts/load_patient_data.sh") or die("Unable to write $basePath/scripts/load_patient_data.sh'");
	print patientMasterScript "/usr/bin/time -v sqlldr $sqlLdrString control=../control_files/patientDimension.ctl log=../log_files/patient_dimension.log";
	close patientMasterScript;

	open (conceptMasterScript,'>',"$basePath/scripts/load_concept_data.sh") or die("Unable to write $basePath/scripts/load_concept_data.sh'");
	print conceptMasterScript "/usr/bin/time -v sqlldr $sqlLdrString control=../control_files/conceptDimension.ctl log=../log_files/concept_dimension.log";
	close conceptMasterScript;
	
	open (factMasterScript,'>',"$basePath/scripts/load_fact_data.sh") or die("Unable to write $basePath/scripts/load_fact_data.sh'");
	print factMasterScript "/usr/bin/time -v sqlldr $sqlLdrString control=../control_files/observationFact.ctl log=../log_files/observation_fact.log";
	close factMasterScript;
	
	open (i2b2MasterScript,'>',"$basePath/scripts/load_i2b2_data.sh") or die("Unable to write $basePath/scripts/load_i2b2_data.sh'");
	print i2b2MasterScript "/usr/bin/time -v sqlldr $sqlLdrString control=../control_files/i2b2.ctl log=../log_files/i2b2.log";
	close i2b2MasterScript;	
	
	open (conceptCountMasterScript,'>',"$basePath/scripts/load_concept_count_data.sh") or die("Unable to write $basePath/scripts/load_concept_count_data.sh'");
	print conceptCountMasterScript "/usr/bin/time -v sqlldr $sqlLdrString control=../control_files/concept_count.ctl log=../log_files/concept_count.log";
	close conceptCountMasterScript;	
	
	open (conceptFolderMasterScript,'>',"$basePath/scripts/load_concept_folders_patients_data.sh") or die("Unable to write $basePath/scripts/load_concept_folders_patients_data.sh'");
        print conceptFolderMasterScript "/usr/bin/time -v sqlldr $sqlLdrString control=../control_files/concepts_folders_patients.ctl log=../log_files/concepts_folders_patients.ctl";
        close conceptFolderMasterScript;

        open (patientMappingMasterScript,'>',"$basePath/scripts/load_patient_mapping_data.sh") or die("Unable to write $basePath/scripts/load_patient_mapping_data.sh'");
        print patientMappingMasterScript "/usr/bin/time -v sqlldr $sqlLdrString control=../control_files/patient_mapping.ctl log=../log_files/patient_mapping.ctl";
        close patientMappingMasterScript;

}

sub generatePatientDimensionControlFile
{
	my ($params) = @_;

	open(patient_dimension_control_file, ">$basePath/control_files/patientDimension.ctl") or die("Unable to write $basePath/control_files/patientDimension.ctl'");
	
	print patient_dimension_control_file "OPTIONS (SKIP=1)\n";
	print patient_dimension_control_file "load data\n";
	print patient_dimension_control_file "infile '../data/i2b2_load_tables/patient_dimension.dat'\n";
	print patient_dimension_control_file "APPEND into table i2b2DemoData.PATIENT_DIMENSION\n";
	print patient_dimension_control_file 'fields terminated by "\t" TRAILING NULLCOLS' . "\n";
	print patient_dimension_control_file $params->{PATIENT_DIMENSION_COLUMNS};
	
	close patient_dimension_control_file;
}

sub generateConceptDimensionControlFile
{
	my ($params) = @_;

	open(concept_dimension_control_file, ">$basePath/control_files/conceptDimension.ctl") or die("Unable to write $basePath/control_files/conceptDimension.ctl'");
	
	print concept_dimension_control_file "OPTIONS (DIRECT=TRUE, SKIP=1) UNRECOVERABLE\n";
	print concept_dimension_control_file "load data\n";
	print concept_dimension_control_file "infile '../data/i2b2_load_tables/concept_dimension.dat'\n";
	print concept_dimension_control_file "APPEND into table i2b2DemoData.CONCEPT_DIMENSION\n";
	print concept_dimension_control_file 'fields terminated by "\t" TRAILING NULLCOLS' . "\n";
	print concept_dimension_control_file $params->{CONCEPT_DIMENSION_COLUMNS};
	
	close concept_dimension_control_file;
}

sub generateObservationFactControlFile
{
	my ($params) = @_;

	open(observation_fact_control_file, ">$basePath/control_files/observationFact.ctl") or die("Unable to write $basePath/control_files/observationFact.ctl'");
	
	print observation_fact_control_file "OPTIONS(DIRECT=TRUE, SKIP=1) UNRECOVERABLE load data\n";
	print observation_fact_control_file "infile '../data/i2b2_load_tables/observation_fact.dat'\n";
	print observation_fact_control_file "APPEND into table i2b2DemoData.OBSERVATION_FACT\n";
	print observation_fact_control_file 'fields terminated by "\t" TRAILING NULLCOLS' . "\n";
	print observation_fact_control_file $params->{OBSERVATION_FACT_COLUMNS};
	
	close observation_fact_control_file;
}

sub generateI2b2ControlFile
{
	my ($params) = @_;

	open(i2b2_control_file, ">$basePath/control_files/i2b2.ctl") or die("Unable to write $basePath/control_files/i2b2.ctl'");
	
	print i2b2_control_file "OPTIONS (DIRECT=TRUE, SKIP=1) UNRECOVERABLE \n";
	print i2b2_control_file "load data\n";
	print i2b2_control_file "infile '../data/i2b2_load_tables/i2b2.dat'\n";
	print i2b2_control_file "APPEND into table i2b2MetaData.i2b2\n";
	print i2b2_control_file 'fields terminated by "\t" TRAILING NULLCOLS' . "\n";
	print i2b2_control_file $params->{I2B2_COLUMNS};
	
	close i2b2_control_file;


}

sub generateConceptCountControlFile
{
	my ($params) = @_;

	open(concept_count_control_file, ">$basePath/control_files/concept_count.ctl") or die("Unable to write $basePath/control_files/concept_count.ctl'");
	
	print concept_count_control_file "OPTIONS (DIRECT=TRUE, SKIP=1) UNRECOVERABLE \n";
	print concept_count_control_file "load data\n";
	print concept_count_control_file "infile '../data/i2b2_load_tables/concept_count.dat'\n";
	print concept_count_control_file "APPEND into table i2b2DemoData.concept_counts\n";
	print concept_count_control_file 'fields terminated by "\t" TRAILING NULLCOLS' . "\n";
	print concept_count_control_file $params->{CONCEPT_COUNT_COLUMNS};
	
	close concept_count_control_file;


}

sub generateConceptsFoldersPatientsControlFile
{
	my ($params) = @_;

	open(concepts_folders_patients_control_file, ">$basePath/control_files/concepts_folders_patients.ctl") or die("Unable to write $basePath/control_files/concepts_folders_patients.ctl'");
	
	print concepts_folders_patients_control_file "OPTIONS (DIRECT=TRUE, SKIP=1) UNRECOVERABLE \n";
	print concepts_folders_patients_control_file "load data\n";
	print concepts_folders_patients_control_file "infile '../data/i2b2_load_tables/concepts_folders_patients.dat'\n";
	print concepts_folders_patients_control_file "APPEND into table i2b2DemoData.concepts_folders_patients\n";
	print concepts_folders_patients_control_file 'fields terminated by "\t" TRAILING NULLCOLS' . "\n";
	print concepts_folders_patients_control_file $params->{CONCEPTS_FOLDERS_PATIENTS_COLUMNS};
	
	close concepts_folders_patients_control_file;


}

sub generatePatientMappingControlFile
{
	my ($params) = @_;

	open(patient_mapping_control_file, ">$basePath/control_files/patient_mapping.ctl") or die("Unable to write $basePath/control_files/patient_mapping.ctl'");
	
	print patient_mapping_control_file "OPTIONS (DIRECT=TRUE, SKIP=1) UNRECOVERABLE \n";
	print patient_mapping_control_file "load data\n";
	print patient_mapping_control_file "infile '../data/i2b2_load_tables/patient_mapping.dat'\n";
	print patient_mapping_control_file "APPEND into table i2b2DemoData.PATIENT_MAPPING\n";
	print patient_mapping_control_file 'fields terminated by "\t" TRAILING NULLCOLS' . "\n";
	print patient_mapping_control_file $params->{PATIENT_MAPPING_COLUMNS};
	
	close patient_mapping_control_file;


}

1;
