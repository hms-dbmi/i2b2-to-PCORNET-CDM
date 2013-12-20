#!/usr/bin/perl

package PatientDimensionFile;

use strict;
use warnings;
use Carp;
use Data::Dumper;
use DBI;

###########################################
#PATIENT_DIMENSION FILE
###########################################
sub generatePatientDimensionFile
{
	print("*************************************************************\n");
	print("PatientDimensionFile.pm\n");
	print("*************************************************************\n");
	
	my ($params) = @_;
	
	my %patientHash = ();

	#We will use this to reference entries in the array that has the new patient ids.
	my $patientCounter = 0;

	#This directory should house the individuals genomic variant files.
	my $inputDataDirectory 				=  $params->{BASE_DIRECTORY} . "data/source/patient_data/";
	my $patient_dimension_output_file	=  $params->{BASE_DIRECTORY} . "data/i2b2_load_tables/patient_dimension.dat";

	print("DEBUG - PatientDimensionFile.pm - Count number of input files.\n");
	
	my @files = <$inputDataDirectory/*>;
	my $count = @files;

	print("DEBUG - PatientDimensionFile.pm - Found $count files.\n");

	my @patientIdArray = PatientDimension::getNewPatientIdList($count);

	print("DEBUG - PatientDimensionFile.pm : Attemping to open data directory $inputDataDirectory\n");

	#Open the directory with annotated genomic files.
	opendir(D, $inputDataDirectory) || die "Can't opedir: $!\n";
	
	print("DEBUG - PatientDimensionFile.pm : Attemping to open output file $patient_dimension_output_file\n");
	
	open patient_dimension, ">$patient_dimension_output_file" || die "Can't open patient_dimension_output_file ($patient_dimension_output_file) : $!\n";

	print patient_dimension PatientDimension->printColumnHeaders();

	while (my $f = readdir(D)) 
	{
		 if($f =~ m/(.*)\.annotated_vcf$/)
		 {
			my $currentID = $1;
		
			my $nextPatientId = shift @patientIdArray;
		
			$patientHash{$currentID} = $nextPatientId;
		
			my $patientDimension = new PatientDimension(PATIENT_NUM => $nextPatientId, SOURCESYSTEM_CD => $currentID);
			print patient_dimension $patientDimension->toTableFileLine();     	
			
	 		$patientCounter = $patientCounter + 1;
		 }
	}
	
	closedir(D);
	close(patient_dimension);
	
	print("*************************************************************\n");
	print("\n");
	
	return \%patientHash;
}
###########################################

1;