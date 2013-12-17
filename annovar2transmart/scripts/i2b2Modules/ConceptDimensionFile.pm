#!/usr/bin/perl

package ConceptDimensionFile;

use strict;
use warnings;
use Carp;

use Data::Dumper;

###########################################
#CONCEPT_DIMENSION FILE
###########################################
sub generateConceptDimensionFile
{
	my ($params) = @_;

	my @conceptList 				= ();
	
	my %variantConceptHash 			= ();
	my $variantFileConceptHash;
	
	my %individualConceptHash 		= ();
	my $individualFileConceptHash;
	
	my $totalConceptCount			= 0;
	
	my $concept_dimension_output_file 	= $params->{BASE_DIRECTORY} . "data/i2b2_load_tables/concept_dimension";

	#We could have many different types of mapping files. To that end we'll have a file to map our mapping files. This hash is {filename} = filetype
	my %mappingFileHash = tranSMARTTextParsing::generateMasterMappingHash($params->{BASE_DIRECTORY});
	
	#After we've created the hash of mapping files we'll iterate over them and extract the concepts and build hashes to be used when building the fact files.
	print("DEBUG - ConceptDimensionFile.pm : Attemping to open output file $concept_dimension_output_file\n");

	while(my($k, $v) = each %mappingFileHash) 
	{ 
		#This system command will count the number of lines in the mapping files. We need to generate a concept for each (minus the header lines).
		my $lines = `/usr/bin/wc -l $params->{BASE_DIRECTORY}mapping_files/$k`;
		
		die("Could not run wc!\n") if !defined($lines);
		
        chomp $lines;$lines =~ s/^\s+//;
        
        my @countArray = split(/\s/, $lines);

        $totalConceptCount += ($countArray[0] - 1);
        
	}

	#Now that we know the total concept count, pre-fetch the concept_ids.
	my @conceptIdArray = ConceptDimension::getNewConceptIdList($totalConceptCount);

	#Open the file we output the concept_dimension rows to.
	open my $concept_dimension_out, ">$concept_dimension_output_file";

	print $concept_dimension_out ConceptDimension->printColumnHeaders();

	while(my($k, $v) = each %mappingFileHash) 
	{ 
		#@hash1{keys %hash2} = values %hash2;
		if($v eq "INDIVIDUAL"){
			$individualFileConceptHash = _parseMappingFile($params->{BASE_DIRECTORY}, $k, $concept_dimension_out, \@conceptIdArray);
		}
		elsif($v eq "VARIANT"){
			$variantFileConceptHash = _parseMappingFile($params->{BASE_DIRECTORY}, $k, $concept_dimension_out, \@conceptIdArray);
		}				
	}

	close($concept_dimension_out);
	
	print("\n\n");

	return ($individualFileConceptHash, $variantFileConceptHash);
}



sub _parseMappingFile {

	my $basePath 				= shift;
	my $currentMappingFile 		= shift;
	my $concept_dimension_out	= shift;
	my $conceptIdArray			= shift;
	
	my %conceptHash				= ();
		
	my $field_mapping_file = $basePath . "mapping_files/$currentMappingFile";

	print("DEBUG - ConceptDimensionFile.pm : Attemping to open mapping file $currentMappingFile\n");

	#Open the mapping file.
	open field_mapping, "<$field_mapping_file";

	my $header 					= <field_mapping>;

	while (<field_mapping>)
	{
		my $line = $_;
	
		#Clean Input line.
		chomp($line);
	
		if($line =~ m/^([^\t]+)\t([^\t]+)/)
		{
			my $currentConceptId = shift(@$conceptIdArray);
			
			#This is the index in the data file that the concept corresponds to.
			my $currentIndexField = $1;
					
			#Use the concept path from here.
			my $currentConcept = $2;
	
			#Store the column index and the concept code in a hash.
			$conceptHash{$currentConceptId} = $currentIndexField;

			#Create the concept object.
			my $conceptDimension = new ConceptDimension(CONCEPT_CD => $currentConceptId, CONCEPT_PATH => $currentConcept);
	
			#Write the entry for the concept_dimension table.
			print $concept_dimension_out $conceptDimension->toTableFileLine();

		}
	}

	close(field_mapping);
	return \%conceptHash;

}

sub _parseGenotypeMappingFile {

	my $basePath 				= shift;
	my $currentMappingFile 		= shift;
	my $concept_dimension_out	= shift;

	my @conceptList				= ();

	my $field_mapping_file 		= $basePath . "mapping_files/$currentMappingFile";

	print("DEBUG - ConceptDimensionFile.pm : Attemping to open mapping file $field_mapping_file\n");

	open genotype_field_mapping, "<$field_mapping_file";

	my $header 					= <genotype_field_mapping>;

	while (<genotype_field_mapping>)
	{
		my $line = $_;

		#Clean Input line.
		chomp($line);
	
		if($line =~ m/^([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)/)
		{
	my $uuid1 = 0;
			#Create the concept object so we can write it to a file.
			my $conceptDimension = new ConceptDimension(CONCEPT_CD => $uuid1, CONCEPT_PATH => $5);
			print $concept_dimension_out $conceptDimension->toTableFileLine();	
			
			my $variantFieldMapping = new VariantFieldMapping(VARIANT_FILE_VARIABLE_COLUMN => $1,  VARIANT_FILE_VALUE_COLUMN => $2, COLUMN_DELIMITER => $3, VARIABLE_NAME => $4, CONCEPT_PATH => $5, CONCEPT_CD => $uuid1);
		
			#Store an array of the Variant Field Mapping objects.
			push(@conceptList, $variantFieldMapping);	
	
		}
	}

	close(genotype_field_mapping);

	return \@conceptList;

}

###########################################


1;