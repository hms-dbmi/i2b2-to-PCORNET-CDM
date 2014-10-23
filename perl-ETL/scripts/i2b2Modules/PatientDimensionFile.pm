#!/usr/bin/perl

package PatientDimensionFile;

use strict;
use warnings;
use Carp;
use Data::Dumper;
use DBI;
use Text::CSV;

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

	my $inputDataDirectory 				=	$configurationObject->{PATIENT_DATA_DIRECTORY};
	my $patient_dimension_output_file	=	$configurationObject->{PATIENT_DIMENSION_OUT_FILE};
	my $patient_mapping_output_file		=	$configurationObject->{PATIENT_MAPPING_OUT_FILE};	
	my $factSet							=	$configurationObject->{FACT_SET};

	print("DEBUG - PatientDimensionFile.pm - Count number of patients.\n");

	#In order to get the count of patients we need to parse through the patient files, find the SUBJECT_ID column and create a distinct list.
	
	#Open the mapping files.
	my %mappingFileHash = tranSMARTTextParsing::generateMasterMappingHash($configurationObject->{BASE_PATH});
	my $subjectIDHash;
	
	while(my($k, $v) = each %mappingFileHash) 
	{
		$subjectIDHash = _extractPatientList($configurationObject, $k, $inputDataDirectory);
	}

	my $count = keys %$subjectIDHash;

	print("DEBUG - PatientDimensionFile.pm - Found $count patients.\n");
	
	my $patientSubjectHash	= DatabaseConnection::getPatientSubjectHash($configurationObject);
	my @patientIdArray 		= PatientDimension::getNewPatientIdList($count, $configurationObject);

	print("DEBUG - PatientDimensionFile.pm : Attemping to open data directory $inputDataDirectory\n");

	opendir(D, $inputDataDirectory) || die "Can't opedir: $!\n";
	
	print("DEBUG - PatientDimensionFile.pm : Attemping to open output file $patient_dimension_output_file\n");
	print("DEBUG - PatientDimensionFile.pm : Attemping to open output file $patient_mapping_output_file\n");
	
	open patient_dimension, ">$patient_dimension_output_file" || die "Can't open patient_dimension_output_file ($patient_dimension_output_file) : $!\n";
	open patient_mapping_output_file, ">$patient_mapping_output_file" || die "Can't open patient_mapping_output_file ($patient_mapping_output_file) : $!\n";	

	print patient_dimension PatientDimension->printColumnHeaders();
	
	while(my($subjectID, $subjectPlaceholder) = each %$subjectIDHash) 
	{
		if(!exists $patientSubjectHash->{$subjectID})
		{
			my $nextPatientId = shift @patientIdArray;

			$patientHash{$subjectID} = $nextPatientId;

			my $patientDimension = new PatientDimension(PATIENT_NUM => $nextPatientId, SOURCESYSTEM_CD => $subjectID);
			print patient_dimension $patientDimension->toTableFileLine();    
			
			my $patientMapping = new PatientMapping(PATIENT_NUM => $nextPatientId, PATIENT_IDE => $subjectID, PATIENT_IDE_SOURCE => $factSet, SOURCESYSTEM_CD => 'AUTISM');
			print patient_mapping_output_file $patientMapping->toTableFileLine();   	
	
			$patientCounter = $patientCounter + 1;
			
			#print("DEBUG - PatientDimensionFile.pm : Creating New Subject - $subjectID\n");

		}
		else
		{
			$patientHash{$subjectID} = $patientSubjectHash->{$subjectID};
			
			#print("DEBUG - PatientDimensionFile.pm : Using existing Subject - $subjectID\n");
		}
	}

	
	closedir(D);
	close(patient_dimension);
	close(patient_mapping_output_file);
	
	print("*************************************************************\n");
	print("\n");
	
	return \%patientHash;
}


sub _extractPatientList {
	my $configurationObject 	= shift;
	my $currentMappingFile 		= shift;
	my $dataDirectoryToParse	= shift;
	my $subjectIdColumn			= "";
	
	my %idHash					= ();
	
	
	my $field_mapping_file = $configurationObject->{BASE_PATH} . "mapping_files/$currentMappingFile";

	print("DEBUG - PatientDimensionFile.pm : Attemping to open mapping file $field_mapping_file\n");

	open field_mapping, "<$field_mapping_file" || die "Can't opedir: $!\n";;

	my $header 					= <field_mapping>;

	while (<field_mapping>)
	{
		my $line = $_;
	
		#Clean Input line.
		chomp($line);

		if($line =~ m/^([^\t]+)\t([^\t]+)\t([^\t]+)/)
		{
			#Gather all the text elements from the mapping file.
			if($3 eq "SUBJECT_ID")
			{
				$subjectIdColumn = $1;
				last;
			}

		}
	}

	close(field_mapping);
	
	if($subjectIdColumn eq ""){die("Could not find SUBJECT_ID field!");}
	
	my $currentStrippedFileName = $currentMappingFile;
	$currentStrippedFileName =~ s/\.map$//;
	
	print("DEBUG - PatientDimensionFile.pm : Attemping to open data file $dataDirectoryToParse$currentStrippedFileName\n");
	
	my $currentPatientFile;
	
	my $csv = Text::CSV->new ( { binary => 1, sep_char => "\t" } ) or die "Cannot use CSV: ".Text::CSV->error_diag ();
	
	if(open $currentPatientFile, "<$dataDirectoryToParse$currentStrippedFileName")
	{
		my %headerHash;
		
		my $dataHeader = $csv->getline( $currentPatientFile );

		#Make a hash so we know the column index for each of our column names.
		my $headerCount = @$dataHeader;
		
		for (my $i=0; $i < $headerCount; $i++) 
		{
	   		$headerHash{@$dataHeader[$i]} = $i;
		}

		#For every line we grab the unique values for our subject ID hash.
		while (my $row = $csv->getline( $currentPatientFile ))
		{	
			if(!(exists $headerHash{$subjectIdColumn})) {die("Could not map a header to an entry in the mapping file! $subjectIdColumn");}

			$idHash{$row->[$headerHash{$subjectIdColumn}]} = 1;

		}
	}
	else
	{
		#print("DEBUG - PatientDimensionFile.pm : Couldn't find file! $dataDirectoryToParse$currentStrippedFileName\n");
	}
	
	close $currentPatientFile;
	

	return \%idHash;	

}


###########################################

1;