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
	
	my $configurationObject = shift;
	
	my %patientHash = ();

	#We will use this to reference entries in the array that has the new patient ids.
	my $patientCounter = 0;

	#This directory should house the individuals genomic variant files.
	my $inputDataDirectory 				=	$configurationObject->{PATIENT_DATA_DIRECTORY};
	my $patient_dimension_output_file	=	$configurationObject->{PATIENT_DIMENSION_OUT_FILE};

	print("DEBUG - PatientDimensionFile.pm - Count number of input files.\n");

	my @files = <$inputDataDirectory/*>;
	my $count = @files;

	print("DEBUG - PatientDimensionFile.pm - Found $count files.\n");
	
	my $patientSubjectHash	= DatabaseConnection::getPatientSubjectHash($configurationObject);
	my @patientIdArray 		= PatientDimension::getNewPatientIdList($count, $configurationObject);

	print("DEBUG - PatientDimensionFile.pm : Attemping to open data directory $inputDataDirectory\n");

	#Open the directory with annotated genomic files.
	opendir(D, $inputDataDirectory) || die "Can't opedir: $!\n";
	
	print("DEBUG - PatientDimensionFile.pm : Attemping to open output file $patient_dimension_output_file\n");
	
	open patient_dimension, ">$patient_dimension_output_file" || die "Can't open patient_dimension_output_file ($patient_dimension_output_file) : $!\n";

	print patient_dimension PatientDimension->printColumnHeaders();

	while (my $f = readdir(D)) 
	{
		 if($f =~ m/(.*)$configurationObject->{PATIENT_FILE_SUFFIX}$/)
		 {
			my $currentID = $configurationObject->{SUBJECT_PREFIX} . $1;
			
			if(!exists $patientSubjectHash->{$currentID})
			{
				my $nextPatientId = shift @patientIdArray;
		
				$patientHash{$currentID} = $nextPatientId;
		
				my $patientDimension = new PatientDimension(PATIENT_NUM => $nextPatientId, SOURCESYSTEM_CD => $currentID);
				print patient_dimension $patientDimension->toTableFileLine();     	
			
				$patientCounter = $patientCounter + 1;

	 		}
	 		else
	 		{
	 			print("DEBUG - PatientDimensionFile.pm : Using existing Subject - $currentID\n");
	 			$patientHash{$currentID} = $patientSubjectHash->{$currentID};
	 		}
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