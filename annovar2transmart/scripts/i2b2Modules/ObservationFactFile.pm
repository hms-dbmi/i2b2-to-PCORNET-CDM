#!/usr/bin/perl

package ObservationFactFile;

use strict;
use warnings;
use Carp;
use UUID::Generator::PurePerl;
use Data::Dumper;

###########################################
#OBSERVATION_FACT FILE
###########################################
sub generateObservationFactFile 
{

	my ($params) = @_;

	my $patientHash = $params->{PATIENT_HASH};
	my $conceptHash = $params->{CONCEPT_HASH};
	my @conceptList = $params->{CONCEPT_LIST};

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
			
				#Next we need to loop through the variant array and pull out the concepts embedded in the special delimited fields.
				foreach(@conceptList) 
				{ 
					#This should be a VariantFieldMapping object.
					my $currentConcept = $_;
				
					#print(Dumper($currentConcept));
				
					#my $observationFact = new ObservationFact(PATIENT_NUM => $patientHash{$currentID}, CONCEPT_CD => $k, TVAL_CHAR => $currentValue);

					#print observation_fact $observationFact->toTableFileLine(); 				
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