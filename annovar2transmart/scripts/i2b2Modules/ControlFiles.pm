#!/usr/bin/perl

package ControlFiles;

use strict;
use warnings;
use Carp;

my $basePath;

sub generateControlFiles
{
	my ($params) = @_;
	
	$basePath = $params->{BASE_DIRECTORY};
	
	generatePatientDimensionControlFile({PATIENT_DIMENSION_COLUMNS => $params->{PATIENT_DIMENSION_COLUMNS}});
	generateConceptDimensionControlFile({CONCEPT_DIMENSION_COLUMNS => $params->{CONCEPT_DIMENSION_COLUMNS}});
	generateObservationFactControlFile({OBSERVATION_FACT_COLUMNS => $params->{OBSERVATION_FACT_COLUMNS}});
	
	generateMasterScripts();
}

sub generateMasterScripts
{
	open (patientMasterScript,'>',"$basePath/scripts/load_patient_data.sh") or die("Unable to write $basePath/scripts/load_patient_data.sh'");
	print patientMasterScript "sqlldr tm_lz/tm_lz control=control_files/patientDimension.ctl log=logFiles/patient_dimension.log";
	close patientMasterScript;

	open (conceptMasterScript,'>',"$basePath/scripts/load_concept_data.sh") or die("Unable to write $basePath/scripts/load_concept_data.sh'");
	print conceptMasterScript "sqlldr tm_lz/tm_lz control=control_files/conceptDimension.ctl log=logFiles/concept_dimension.log";
	close conceptMasterScript;
	
	open (factMasterScript,'>',"$basePath/scripts/load_fact_data.sh") or die("Unable to write $basePath/scripts/load_fact_data.sh'");
	print factMasterScript "sqlldr tm_lz/tm_lz control=control_files/observationFact.ctl log=logFiles/observation_fact.log";
	close factMasterScript;
}

sub generatePatientDimensionControlFile
{
	my ($params) = @_;

	open patient_dimension_control_file, ">$basePath/control_files/patientDimension.ctl";
	
	print patient_dimension_control_file "load data\n";
	print patient_dimension_control_file "infile '../data/i2b2_load_tables/patient_dimension'\n";
	print patient_dimension_control_file "into table TM_LZ.PATIENT_DIMENSION\n";
	print patient_dimension_control_file 'fields terminated by "\t" TRAILING NULLCOLS' . "\n";
	print patient_dimension_control_file $params->{PATIENT_DIMENSION_COLUMNS};
	
	close patient_dimension_control_file;
}

sub generateConceptDimensionControlFile
{
	my ($params) = @_;

	open concept_dimension_control_file, ">$basePath/control_files/conceptDimension.ctl";
	
	print concept_dimension_control_file "load data\n";
	print concept_dimension_control_file "infile '../data/i2b2_load_tables/concept_dimension'\n";
	print concept_dimension_control_file "into table TM_LZ.CONCEPT_DIMENSION\n";
	print concept_dimension_control_file 'fields terminated by "\t" TRAILING NULLCOLS' . "\n";
	print concept_dimension_control_file $params->{CONCEPT_DIMENSION_COLUMNS};
	
	close concept_dimension_control_file;
}

sub generateObservationFactControlFile
{
	my ($params) = @_;

	open observation_fact_control_file, ">$basePath/control_files/observationFact.ctl";
	
	print observation_fact_control_file "load data\n";
	print observation_fact_control_file "infile '../data/i2b2_load_tables/observation_fact'\n";
	print observation_fact_control_file "into table TM_LZ.OBSERVATION_FACT\n";
	print observation_fact_control_file 'fields terminated by "\t" TRAILING NULLCOLS' . "\n";
	print observation_fact_control_file $params->{OBSERVATION_FACT_COLUMNS};
	
	close observation_fact_control_file;
}

1;