#!/usr/bin/perl

package ObservationFactFile;

#use strict;
#use warnings;
use Carp;
use UUID::Generator::PurePerl;
use Data::Dumper;
use List::Util qw(first);
use Scalar::Util qw(looks_like_number);

###########################################
#OBSERVATION_FACT FILE
###########################################
sub generateObservationFactFile 
{

	print("*************************************************************\n");
	print("ObservationFactFile.pm\n");
	print("*************************************************************\n");

	my ($params) = @_;

	my $configurationObject			= $params->{CONFIGURATION_OBJECT};

	my $patientHash 				= $params->{PATIENT_HASH};
	
	#Pull the hashes into an easier to use variable.
	my $variantNumericConcepts 		= $params->{VARIANT_NUMERIC_CONCEPTS};
	my $individualNumericConcepts 	= $params->{INDIVIDUAL_NUMERIC_CONCEPTS};
	my $variantTextConcepts 		= $params->{VARIANT_TEXT_CONCEPTS};
	my $individualTextConcepts 		= $params->{INDIVIDUAL_TEXT_CONCEPTS};
	
	my $observation_fact_output_file	= $configurationObject->{OBSERVATION_FACT_OUT_FILE};
	my $inputDataDirectory 				= $configurationObject->{PATIENT_DATA_DIRECTORY};
	my $variantDataDirectory			= $configurationObject->{VARIANT_DATA_DIRECTORY};
	my $variantDataFile					= $configurationObject->{VARIANT_DATA_FILE};

	#To speed things up later on down the line we will remove the need to split part of the concept info.
	while(my($columnName, $subHash) = each %$individualTextConcepts) 
	{ 	
		while(my($columnValue, $conceptInfo) = each %$subHash) 
		{ 
			my @conceptPathIdSplit = split(/!!!/,$conceptInfo);
			
			$subHash->{$columnValue} = $conceptPathIdSplit[1];
		}
	}

	while(my($columnName, $subHash) = each %$variantTextConcepts) 
	{ 	
		while(my($columnValue, $conceptInfo) = each %$subHash) 
		{ 
			my @conceptPathIdSplit = split(/!!!/,$conceptInfo);
			
			$subHash->{$columnValue} = $conceptPathIdSplit[1];
		}
	}

	#This is ugly, but, we need to retrieve all the encounter numbers we might need. We may not use all of them (As not all patients have all variants) but we'll assume patient concepts + (variant concepts * patient count).
	my $encounterIdCounter = 0;
	
	#This system command will count the number of lines in the variant file.
	my $lines = `/usr/bin/wc -l $variantDataFile`;

	die("Could not run wc!\n") if !defined($lines);	
	chomp $lines;$lines =~ s/^\s+//;
	my @countArray = split(/\s/, $lines);
	my $totalVariantCount += ($countArray[0] - 1);
	
	$encounterIdCounter += keys %$patientHash;
	$encounterIdCounter *= $totalVariantCount;
	$encounterIdCounter += keys %$individualNumericConcepts;

	print("DEBUG - ObservationFactFile.pm : Gathering $encounterIdCounter new Encounter Nums\n");

	my $encounterIdArray = ObservationFact::getNewEncounterIdList($encounterIdCounter, $configurationObject);		

	my %variantPatientHashArray	= ();

	print("DEBUG - ObservationFactFile.pm : Attemping to open data directory $inputDataDirectory\n");

	#Open the directory with annotated genomic files.
	opendir(D, $inputDataDirectory) || die "Can't opedir: $!\n";
	
	print("DEBUG - ObservationFactFile.pm : Attemping to open output file $observation_fact_output_file\n");
	open observation_fact, ">$observation_fact_output_file";

	print observation_fact ObservationFact->printColumnHeaders();

	while (my $f = readdir(D)) 
	{
		 if($f =~ m/(.*)\.annotated_vcf$/)
		 {
			my $currentID = $configurationObject->{SUBJECT_PREFIX} . $1;
			
			print("DEBUG - ObservationFactFile.pm : Working on patient file $currentID\n");
			
			open currentPatientANNOVARFile, "<$inputDataDirectory$f";

			my $header = <currentPatientANNOVARFile>;
			
			chomp($header);
			
			my @headerArray = split(/\t/,$header);
			
			my %headerHash;
			@headerHash{@headerArray} = 0..$#headerArray;
			
			while (<currentPatientANNOVARFile>)
			{
				chomp($_);
				
				#Split the line from the ANNOVAR file.
				my @line = split(/\t/,$_);
				
				my $currentEncounterId = shift @$encounterIdArray;

				#Add an observation fact record for each numeric concept.
				while(my($columnName, $conceptCd) = each %$individualNumericConcepts) 
				{ 	
					if(looks_like_number($line[$headerHash{$columnName}]))
					{
						#("UPLOAD_ID", "UNITS_CD", "CONCEPT_CD", "VALTYPE_CD", "TVAL_CHAR", "NVAL_NUM", "UPDATE_DATE", "END_DATE", "VALUEFLAG_CD", "ENCOUNTER_NUM", "PATIENT_NUM", "OBSERVATION_BLOB", "LOCATION_CD", "START_DATE", "QUANTITY_NUM", "SOURCESYSTEM_CD", "PROVIDER_ID", "INSTANCE_NUM", "MODIFIER_CD", "DOWNLOAD_DATE", "CONFIDENCE_NUM");
						print observation_fact "\t\t$conceptCd\tN\t\t$line[$headerHash{$columnName}]\t\t\t\t$currentEncounterId\t$patientHash->{$currentID}\t\t\t\t\tWES_LOADING\t@\t1\t\t\t\n";

						#So that we can build more observation fact records later we take note of all the variant + patient combinations.
						$variantPatientHashArray{$line[0]}{$patientHash->{$currentID}} = $currentEncounterId;						
					}
				}
				
				#For the text concepts we need to look up the concept code based on the actual value the patient has.
				while(my($columnName, $subHash) = each %$individualTextConcepts) 
				{ 					
					if(length($line[$headerHash{$columnName}]) < 255)
					{
						my $conceptCd = $subHash->{$line[$headerHash{$columnName}]};
					
						if($conceptCd eq '')
						{
							#die("Couldn't find a Concept Code for this concept - $columnName - $headerHash{$columnName} - $line[$headerHash{$columnName}]");
							#print("Couldn't find a Concept Code for this concept - $columnName - $headerHash{$columnName} - $line[$headerHash{$columnName}]\n");
						}
											
						#("UPLOAD_ID", "UNITS_CD", "CONCEPT_CD", "VALTYPE_CD", "TVAL_CHAR", "NVAL_NUM", "UPDATE_DATE", "END_DATE", "VALUEFLAG_CD", "ENCOUNTER_NUM", "PATIENT_NUM", "OBSERVATION_BLOB", "LOCATION_CD", "START_DATE", "QUANTITY_NUM", "SOURCESYSTEM_CD", "PROVIDER_ID", "INSTANCE_NUM", "MODIFIER_CD", "DOWNLOAD_DATE", "CONFIDENCE_NUM");
						print observation_fact "\t\t$conceptCd\tT\t$line[$headerHash{$columnName}]\t\t\t\t\t$currentEncounterId\t$patientHash->{$currentID}\t\t\t\t\tWES_LOADING\t@\t1\t\t\t\n";
						
						#So that we can build more observation fact records later we take note of all the variant + patient combinations.
						$variantPatientHashArray{$line[0]}{$patientHash->{$currentID}} = $currentEncounterId;
					}
					
				}
			}
		
			close currentPatientANNOVARFile;
		 }
	}
	
	closedir(D);
	
	#The outmost iterator will be the variant file.
	print("DEBUG - ObservationFactFile.pm : Attemping to open variant input file $variantDataFile\n");
	open variant_data, "<$variantDataFile";
	
	my $header = <variant_data>;
	my @headerArray = split(/\t/,$header);

	my %headerHash;
	@headerHash{@headerArray} = 0..$#headerArray;
	
	my $testCounter = 0;
	
	#Each line of the variant data file.
	while (<variant_data>)
	{
		chomp($_);
		my @line = split(/\t/,$_);
	
		my $currentVariant = $line[0];

		while(my($columnName, $conceptCd) = each %$variantNumericConcepts) 
		{ 
			while(my($patientId, $encounterNum) = each %{ $variantPatientHashArray{$currentVariant}}) 
			{ 	
				if(looks_like_number($line[$headerHash{$columnName}]))
				{
					$testCounter += 1;
					print observation_fact "\t\t$conceptCd\tN\t\t$line[$headerHash{$columnName}]\t\t\t\t$encounterNum\t$patientId\t\t\t\t\tWES_LOADING\t@\t1\t\t\t\n";
				}
			}
		}

		while(my($columnName, $subHash) = each %$variantTextConcepts) 
		{ 
			if(length($line[$headerHash{$columnName}]) < 255)
			{
				my $conceptCd = $subHash->{$line[$headerHash{$columnName}]};
		
				if($conceptCd eq '')
				{
					#die("Couldn't find a Concept Code for this concept - $columnName - $headerHash{$columnName} - $line[$headerHash{$columnName}]");
					#print("Couldn't find a Concept Code for this concept - $columnName - $headerHash{$columnName} - $line[$headerHash{$columnName}]\n");
				}
				else
				{
					while(my($patientId, $encounterNum) = each %{ $variantPatientHashArray{$currentVariant}}) 
					{ 	
						$testCounter += 1;
						print observation_fact "\t\t$conceptCd\tT\t$line[$headerHash{$columnName}]\t\t\t\t\t$encounterNum\t$patientId\t\t\t\t\tWES_LOADING\t@\t1\t\t\t\n";
					}
				}
			}

		}
	
	}
	close variant_data;
	
	close(observation_fact);
	
	print "$testCounter\n";
	
	print("*************************************************************\n");
	print("\n");
}

###########################################

1;