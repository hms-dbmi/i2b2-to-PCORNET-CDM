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
	print("*************************************************************\n");
	print("i2b2File.pm\n");
	print("*************************************************************\n");

	my ($params) = @_;
	
	my $configurationObject 		= $params->{CONFIGURATION_OBJECT};
	
	#Pull the hash references into easier to read variables.
	my $variantNumericConcepts 		= $params->{VARIANT_NUMERIC_CONCEPTS};
	my $individualNumericConcepts 	= $params->{INDIVIDUAL_NUMERIC_CONCEPTS};
	my $variantTextConcepts 		= $params->{VARIANT_TEXT_CONCEPTS};
	my $individualTextConcepts 		= $params->{INDIVIDUAL_TEXT_CONCEPTS};
					
	my $i2b2_table_output_file 		= $configurationObject->{I2B2_OUT_FILE};
	my $currentStudyId				= $configurationObject->{STUDY_ID};
	print("DEBUG - i2b2File.pm : Attemping to open output file $i2b2_table_output_file\n");
	
	open (i2b2_output,">$i2b2_table_output_file") || die "Can't open output file ($i2b2_table_output_file) : $!\n";;

	#Get the mapping of mapping files.
	my %mappingFileHash = tranSMARTTextParsing::generateMasterMappingHash($configurationObject->{BASE_PATH});

	#We need to prefetch an ID per entry in the concept hashes.
	my $conceptCount = keys %$variantNumericConcepts;
	$conceptCount 	+= keys %$individualNumericConcepts;
	$conceptCount 	+= tranSMARTTextParsing::countHashLeaves($variantTextConcepts);
	$conceptCount 	+= tranSMARTTextParsing::countHashLeaves($individualTextConcepts);
	
	my @i2b2IdArray = i2b2::getNewI2b2IdList($conceptCount, $configurationObject);

	print i2b2_output i2b2->printColumnHeaders();

	while(my($mappingFile, $mappingFileType) = each %mappingFileHash) 
	{ 
		my $currentMappingFile = $configurationObject->{MAPPING_FILE_DIRECTORY} . $mappingFile;
		
		print("DEBUG - i2b2File.pm : Attemping to open mapping file $currentMappingFile\n");
		
		#Open the current mapping file to generate records for the i2b2 table.
		open (field_mapping, "<$currentMappingFile") || die "Can't open mapping file ($currentMappingFile) : $!\n";

		my $header = <field_mapping>;

		while (<field_mapping>)
		{
			my $line = $_;
	
			#Clean Input line.
			chomp($line);
	
			if($line =~ m/^([^\t]+)\t([^\t]+)\t([^\t]+)/)
			{
			
				my $currentConceptType 	= $3;
				
				#Pull the concept cd based on the name of the column in the data file. For text entries we need to loop through the hash to create all the possible data values.
				if($mappingFileType eq "INDIVIDUAL" and $currentConceptType eq "N")
				{
					_generateSingleI2b2Record($1,$2, $individualNumericConcepts->{$1}, shift @i2b2IdArray,'N', $currentStudyId);
				}
				elsif($mappingFileType eq "VARIANT" and $currentConceptType eq "N")
				{
					_generateSingleI2b2Record($1,$2, $variantNumericConcepts->{$1}, shift @i2b2IdArray,'N', $currentStudyId);
				}
				elsif($mappingFileType eq "INDIVIDUAL" and $currentConceptType eq "T")
				{					
					my $individualTextConceptsSubHash = $individualTextConcepts->{$1};
					
					while(my($nameText, $fullConceptInfo) = each %$individualTextConceptsSubHash) 
					{
						my @conceptPathIdSplit = split(/!!!/,$fullConceptInfo);
						
						if(length($conceptPathIdSplit[0]) < 255)
						{
							_generateSingleI2b2Record($1,$conceptPathIdSplit[0],$conceptPathIdSplit[1],shift @i2b2IdArray,'T', $currentStudyId);
						}
					}
				}
				elsif($mappingFileType eq "VARIANT" and $currentConceptType eq "T")
				{
					my $variantTextConceptsSubHash = $variantTextConcepts->{$1};
					
					while(my($nameText, $fullConceptInfo) = each %$variantTextConceptsSubHash) 
					{
						my @conceptPathIdSplit = split(/!!!/,$fullConceptInfo);
						
						if(length($conceptPathIdSplit[0]) < 255)
						{
							_generateSingleI2b2Record($1,$conceptPathIdSplit[0],$conceptPathIdSplit[1],shift @i2b2IdArray,'T', $currentStudyId);
						}
					}
				}
				
				
			}
		}

	}

	close(i2b2_output);

	print("*************************************************************\n\n");

}

sub _generateSingleI2b2Record {

	my $currentColumnId 	= shift;
	my $currentConceptPath 	= shift;
	my $currentConceptCd	= shift;
	my $i2b2Id				= shift;
	my $columnDataType		= shift;
	my $currentStudyId		= shift;
	
	my $metaDataXML			= '';
	
	if($columnDataType eq "N") {$metaDataXML = '<?xml version="1.0"?><ValueMetadata><Version>3.02</Version><CreationDateTime>08/14/2008 01:22:59</CreationDateTime><TestID></TestID><TestName></TestName><DataType>PosFloat</DataType><CodeType></CodeType><Loinc></Loinc><Flagstouse></Flagstouse><Oktousevalues>Y</Oktousevalues><MaxStringLength></MaxStringLength><LowofLowValue>0</LowofLowValue><HighofLowValue>0</HighofLowValue><LowofHighValue>100</LowofHighValue>100<HighofHighValue>100</HighofHighValue><LowofToxicValue></LowofToxicValue><HighofToxicValue></HighofToxicValue><EnumValues></EnumValues><CommentsDeterminingExclusion><Com></Com></CommentsDeterminingExclusion><UnitValues><NormalUnits>ratio</NormalUnits><EqualUnits></EqualUnits><ExcludingUnits></ExcludingUnits><ConvertingUnits><Units></Units><MultiplyingFactor></MultiplyingFactor></ConvertingUnits></UnitValues><Analysis><Enums /><Counts /><New /></Analysis></ValueMetadata>';}
												
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
								C_COLUMNDATATYPE	=> $columnDataType,
								C_OPERATOR			=> 'LIKE',
								C_COMMENT			=> $currentStudyId,
								SOURCESYSTEM_CD		=> $currentStudyId,
								M_APPLIED_PATH		=> '@',
								I2B2_ID				=> $i2b2Id,
								C_VISUALATTRIBUTES	=> 'LA',
								C_SYNONYM_CD		=> 'N',
								C_METADATAXML		=> $metaDataXML
								);
								
	print i2b2_output $i2b2Record->toTableFileLine();

}


# 
# 	
# 	
# my $i2b2Record = new i2b2(	C_HLEVEL 			=> 0, 
#  								C_FULLNAME 			=> '\\test\\', 
#  								C_DIMCODE 			=> 'test',
#  								C_TOOLTIP			=> '\\test\\',
#  								C_FACTTABLECOLUMN	=> 'CONCEPT_CD',
#  								C_NAME				=> 'test',
#  								C_TABLENAME			=> 'CONCEPT_DIMENSION',
#  								C_COLUMNNAME		=> 'CONCEPT_PATH',
#  								C_COLUMNDATATYPE	=> 'T',
#  								C_OPERATOR			=> 'LIKE',
#  								C_COMMENT			=> 'WES_LOADER',
#  								C_TOTALNUM			=> 0,
#  								SOURCESYSTEM_CD		=> 'WES_LOADER',
#  								M_APPLIED_PATH		=> '@',
#  								I2B2_ID				=> shift @i2b2IdArray,
#  								C_VISUALATTRIBUTES	=> 'CA',
#  								C_SYNONYM_CD		=> 'N'
#  								);	
#  
#  	print i2b2_output $i2b2Record->toTableFileLine();
#  	
#  	$i2b2Record = new i2b2(	C_HLEVEL 				=> 1, 
#  								C_FULLNAME 			=> '\\test\\WES\\', 
#  								C_DIMCODE 			=> 'WES',
#  								C_TOOLTIP			=> '\\test\\WES\\',
#  								C_FACTTABLECOLUMN	=> 'CONCEPT_CD',
#  								C_NAME				=> 'WES',
#  								C_TABLENAME			=> 'CONCEPT_DIMENSION',
#  								C_COLUMNNAME		=> 'CONCEPT_PATH',
#  								C_COLUMNDATATYPE	=> 'T',
#  								C_OPERATOR			=> 'LIKE',
#  								C_COMMENT			=> 'WES_LOADER',
#  								C_TOTALNUM			=> 0,
#  								SOURCESYSTEM_CD		=> 'WES_LOADER',
#  								M_APPLIED_PATH		=> '@',
#  								I2B2_ID				=> shift @i2b2IdArray,
#  								C_VISUALATTRIBUTES	=> 'FA',
#  								C_SYNONYM_CD		=> 'N'
#  								);	
#  
#  	print i2b2_output $i2b2Record->toTableFileLine();	
		






1;