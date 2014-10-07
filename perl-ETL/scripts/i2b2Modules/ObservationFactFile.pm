#!/usr/bin/perl

package ObservationFactFile;

#use strict;
#use warnings;
use Carp;
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
	my $individualNumericConcepts 	= $params->{INDIVIDUAL_NUMERIC_CONCEPTS};
	my $individualTextConcepts 		= $params->{INDIVIDUAL_TEXT_CONCEPTS};
	
	my $observation_fact_output_file	= $configurationObject->{OBSERVATION_FACT_OUT_FILE};
	my $inputDataDirectory 				= $configurationObject->{PATIENT_DATA_DIRECTORY};
	
	my $factSet							= $configurationObject->{FACT_SET};

	my %conceptPatientHash;
	my %conceptHash;

	print("DEBUG - ObservationFactFile.pm : Attemping to open data file $dataDirectoryToParse$currentStrippedFileName\n");

	#To speed things up later on down the line we will remove the need to split part of the concept info.
	while(my($columnName, $subHash) = each %$individualTextConcepts) 
	{ 	
		while(my($columnValue, $conceptInfo) = each %$subHash) 
		{ 
			my @conceptPathIdSplit = split(/!!!/,$conceptInfo);
			
			$subHash->{$columnValue} = $conceptPathIdSplit[1];
			$conceptHash->{$conceptPathIdSplit[1]} = $conceptPathIdSplit[0];
		}
	}

	while(my($columnName, $conceptInfo) = each %$individualNumericConcepts) 
	{ 	
		my @conceptPathIdSplit = split(/!!!/,$conceptInfo);
		$conceptHash->{$conceptPathIdSplit[1]} = $conceptPathIdSplit[0];
		$individualNumericConcepts->{$columnName} = $conceptPathIdSplit[1];
	}

	#This is ugly, but, we need to retrieve all the encounter numbers we might need. We may not use all of them (As not all patients have all variants) but we'll assume patient concepts + (variant concepts * patient count).
	my $encounterIdCounter = 0;
	
	#This system command will count the number of lines in the variant file.
	
	my $numericConceptCount = keys %$individualNumericConcepts;
	my $textConceptCount = keys %$individualTextConcepts;
	my $totalConceptCount = $numericConceptCount + $textConceptCount;
	
	$encounterIdCounter += keys %$patientHash;
	$encounterIdCounter *= $totalConceptCount;	

	print("DEBUG - ObservationFactFile.pm : Gathering $encounterIdCounter new Encounter Nums\n");

	my $encounterIdArray = ObservationFact::getNewEncounterIdList($encounterIdCounter, $configurationObject);		

	my $fileSubjectColumnHash = getSubjectColumns($configurationObject);

	print("DEBUG - ObservationFactFile.pm : Attemping to open data directory $inputDataDirectory\n");

	#Open the directory with annotated genomic files.
	opendir(D, $inputDataDirectory) || die "Can't opedir: $!\n";
	
	print("DEBUG - ObservationFactFile.pm : Attemping to open output file $observation_fact_output_file\n");
	open observation_fact, ">$observation_fact_output_file";

	print observation_fact ObservationFact->printColumnHeaders();

	while (my $f = readdir(D)) 
	{
		 if($f =~ m/(.*)\.txt$/)
		 {
			
			print("DEBUG - ObservationFactFile.pm : Working on data file $f\n");
			
			open currentPatientFile, "<$inputDataDirectory$f";

			my $header = <currentPatientFile>;
			
			chomp($header);
			
			my @headerArray = split(/\t/,$header);
			
			my %headerHash;
			@headerHash{@headerArray} = 0..$#headerArray;
						
			while (<currentPatientFile>)
			{
				chomp($_);
				
				#Split the line from the ANNOVAR file.
				my @line = split(/\t/,$_);
				
				my $currentEncounterId 	= shift @$encounterIdArray;
				my $currentSubjectId	= $line[$headerHash{$fileSubjectColumnHash->{$f . '.map'}}];

				if($patientHash->{$currentSubjectId} eq '') 
				{
					print("BAD RECORD");
				}

				#Add an observation fact record for each numeric concept.
				while(my($columnName, $conceptCd) = each %$individualNumericConcepts) 
				{ 	
					if(looks_like_number($line[$headerHash{$columnName}]))
					{
						#("UPLOAD_ID", "UNITS_CD", "CONCEPT_CD", "VALTYPE_CD", "TVAL_CHAR", "NVAL_NUM", "UPDATE_DATE", "END_DATE", "VALUEFLAG_CD", "ENCOUNTER_NUM", "PATIENT_NUM", "OBSERVATION_BLOB", "LOCATION_CD", "START_DATE", "QUANTITY_NUM", "SOURCESYSTEM_CD", "PROVIDER_ID", "INSTANCE_NUM", "MODIFIER_CD", "DOWNLOAD_DATE", "CONFIDENCE_NUM");
						print observation_fact "\t\t$conceptCd\tN\tE\t$line[$headerHash{$columnName}]\t\t\t\t$currentEncounterId\t$patientHash->{$currentSubjectId}\t\t\t\t\t$factSet\t@\t1\t\t\t\n";
												
						if(exists $conceptPatientHash{$conceptCd} )
						{
							$conceptPatientHash{$conceptCd}{$patientHash->{$currentSubjectId}} = undef;
						}
						else
						{
							$conceptPatientHash{$conceptCd} = { $patientHash->{$currentSubjectId} => undef}
						}

						#So that we can build more observation fact records later we take note of all the variant + patient combinations.
						$variantPatientHashArray{$line[0]}{$patientHash->{$currentSubjectId}} = $currentEncounterId;						
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
						print observation_fact "\t\t$conceptCd\tT\t$line[$headerHash{$columnName}]\t\t\t\t\t$currentEncounterId\t$patientHash->{$currentSubjectId}\t\t\t\t\t$factSet\t@\t1\t\t\t\n";
						
						#So that we can build more observation fact records later we take note of all the variant + patient combinations.
						$variantPatientHashArray{$line[0]}{$patientHash->{$currentSubjectId}} = $currentEncounterId;
	
						if(exists $conceptPatientHash{$conceptCd})
						{
							$conceptPatientHash{$conceptCd}{$patientHash->{$currentSubjectId}} = undef;
						}
						else
						{
							$conceptPatientHash{$conceptCd} = { $patientHash->{$currentSubjectId} => undef}
						}						
					}
					
				}
			}
		
			close currentPatientFile;
		 }
	}
	
	closedir(D);
	
	close(observation_fact);
	
	print "DEBUG - ObservationFactFile.pm : Creating count file.\n";
	
	open my $concept_count_out, 			">", $configurationObject->{CONCEPT_COUNT_OUT_FILE};
	open my $concepts_folders_patients_out, ">", $configurationObject->{CONCEPTS_FOLDERS_PATIENTS_OUT_FILE};
	
	my $longestConceptPath = 0;
	
	my %conceptPathPatientHash;
	
	#Get the count of patients for each concept.
	while(my($conceptCd, $subPatientHash) = each %conceptPatientHash)
	{
		my $conceptCount = keys %$subPatientHash;
		my $currentConcept = $conceptHash->{$conceptCd};
		my $parentConcept = $currentConcept;
		
		#Remove last step from path.
		$parentConcept =~ s/[^\\]*\\$//g;
		
		#Keep track of the longest concept path we put into the table.
		my $numberOfSteps = ($currentConcept =~ s/\\/\\/g);
		
		if($longestConceptPath < $numberOfSteps)
		{
			$longestConceptPath = $numberOfSteps;
		}

		my $conceptCountObject = new ConceptCount(CONCEPT_PATH => $currentConcept, PARENT_CONCEPT_PATH => $parentConcept, PATIENT_COUNT => $conceptCount);
		
		#Write the entry for the concept_dimension table.
		print $concept_count_out $conceptCountObject->toTableFileLine();

		#This is used later to build intermediate paths.
		if(exists $conceptPathPatientHash{$parentConcept})
		{
			@{$conceptPathPatientHash{$parentConcept}}{ keys %$subPatientHash } = values %$subPatientHash;
		}
		else
		{
			$conceptPathPatientHash{$parentConcept} = {};
			@{$conceptPathPatientHash{$parentConcept}}{ keys %$subPatientHash } = values %$subPatientHash;
		}
	}

	my $currentDepthFromBottom = 0;

	#We make a pass for each depth.
	while($currentDepthFromBottom < $longestConceptPath)
	{
		#Loop through all concepts.
		while(my($conceptPath, $subPatientHash) = each %conceptPathPatientHash)
		{
			my $currentConceptDepth = ($conceptPath =~ s/\\/\\/g);
			
			#If this path is the depth we are working on.
			if( ($currentConceptDepth == ($longestConceptPath - $currentDepthFromBottom)) && ($currentConceptDepth > 2) ) 
			{
				my $parentPath = $conceptPath;
				
				$parentPath =~ s/[^\\]*\\$//g;
				
				#For this level node we add path and the patient hash. We already have the patient hash in another hash so we gotta hash it out. hash. hash hash.
				if(exists $conceptPathPatientHash{$parentPath})
				{
					@{$conceptPathPatientHash{$parentPath}}{ keys %$subPatientHash } = values %$subPatientHash;
				}
				else
				{
					$conceptPathPatientHash{$parentPath} = {};
					@{$conceptPathPatientHash{$parentPath}}{ keys %$subPatientHash } = values %$subPatientHash;
				}
			
			}
		}
		
		$currentDepthFromBottom += 1;
	}
	

	#Loop through the hash and dump the contents to our concept count file.
	while(my($conceptPath, $patientHash) = each %conceptPathPatientHash)
	{	
		my $conceptCount = keys %$patientHash;
		my $parentConcept = $conceptPath;
		
		#Remove last step from path.
		$parentConcept =~ s/[^\\]*\\$//g;
		
		my $conceptCountObject = new ConceptCount(CONCEPT_PATH => $conceptPath, PARENT_CONCEPT_PATH => $parentConcept, PATIENT_COUNT => $conceptCount);
		
		#Write the entry for the concept_dimension table.
		print $concept_count_out $conceptCountObject->toTableFileLine();

		if($conceptPath ne "")
		{
			while(my($patientNum, $dummyValue) = each %$patientHash)
			{

				my $conceptsFoldersPatientsObject = new ConceptsFoldersPatients(CONCEPT_PATH => $conceptPath, PATIENT_NUM => $patientNum);
		
				#Write the entry for the concept_dimension table.
				print $concepts_folders_patients_out $conceptsFoldersPatientsObject->toTableFileLine();
			
			}
		}
	}

	close($concept_count_out);	
	close($concepts_folders_patients_out);
	
	print("*************************************************************\n");
	print("\n");
}

sub getSubjectColumns
{
	my $configurationObject 	= shift;

	my %mappingFileHash = tranSMARTTextParsing::generateMasterMappingHash($configurationObject->{BASE_PATH});
	my %fileSubjectColumnHash;
	
	while(my($fileName, $v) = each %mappingFileHash) 
	{
		my $field_mapping_file = $configurationObject->{BASE_PATH} . "mapping_files/$fileName";

		print("DEBUG - ObservatioNFactFile.pm : Attemping to open mapping file to get subject id column $field_mapping_file\n");

		open field_mapping, "<$field_mapping_file" || die "Can't opedir: $!\n";;

		my $header 	= <field_mapping>;

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
					$fileSubjectColumnHash{$fileName} = $1;
					last;
				}

			}

		}

	}
	
	return \%fileSubjectColumnHash;
}


###########################################

1;