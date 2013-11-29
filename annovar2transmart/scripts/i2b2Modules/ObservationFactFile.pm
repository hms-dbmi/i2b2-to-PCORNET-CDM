#!/usr/bin/perl

package ObservationFactFile;

use strict;
use warnings;
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

	my $patientHash = $params->{PATIENT_HASH};
	my $conceptHash = $params->{CONCEPT_HASH};
	my @conceptList = @{$params->{CONCEPT_LIST}};

	my $observation_fact_output_file	= $params->{BASE_DIRECTORY} . "data/i2b2_load_tables/observation_fact";
	my $inputDataDirectory 				= $params->{BASE_DIRECTORY} . "data/source/";

	print("DEBUG - ObservationFactFile.pm : Attemping to open data directory $inputDataDirectory\n");

	#Open the directory with annotated genomic files.
	opendir(D, $inputDataDirectory) || die "Can't opedir: $!\n";
	
	print("DEBUG - ObservationFactFile.pm : Attemping to open output file $observation_fact_output_file\n");
	open observation_fact, ">$observation_fact_output_file";

	print observation_fact ObservationFact->printColumnHeaders();

	while (my $f = readdir(D)) 
	{
		 if($f =~ m/(.*)\.annovar$/)
		 {
			my $currentID = $1;
		
			open currentPatientANNOVARFile, "<$inputDataDirectory$f";

			my $header = <currentPatientANNOVARFile>;

			while (<currentPatientANNOVARFile>)
			{
				#Split the line from the ANNOVAR file.
				my @line = split;

				#Now, we need to extract columns based on the concept mappings we created earlier.
				while(my($k, $v) = each %$conceptHash) 
				{ 
					#The current value is the value of the concept that is referred to by its column index in the data file.
					my $currentValue = $line[$v-1];
				
					my $observationFact = new ObservationFact(PATIENT_NUM => $patientHash->{$currentID}, CONCEPT_CD => $k, TVAL_CHAR => $currentValue);

					print observation_fact $observationFact->toTableFileLine(); 				
				}
				
				for my $i (0 .. @conceptList-1)
				{	
					#Find out which column we need to extract the mapping from.
					my $variableColumn = $conceptList[$i]->{VARIANT_FILE_VARIABLE_COLUMN};
					
					#Find out which column we need to extract the value from.
					my $valueColumn = $conceptList[$i]->{VARIANT_FILE_VALUE_COLUMN};

					#When the mapping and value field are the same we parse just that one field.
					if($variableColumn eq $valueColumn)
					{
						#Get the name of the variable and the delimiter we are using.
						my $variableName 		= $conceptList[$i]->{VARIABLE_NAME};
						my $variableDelimiter 	= $conceptList[$i]->{COLUMN_DELIMITER};
													
						#Create the regular expression to extract the value for the concept.
						my $regularExpression = "$variableName([^$variableDelimiter]*)";

						#Extract the value we are interested in out of the data column.
						if($line[$variableColumn-1] =~ m/$regularExpression/)
						{
							#The first match is the value we are after. Some values are just a true/false, so if $1 is blank at this point it was found and it's true.
							my $retrievedValue = $1 // "TRUE";
							
							my $observationFact 	= new ObservationFact(PATIENT_NUM => $patientHash->{$currentID}, CONCEPT_CD => $conceptList[$i]->{CONCEPT_CD}, TVAL_CHAR => $retrievedValue);
							print observation_fact $observationFact->toTableFileLine(); 
						}
					}
					else
					{
						my $variableName 			= $conceptList[$i]->{VARIABLE_NAME};
						my $variableDelimiter 		= $conceptList[$i]->{COLUMN_DELIMITER};
					
						#If the mapping and value fields are different we need to parse two columns.
						my @parsedVariableColumn 	= split(/$variableDelimiter/,$line[$variableColumn-1]);
						
						#We need to look for the index of the entry in the delimited field that matches our variable name.
						my $variableIndex = first { $parsedVariableColumn[$_] eq $variableName } 0..$#parsedVariableColumn;
						$variableIndex = $variableIndex  // -1;
						
						if($variableIndex >= 0)
						{
							#Okay, we've found the index of where the value should be in the value column, parse the value.
							my @parsedValueColumn		= split(/$variableDelimiter/,$line[$valueColumn-1]);
							my $retrievedValue			= $parsedValueColumn[$variableIndex];
							
							my $observationFact 	= new ObservationFact(PATIENT_NUM => $patientHash->{$currentID}, CONCEPT_CD => $conceptList[$i]->{CONCEPT_CD}, TVAL_CHAR => $retrievedValue);
							
							print observation_fact $observationFact->toTableFileLine(); 														
						}
					}
				}

			}
		
			close currentPatientANNOVARFile	
		 }
	}
	
	closedir(D);
	close(observation_fact);
}
###########################################

1;