#!/usr/bin/perl

package ConceptDimensionFile;

use strict;
use warnings;
use Carp;
use UUID::Generator::PurePerl;


###########################################
#CONCEPT_DIMENSION FILE
###########################################
sub generateConceptDimensionFile
{
	my ($params) = @_;

	my @conceptList = ();
	my %conceptHash = ();
	
	my $uuid1;
	my $ug = UUID::Generator::PurePerl->new();
	
	my $variant_field_mapping_file 		= $params->{BASE_DIRECTORY} . "mapping_files/variant_field_mapping";
	my $genotype_field_mapping_file		= $params->{BASE_DIRECTORY} . "mapping_files/genotype_field_mapping";
	my $concept_dimension_output_file 	= $params->{BASE_DIRECTORY} . "data/i2b2_load_tables/concept_dimension";

	#When building the concept dimension entries we need to utilize the mapping files.
	#The first mapping file maps the columns in the annovar file to the tranSMART hierarchy.

	print("DEBUG - ConceptDimensionFile.pm : Attemping to open mapping file $variant_field_mapping_file\n");

	#Open the mapping file.
	open variant_field_mapping, "<$variant_field_mapping_file";

	print("DEBUG - ConceptDimensionFile.pm : Attemping to open output file $concept_dimension_output_file\n");

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
			#This is the index in the data file that the concept corresponds to.
			my $currentIndexField = $1;
					
			#Use the concept path from here.
			my $currentConcept = $2;
	
			#Create a new concept code identifier.
			$uuid1 = $ug->generate_v1();
	
			#Store the column index and the concept code in a hash.
			$conceptHash{$uuid1} = $currentIndexField;

			#Create the concept object.
			my $conceptDimension = new ConceptDimension(CONCEPT_CD => $uuid1, CONCEPT_PATH => $currentConcept);
	
			#Write the entry for the concept_dimension table.
			print concept_dimension $conceptDimension->toTableFileLine();

		}
	}

	close(variant_field_mapping);

	print("DEBUG - ConceptDimensionFile.pm : Attemping to open mapping file $genotype_field_mapping_file\n");

	open genotype_field_mapping, "<$genotype_field_mapping_file";
	$header = <genotype_field_mapping>;

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
			my $conceptDimension = new ConceptDimension(CONCEPT_CD => $uuid1, CONCEPT_PATH => $currentConceptPath);
			print concept_dimension $conceptDimension->toTableFileLine();	
		
			my $variantFieldMapping = new VariantFieldMapping();
		
			#Store an array of the Variant Field Mapping objects.
			push(@conceptList, $conceptDimension);	
	
		}
	}

	close(genotype_field_mapping);
	
	close(concept_dimension);
	
	return (\@conceptList, \%conceptHash);
}
###########################################


1;