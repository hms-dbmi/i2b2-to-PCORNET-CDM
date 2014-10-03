#!/usr/bin/perl

package tranSMARTTextParsing;

use strict;
use warnings;
use Data::Dumper;

sub generateMasterMappingHash {
	
	my $basePath = shift;
	
	my %mappingFileHash = ();
	
	my $masterMappingFile = $basePath . "mapping_files/master_mapping";
	
	print("DEBUG - tranSMARTTextParsing.pm : Attemping to open master mapping file $masterMappingFile\n");
	
	open master_mapping, "<$masterMappingFile"; 
	my $header = <master_mapping>;

	while (<master_mapping>)
	{	
		my $line = $_;
		chomp $line;
		if($line =~ m/^([^\t]+)\t([^\t]+)/)
		{
			$mappingFileHash{$1} = $2
		}
	}
	
	print("\n");
	
	return %mappingFileHash;

}

sub countHashLeaves {

	my $hashToCount = shift;
	
	my $leafCounter = 0;
	
	while(my($key, $subHash) = each %$hashToCount) 
	{
		$leafCounter += keys %$subHash;
	}
	
	return $leafCounter;

}

sub generateConfigObjectFromFile {

	my $configFile = shift;
	my $debugFlag = shift;
	
	my %configHash;
							
	print("DEBUG - tranSMARTTextParsing.pm : Attemping to open configuration file $configFile\n");							
	
	open master_mapping, "<$configFile"; 
	while (<master_mapping>)
	{	
		my $line = $_;
		
		chomp $line;
		
		if($line =~ m/^([^\t#]+)\t"([^\t]+)"/)
		{
			$configHash{$1} = $2;
			
		}
	}
	
	my $configObject = new configurationObject(
						BASE_PATH 					=> $configHash{'BASE_PATH'}, 
						STUDY_ID 					=> $configHash{'STUDY_ID'},
						PATIENT_DATA_DIRECTORY		=> $configHash{'PATIENT_DATA_DIRECTORY'},
						MAPPING_FILE_DIRECTORY		=> $configHash{'MAPPING_FILE_DIRECTORY'},
						CONCEPT_DIMENSION_OUT_FILE 	=> $configHash{'CONCEPT_DIMENSION_OUT_FILE'},
						PATIENT_DIMENSION_OUT_FILE	=> $configHash{'PATIENT_DIMENSION_OUT_FILE'},
						I2B2_OUT_FILE				=> $configHash{'I2B2_OUT_FILE'},
						OBSERVATION_FACT_OUT_FILE	=> $configHash{'OBSERVATION_FACT_OUT_FILE'},
						CONCEPT_COUNT_OUT_FILE		=> $configHash{'CONCEPT_COUNT_OUT_FILE'},
						SUBJECT_PREFIX				=> $configHash{'SUBJECT_PREFIX'},
						SQLLDR_LOGIN_STRING			=> $configHash{'SQLLDR_LOGIN_STRING'},
						DATABASE_CONNECTION_STRING	=> $configHash{'DATABASE_CONNECTION_STRING'},
						DATABASE_USERNAME			=> $configHash{'DATABASE_USERNAME'},
						DATABASE_PASSWORD			=> $configHash{'DATABASE_PASSWORD'},
						PATIENT_FILE_SUFFIX			=> $configHash{'PATIENT_FILE_SUFFIX'},
						FACT_SET					=> $configHash{'FACT_SET'},						
						DEBUG						=> $debugFlag);
	
	return $configObject;

}

1;