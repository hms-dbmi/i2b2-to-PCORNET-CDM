#!/usr/bin/perl

package ObservationFactFile;

#use strict;
#use warnings;
use Carp;
use UUID::Generator::PurePerl;
use Data::Dumper;
use List::Util qw(first);

###########################################
#OBSERVATION_FACT FILE
###########################################
sub generateObservationFactFile 
{
	my ($params) = @_;

	my $patientHash 	= $params->{PATIENT_HASH};
	my $individualHash 	= $params->{INDIVIDUAL_CONCEPTS};
	my $variantHash 	= $params->{VARIANT_CONCEPTS};

	my $observation_fact_output_file	= $params->{BASE_DIRECTORY} . "data/i2b2_load_tables/observation_fact";
	my $inputDataDirectory 				= $params->{BASE_DIRECTORY} . "data/source/patient_data/";
	my $variantDataDirectory			= $params->{BASE_DIRECTORY} . "data/source/variant_data/";

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
			my $currentID = $1;
			
			print("DEBUG - ObservationFactFile.pm : Working on patient file $currentID\n");
			
			open currentPatientANNOVARFile, "<$inputDataDirectory$f";

			my $header = <currentPatientANNOVARFile>;
			
			my @headerArray = split(/\t/,$header);
			
			my %headerHash;
			@headerHash{@headerArray} = 0..$#headerArray;
			
			while (<currentPatientANNOVARFile>)
			{
				#Split the line from the ANNOVAR file.
				my @line = split;
		
				#Per mapping file we need to loop through the concepts and extract them out. For now this will only function on a default patient file.
				while(my($k, $v) = each %$individualHash) 
				{ 
					while(my($conceptCd, $columnName) = each %$v) 
					{ 	
						#These are too slow to call all the time.				
						#my $observationFact = new ObservationFact(PATIENT_NUM => $patientHash->{$currentID}, CONCEPT_CD => $conceptCd, TVAL_CHAR => $line[$headerHash{$columnName}+1]);
						#print observation_fact $observationFact->toTableFileLine();
						#("UPLOAD_ID", "TEXT_SEARCH_INDEX", "UNITS_CD", "CONCEPT_CD", "VALTYPE_CD", "TVAL_CHAR", "NVAL_NUM", "UPDATE_DATE", "END_DATE", "VALUEFLAG_CD", "ENCOUNTER_NUM", "PATIENT_NUM", "OBSERVATION_BLOB", "LOCATION_CD", "START_DATE", "QUANTITY_NUM", "SOURCESYSTEM_CD", "PROVIDER_ID", "INSTANCE_NUM", "MODIFIER_CD", "DOWNLOAD_DATE", "CONFIDENCE_NUM");
						#print observation_fact "\t\t\t$conceptCd\tT\t$line[$headerHash{$columnName}+1]\t\t\t\t\t1\t$patientHash->{$currentID}\t\t\t\t\tWES_LOADING\t\t\t\t\t\n";

						#So that we can build more observation fact records later we take note of all the variant + patient combinations.
						$variantPatientHashArray{$line[0]}{$patientHash->{$currentID}} = undef;
					}
					
				}
				
			}
		
			close currentPatientANNOVARFile;
		 }
	}
	
	closedir(D);
	
	#The outmost iterator will be the variant file.
	print("DEBUG - ObservationFactFile.pm : Attemping to open variant input file $variantDataDirectory\n");
	open variant_data, "<$variantDataDirectory/i2b2_55sample_allVariantAnnotations.txt";
	
	my $header = <variant_data>;
	my @headerArray = split(/\t/,$header);

	my %headerHash;
	@headerHash{@headerArray} = 0..$#headerArray;

	#Each line of the variant data file.
	while (<variant_data>)
	{

		my @line = split;
	
		my $currentVariant = $line[0];
	
		#Each variant mapping file.
		while(my($k, $v) = each %$variantHash) 
		{
			#Each variant in mapping file.
			while(my($conceptCd, $columnName) = each %$v) 
			{ 

				#All the patients with this variant.
				while(my($patientId, $dummyColumn) = each %{ $variantPatientHashArray{$currentVariant}}) 
				{ 				
					print observation_fact "\t\t\t$conceptCd\tT\t$line[$headerHash{$columnName}+1]\t\t\t\t\t1\t$patientId\t\t\t\t\tWES_LOADING\t\t\t\t\t\n";
				}
			}
		}
	
	}
	close variant_data;
	
	close(observation_fact);
}



###########################################



# 
# 				for my $i (0 .. @conceptList-1)
# 				{	
# 					#Find out which column we need to extract the mapping from.
# 					my $variableColumn = $conceptList[$i]->{VARIANT_FILE_VARIABLE_COLUMN};
# 					
# 					#Find out which column we need to extract the value from.
# 					my $valueColumn = $conceptList[$i]->{VARIANT_FILE_VALUE_COLUMN};
# 
# 					#When the mapping and value field are the same we parse just that one field.
# 					if($variableColumn eq $valueColumn)
# 					{
# 						#Get the name of the variable and the delimiter we are using.
# 						my $variableName 		= $conceptList[$i]->{VARIABLE_NAME};
# 						my $variableDelimiter 	= $conceptList[$i]->{COLUMN_DELIMITER};
# 													
# 						#Create the regular expression to extract the value for the concept.
# 						my $regularExpression = "$variableName([^$variableDelimiter]*)";
# 
# 						#Extract the value we are interested in out of the data column.
# 						if($line[$variableColumn-1] =~ m/$regularExpression/)
# 						{
# 							#The first match is the value we are after. Some values are just a true/false, so if $1 is blank at this point it was found and it's true.
# 							my $retrievedValue = $1 // "TRUE";
# 							
# 							my $observationFact 	= new ObservationFact(PATIENT_NUM => $patientHash->{$currentID}, CONCEPT_CD => $conceptList[$i]->{CONCEPT_CD}, TVAL_CHAR => $retrievedValue);
# 							print observation_fact $observationFact->toTableFileLine(); 
# 						}
# 					}
# 					else
# 					{
# 						my $variableName 			= $conceptList[$i]->{VARIABLE_NAME};
# 						my $variableDelimiter 		= $conceptList[$i]->{COLUMN_DELIMITER};
# 					
# 						#If the mapping and value fields are different we need to parse two columns.
# 						my @parsedVariableColumn 	= split(/$variableDelimiter/,$line[$variableColumn-1]);
# 						
# 						#We need to look for the index of the entry in the delimited field that matches our variable name.
# 						my $variableIndex = first { $parsedVariableColumn[$_] eq $variableName } 0..$#parsedVariableColumn;
# 						$variableIndex = $variableIndex  // -1;
# 						
# 						if($variableIndex >= 0)
# 						{
# 							#Okay, we've found the index of where the value should be in the value column, parse the value.
# 							my @parsedValueColumn		= split(/$variableDelimiter/,$line[$valueColumn-1]);
# 							my $retrievedValue			= $parsedValueColumn[$variableIndex];
# 							
# 							my $observationFact 	= new ObservationFact(PATIENT_NUM => $patientHash->{$currentID}, CONCEPT_CD => $conceptList[$i]->{CONCEPT_CD}, TVAL_CHAR => $retrievedValue);
# 							
# 							print observation_fact $observationFact->toTableFileLine(); 														
# 						}
# 					}
# 				}



1;