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
	
	generatePatientDimensionControlFile({PATIENT_DIMENSION_COLUMNS => $params->{PATIENT_DIMENSION_COLUMNS}});
	generateConceptDimensionControlFile({CONCEPT_DIMENSION_COLUMNS => $params->{CONCEPT_DIMENSION_COLUMNS}});
	generateObservationFactControlFile({OBSERVATION_FACT_COLUMNS => $params->{OBSERVATION_FACT_COLUMNS}});
	generateI2b2ControlFile({I2B2_COLUMNS => $params->{I2B2_COLUMNS}});
	
	generateMasterScripts($configurationObject->{SQLLDR_LOGIN_STRING});
}

sub generateMasterScripts
{

	my $sqlLdrString = shift;

	open (patientMasterScript,'>',"$basePath/scripts/load_patient_data.sh") or die("Unable to write $basePath/scripts/load_patient_data.sh'");
	print patientMasterScript "sqlldr $sqlLdrString control=../control_files/patientDimension.ctl log=../log_files/patient_dimension.log";
	close patientMasterScript;

	open (conceptMasterScript,'>',"$basePath/scripts/load_concept_data.sh") or die("Unable to write $basePath/scripts/load_concept_data.sh'");
	print conceptMasterScript "sqlldr $sqlLdrString control=../control_files/conceptDimension.ctl log=../log_files/concept_dimension.log";
	close conceptMasterScript;
	
	open (factMasterScript,'>',"$basePath/scripts/load_fact_data.sh") or die("Unable to write $basePath/scripts/load_fact_data.sh'");
	print factMasterScript "sqlldr $sqlLdrString control=../control_files/observationFact.ctl log=../log_files/observation_fact.log";
	close factMasterScript;
	
	open (i2b2MasterScript,'>',"$basePath/scripts/load_i2b2_data.sh") or die("Unable to write $basePath/scripts/load_i2b2_data.sh'");
	print i2b2MasterScript "sqlldr $sqlLdrString control=../control_files/i2b2.ctl log=../log_files/i2b2.log";
	close i2b2MasterScript;	
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

1;