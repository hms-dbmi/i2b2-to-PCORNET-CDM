#!/usr/bin/perl

use i2b2Modules::ConceptDimension;
use i2b2Modules::PatientDimension;
use i2b2Modules::ObservationFact;
use ANNOVARModules::VariantFieldMapping;

use Data::Dumper;

use UUID::Generator::PurePerl;
$ug = UUID::Generator::PurePerl->new();

my %patientHash = ();
my @conceptList = ();

###########################################
#PATIENT_DIMENSION FILE
###########################################
#This directory should house the individuals genomic variant files.
my $inputDataDirectory 				= "/Users/mmcduffie/Documents/HMS/tranSMART Exome/data/source/";
my $patient_dimension_output_file	= "/Users/mmcduffie/Documents/HMS/tranSMART Exome/data/i2b2_load_tables/patient_dimension";
my $patient_dimension_columns		= "";

#Open the directory with annotated genomic files.
opendir(D, $inputDataDirectory) || die "Can't opedir: $!\n";
open patient_dimension, ">$patient_dimension_output_file";

print patient_dimension PatientDimension->printColumnHeaders();

while (my $f = readdir(D)) 
{
     if($f =~ m/(.*)\.annovar$/)
     {
     	my $currentID = $1;
     	$uuid1 = $ug->generate_v1();
     	
     	$patientHash{$currentID} = $uuid1;
     	
		$patientDimension = new PatientDimension(PATIENT_NUM => $uuid1, SOURCESYSTEM_CD => $currentID);
		print patient_dimension $patientDimension->toTableFileLine();     	
     
     }
}
closedir(D);
close(patient_dimension);
###########################################

###########################################
#CONCEPT_DIMENSION FILE
###########################################
my $variant_field_mapping_file 		= "/Users/mmcduffie/Documents/HMS/tranSMART Exome/mapping_files/variant_field_mapping";
my $genotype_field_mapping_file		= "/Users/mmcduffie/Documents/HMS/tranSMART Exome/mapping_files/genotype_field_mapping";
my $concept_dimension_output_file 	= "/Users/mmcduffie/Documents/HMS/tranSMART Exome/data/i2b2_load_tables/concept_dimension";

#When building the concept dimension entries we need to utilize the mapping files.
#The first mapping file maps the columns in the annovar file to the tranSMART hierarchy.

#Open the mapping file.
open variant_field_mapping, "<$variant_field_mapping_file";

#Open the file we output the concept_dimension rows to.
open concept_dimension, ">$concept_dimension_output_file";

print concept_dimension ConceptDimension->printColumnHeaders();

my $header = <variant_field_mapping>;

while (<variant_field_mapping>)
{
	my $line = $_;
	
	#Clean Input line.
	chomp($line);
	
	if($line =~ m/^([^\t]+)\t([^\t]+)/)
	{
		#Use the concept path from here.
		my $currentConcept = $2;
	
		#Create a new concept code identifier.
		$uuid1 = $ug->generate_v1();
	
		#Store the column index and the concept code in a hash.
		$conceptHash{$uuid1} = $currentIndexField;
	
		#Create the concept object.
		$conceptDimension = new ConceptDimension(CONCEPT_CD => $uuid1, CONCEPT_PATH => $currentConcept);
	
		#Write the entry for the concept_dimension table.
		print concept_dimension $conceptDimension->toTableFileLine();

	}
}

close(variant_field_mapping);

open genotype_field_mapping, "<$genotype_field_mapping_file";
my $header = <genotype_field_mapping>;

while (<genotype_field_mapping>)
{
	my $line = $_;

	#Clean Input line.
	chomp($line);
	
	if($line =~ m/^([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)/)
	{
		#This is the index in the data file that the concept corresponds to.
		my $currentIndexField = $1;
		
		#This is the index where the data values can be extracted from.
		my $currentValueIndexField = $2;
		
		#This is the delimiter we will find in the data values.
		my $currentDelimiter = $3;
		
		#The fields (When the index and value index are the same) are separated by delimiters and have a two character naming convention (;AC=). Pull the two character name here.
		my $currentFieldName = $4;
		
		my $currentConceptPath = $5;
		
		#Create a new concept code identifier.
		$uuid1 = $ug->generate_v1();
	
		#Create the concept object so we can write it to a file.
		$conceptDimension = new ConceptDimension(CONCEPT_CD => $uuid1, CONCEPT_PATH => $currentConceptPath);
		print concept_dimension $conceptDimension->toTableFileLine();	
		
		my $variantFieldMapping = new VariantFieldMapping();
		
		#Store an array of the Variant Field Mapping objects.
		push(@conceptList, $conceptDimension);	
	
	}
}

close(genotype_field_mapping);
	
close(concept_dimension);
###########################################

###########################################
#OBSERVATION_FACT FILE
###########################################
my $observation_fact_output_file	= "/Users/mmcduffie/Documents/HMS/tranSMART Exome/data/i2b2_load_tables/observation_fact";

#Open the directory with annotated genomic files.
opendir(D, $inputDataDirectory) || die "Can't opedir: $!\n";
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
			while(my($k, $v) = each %conceptHash) 
			{ 
				#The current value is the value of the concept that is referred to by its column index in the data file.
				my $currentValue = $line[$v-1];
				
				$observationFact = new ObservationFact(PATIENT_NUM => $patientHash{$currentID}, CONCEPT_CD => $k, TVAL_CHAR => $currentValue);

				print observation_fact $observationFact->toTableFileLine(); 				
			}
			
			#Next we need to loop through the variant array and pull out the concepts embedded in the special delimited fields.
			foreach(@conceptList) 
			{ 
				#This should be a VariantFieldMapping object.
				my $currentConcept = $_;
				
				print(Dumper($currentConcept));
				
				$observationFact = new ObservationFact(PATIENT_NUM => $patientHash{$currentID}, CONCEPT_CD => $k, TVAL_CHAR => $currentValue);

				print observation_fact $observationFact->toTableFileLine(); 				
			}
			
		}
		
		close currentPatientANNOVARFile	
     }
}
closedir(D);
close(observation_fact);
###########################################

