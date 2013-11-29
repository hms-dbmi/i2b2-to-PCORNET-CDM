#!/usr/bin/perl

package PatientDimensionFile;

use strict;
use warnings;
use Carp;
use UUID::Generator::PurePerl;
use Data::Dumper;

###########################################
#PATIENT_DIMENSION FILE
###########################################
sub generatePatientDimensionFile
{
	my ($params) = @_;
	
	my %patientHash = ();
	my $uuid1;
	my $ug = UUID::Generator::PurePerl->new();

	#This directory should house the individuals genomic variant files.
	my $inputDataDirectory 				=  $params->{BASE_DIRECTORY} . "data/source/";
	my $patient_dimension_output_file	=  $params->{BASE_DIRECTORY} . "data/i2b2_load_tables/patient_dimension";

	print("DEBUG - PatientDimensionFile.pm : Attemping to open data directory $inputDataDirectory\n");

	#Open the directory with annotated genomic files.
	opendir(D, $inputDataDirectory) || die "Can't opedir: $!\n";
	
	print("DEBUG - PatientDimensionFile.pm : Attemping to open output file $patient_dimension_output_file\n");
	
	open patient_dimension, ">$patient_dimension_output_file";

	print patient_dimension PatientDimension->printColumnHeaders();

	while (my $f = readdir(D)) 
	{
		 if($f =~ m/(.*)\.annovar$/)
		 {
			my $currentID = $1;
			
			$uuid1 = $ug->generate_v1();
		
			$patientHash{$currentID} = $uuid1;
		
			my $patientDimension = new PatientDimension(PATIENT_NUM => $uuid1, SOURCESYSTEM_CD => $currentID);
			print patient_dimension $patientDimension->toTableFileLine();     	
	 
		 }
	}
	
	closedir(D);
	close(patient_dimension);
	
	return \%patientHash;
}
###########################################

1;