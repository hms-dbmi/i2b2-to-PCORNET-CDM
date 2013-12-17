#!/usr/bin/perl

package i2b2File;

use strict;
use warnings;
use Carp;
use Data::Dumper;

###########################################
#i2b2 FILE
###########################################
sub generateI2b2File
{
	my ($params) = @_;
	
	my %individualHash 	= ();
	my %variantHash 	= ();
	
	while ((my $key, my $value) = each %$params->{VARIANT_CONCEPTS}) 
	{
   		$variantHash{$value}=$key;
	}
	
	while ((my $key, my $value) = each %$params->{INDIVIDUAL_CONCEPTS}) 
	{
   		$individualHash{$value}=$key;
	}	
					
	my $i2b2_table_output_file 	= $params->{BASE_DIRECTORY} . "data/i2b2_load_tables/i2b2";
	
	print("DEBUG - i2b2File.pm : Attemping to open output file $i2b2_table_output_file\n");
	
	open (i2b2_output,">$i2b2_table_output_file") || die "Can't open output file ($i2b2_table_output_file) : $!\n";;

	#Get the mapping of mapping files.
	my %mappingFileHash = tranSMARTTextParsing::generateMasterMappingHash($params->{BASE_DIRECTORY});

	#We need to prefetch an ID per entry in the concept hashes.
	my $conceptCount = keys %variantHash;
	$conceptCount = $conceptCount + keys %individualHash;
	my @i2b2IdArray = i2b2::getNewI2b2IdList($conceptCount);

	while(my($mappingFile, $mappingFileType) = each %mappingFileHash) 
	{ 
		my $currentMappingFile = $params->{BASE_DIRECTORY} . "/mapping_files/" . $mappingFile;
		
		print("DEBUG - i2b2File.pm : Attemping to open mapping file $currentMappingFile\n");
		
		#Open the current mapping file to generate records for the i2b2 table.
		open (field_mapping, "<$currentMappingFile") || die "Can't open mapping file ($currentMappingFile) : $!\n";

		my $header = <field_mapping>;

		while (<field_mapping>)
		{
			my $line = $_;
	
			#Clean Input line.
			chomp($line);
	
			if($line =~ m/^([^\t]+)\t([^\t]+)/)
			{
				my $currentColumnId = $1;
				my $currentConceptPath = $2;
				my $currentConceptCd;
				
				#Pull the concept cd based on the name of the column in the data file.
				if($mappingFileType eq "INDIVIDUAL")
				{
					$currentConceptCd = $individualHash{$currentColumnId};
				}
				elsif($mappingFileType eq "VARIANT")
				{
		 			$currentConceptCd = $variantHash{$currentColumnId};
				}
				
				#The level is the number of hops minus the first and last slash.
				my $levelCount = ($currentConceptPath =~ tr/\\//) - 2;
				
				my $currentConceptName = "";
				
				#Concept name is the last hope in the hierarchy.
				if($currentConceptPath =~ m/([^\\]*)\\$/) 
				{
					$currentConceptName = $1;
				}
				else
				{
					die("Could not extract concept name from path!");
				}
				
				my $i2b2Record = new i2b2(	C_HLEVEL 			=> $levelCount, 
											C_FULLNAME 			=> $currentConceptPath, 
											C_DIMCODE 			=> $currentConceptPath,
											C_TOOLTIP			=> $currentConceptPath,
											C_BASECODE			=> $currentConceptCd,
											C_FACTTABLECOLUMN	=> 'CONCEPT_CD',
											C_NAME				=> $currentConceptName,
											C_TABLENAME			=> 'CONCEPT_DIMENSION',
											C_COLUMNNAME		=> 'CONCEPT_PATH',
											C_COLUMNDATATYPE	=> 'T',
											C_OPERATOR			=> 'LIKE',
											C_COMMENT			=> 'WES_LOADER',
											SOURCESYSTEM_CD		=> 'WES_LOADER',
											M_APPLIED_PATH		=> '@',
											I2B2_ID				=> shift @i2b2IdArray
											);
											
				print i2b2_output $i2b2Record->toTableFileLine();
			}
		}

	}
	
	close(i2b2_output);

}


1;