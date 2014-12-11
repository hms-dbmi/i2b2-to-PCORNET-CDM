#!/usr/bin/perl

package ConceptDimensionFile;

use strict;
use warnings;
use Carp;
#use LowLevels;

use Text::CSV;

use Data::Dumper;


my $currentStudyId = "";

###########################################
#CONCEPT_DIMENSION FILE
###########################################
sub generateConceptDimensionFile
{
	
	print("*************************************************************\n");
	print("ConceptDimensionFile.pm\n");
	print("*************************************************************\n");
		
	my $configurationObject = shift;

	my %numericIndividualConceptHash 	= ();	
	my %textIndividualConceptHash 		= ();
	
	my $concept_dimension_output_file 	= 	$configurationObject->{CONCEPT_DIMENSION_OUT_FILE};
	my $patient_data_directory			= 	$configurationObject->{PATIENT_DATA_DIRECTORY};
	$currentStudyId						=	$configurationObject->{STUDY_ID};
	
	#We could have many different types of mapping files. To that end we'll have a file to map our mapping files. This hash is {filename} = filetype
	my %mappingFileHash = tranSMARTTextParsing::generateMasterMappingHash($configurationObject->{BASE_PATH});
	while(my($k, $v) = each %mappingFileHash) 
	{
		if($v eq "INDIVIDUAL")	
		{
			_parseMappingFileTextPassPatient($configurationObject, $k, $patient_data_directory, \%textIndividualConceptHash);
		}
	}
	
	print("DEBUG - ConceptDimensionFile.pm : Attemping to open output file $concept_dimension_output_file\n");

	my $totalConceptCount = 0;
	
	#Count each line in the mapping files. Maybe we should merge the counts into the functions below.
	$totalConceptCount = _countLinesInMappingFiles(\%mappingFileHash, $configurationObject->{BASE_PATH});

	#We'll need a concept for each of the items in the concept hashes we extracted from the data file.
	$totalConceptCount += _countItemsInConceptHash(\%textIndividualConceptHash);

	#Now that we know the total concept count, pre-fetch the concept_ids.
	my @conceptIdArray = ConceptDimension::getNewConceptIdList($totalConceptCount, $configurationObject);

	open my $concept_dimension_out, ">$concept_dimension_output_file";

	print $concept_dimension_out ConceptDimension->printColumnHeaders();

	#After we've created the hash of mapping files we'll iterate over them and extract the numeric concepts and build hashes to be used when building the fact files.
	while(my($k, $v) = each %mappingFileHash) 
	{ 
		if($v eq "INDIVIDUAL") 	
		{
			_parseMappingFileSecondPass($configurationObject->{BASE_PATH}, $k, $concept_dimension_out, \@conceptIdArray, \%numericIndividualConceptHash);
		}
	}
	#We need to create the text concepts from the hashes we created earlier.
	_createConceptsFromConceptHash(\%textIndividualConceptHash, \@conceptIdArray, $concept_dimension_out);

	close($concept_dimension_out);
        	
	print("*************************************************************\n");
	print("\n");
	
	# generate concepts for levels 1 and 2 + concept roots for text concepts
	# add them to the concept_dimension_out file
	# return a hash with conceptName, conceptPath and conceptCd
        my %LowLevelHash = _generateMissingConceptsLevels($configurationObject,\%numericIndividualConceptHash, \%textIndividualConceptHash);
	
	return (\%numericIndividualConceptHash, \%textIndividualConceptHash, \%LowLevelHash);
}

sub _parseMappingFileTextPassPatient {
	my $configurationObject 	= shift;
	my $currentMappingFile 		= shift;
	my $dataDirectoryToParse	= shift;
	my $textAttributeHash		= shift;

	my %idPathHash				= ();
	
	my $field_mapping_file = $configurationObject->{BASE_PATH} . "mapping_files/$currentMappingFile";

	print("DEBUG - ConceptDimensionFile.pm : Attemping to open mapping file $field_mapping_file\n");

	open field_mapping, "<$field_mapping_file" || die "Can't opedir: $!\n";;

	my $header 					= <field_mapping>;

	while (<field_mapping>)
	{
		my $line = $_;
	
		#Clean Input line.
		chomp($line);

		if($line =~ m/^([^\t]+)\t([^\t]+)\t([^\t]+)/)
		{
			#Gather all the text elements from the mapping file.
			if($3 eq "T")
			{
				$textAttributeHash->{$1} = ();
				$idPathHash{$1} = $2;
			}

		}
	}

	close(field_mapping);

	my $currentStrippedFileName = $currentMappingFile;
	$currentStrippedFileName =~ s/\.map$//;
	
	print("DEBUG - ConceptDimensionFile.pm : Attemping to open data file $dataDirectoryToParse$currentStrippedFileName\n");
	my @rows;
	my $csv = Text::CSV->new ( { binary => 1, sep_char => "\t" } ) or die "Cannot use CSV: ".Text::CSV->error_diag ();
 	my $currentPatientFile;
 	
	if(open $currentPatientFile, "<$dataDirectoryToParse$currentStrippedFileName")
	{
	
		my $dataHeader = $csv->getline( $currentPatientFile );

		#Make a hash so we know the column index for each of our column names.
		my %headerHash;
		
		my $headerCount = @$dataHeader;
		
		for (my $i=0; $i < $headerCount; $i++) 
		{
	   		$headerHash{@$dataHeader[$i]} = $i;
		}

		#For every line we grab the unique values for our text field hash.
		while (my $row = $csv->getline( $currentPatientFile ))
		{	
			#Loop through the text hash and add the value to the distinct hash.
			while(my($columnId, $columnHash) = each %$textAttributeHash) 
			{
				if(exists $headerHash{$columnId})
				{
					if($row->[$headerHash{$columnId}] ne "" && !($row->[$headerHash{$columnId}] =~ s/\n//))
					{
						$textAttributeHash->{$columnId}{$row->[$headerHash{$columnId}]} = "$idPathHash{$columnId}$row->[$headerHash{$columnId}]\\";
					}
				}
			}	

		}	
	
		$csv->eof or $csv->error_diag();	
	}
	
	close $currentPatientFile;	

}

sub _parseMappingFileSecondPass {

	my $basePath 				= shift;
	my $currentMappingFile 		= shift;
	my $concept_dimension_out	= shift;
	my $conceptIdArray			= shift;
	my $conceptHash				= shift;
		
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
	
		if($line =~ m/^([^\t]+)\t([^\t]+)\t([^\t]+)/)
		{
			if($3 eq "N")
			{
				my $currentConceptId = shift(@$conceptIdArray);
			
				#This is the index in the data file that the concept corresponds to.
				my $currentIndexField = $1;
					
				#Use the concept path from here.
				my $currentConcept = $2;

				#Store the column index and the concept code in a hash.
				$conceptHash->{$currentIndexField} = $currentConcept . "!!!" . $currentConceptId;

				#Create the concept object.
				my $conceptDimension = new ConceptDimension(CONCEPT_CD => $currentConceptId, CONCEPT_PATH => $currentConcept, SOURCESYSTEM_CD => $currentStudyId);
	
				#Write the entry for the concept_dimension table.
				print $concept_dimension_out $conceptDimension->toTableFileLine();
			}

		}
	}

	close(field_mapping);

}

sub _countItemsInConceptHash {

	my $conceptHash = shift;
	
	my $conceptCount = 0;
	
	#There is an outer hash and an inner hash that we count.
	while(my($k, $v) = each %$conceptHash) 
	{ 
		$conceptCount += keys %$v;	
	}	

	return $conceptCount;

}

sub _countLinesInMappingFiles {
	
	my $mappingFileHash = shift;
	my $baseDirectory = shift;
	
	my $totalConceptCount = 0;
	
	while(my($k, $v) = each %$mappingFileHash) 
	{ 
		#wc count file.
		my $wcCountFile = $baseDirectory . "mapping_files/$k";
	
		#This system command will count the number of lines in the mapping files. We need to generate a concept for each (minus the header lines).
		my $lines = `/usr/bin/wc -l $wcCountFile`; die("Could not run wc!\n") if !defined($lines);
		
        chomp $lines;$lines =~ s/^\s+//;
        
        my @countArray = split(/\s/, $lines);

        $totalConceptCount += ($countArray[0] - 1);
	}

	return $totalConceptCount;

}

sub _createConceptsFromConceptHash {

	my $currentHash 			= shift;
	my $conceptIdArray 			= shift;
	my $concept_dimension_out	= shift;
	
	while(my($columnName, $distinctLeafValues) = each %$currentHash) 
	{ 
		while(my($shortName, $fullConceptPath) = each %$distinctLeafValues) 
		{
			if(length($fullConceptPath) < 255)
			{
				my $currentConceptId = shift(@$conceptIdArray);	
			
				#Create the concept object.
				my $conceptDimension = new ConceptDimension(CONCEPT_CD => $currentConceptId, CONCEPT_PATH => $fullConceptPath, SOURCESYSTEM_CD => $currentStudyId);
			
				#Write the entry for the concept_dimension table.
				print $concept_dimension_out $conceptDimension->toTableFileLine();
			
				#Add the concept ID alongside the full concept path in the hash.
				$distinctLeafValues->{$shortName} .= "!!!$currentConceptId";
			}
		}
	}

}

sub _generateMissingConceptsLevels {

        my $configurationObject = shift;
	my $numericConcepts = shift;
	my $textConcepts = shift;

 	my $concept_dimension_output_file       =       $configurationObject->{CONCEPT_DIMENSION_OUT_FILE};
        my $patient_data_directory                      =       $configurationObject->{PATIENT_DATA_DIRECTORY};
        my $currentStudyId                                         =       $configurationObject->{STUDY_ID};
        my $i2b2_table_output_file              = $configurationObject->{I2B2_OUT_FILE};
	
	# create a hash to retrieve text concepts roots from \%textIndividualConceptHash
	my @textConceptsKeys = keys %$textConcepts;
	my %conceptNewHash;
	foreach (@textConceptsKeys) {
		my $concept = $_; 
		my $currentArray = $$textConcepts{$concept};
		my @currentKeys =  keys %$currentArray;
		my $currentPath = $$currentArray{$currentKeys[0]};
		if ($currentPath =~ /((\\[^\t\\]+)+\\)[^\t\\]+\\!!!\d+$/){
			$conceptNewHash{$concept} = $1; 
		}
	}
	my @numericConceptsKeys = keys %$numericConcepts;
	foreach (@numericConceptsKeys) {
		my $concept = $_;
		my $currentPath = $$numericConcepts{$concept};
		if ($currentPath =~ /((\\[^\t\\]+)+\\)[^\t\\]+\\!!!\d+$/){
 #                       print Dumper $1; 
			$conceptNewHash{$concept} = $1;
                 } 
	}

#print Dumper \%conceptNewHash;

	my %conceptPathHash;
	my $levelMax = 0;
	while (my($k,$v) = each %conceptNewHash) {
		$conceptPathHash{$v} ++;
		my $level = () = $v =~ /\\/g;
		$level -= 2;
		$levelMax = $level if $level > $levelMax;
#		print Dumper $level;
	}

	for (my $i = 0; $i <= $levelMax; $i++) {
	 	while (my($k,$v) = each %conceptPathHash) {
                	if ($k =~ /((\\[^\t\\]+)+\\)[^\t\\]+\\$/){ 
				$conceptPathHash{$1} ++;
			}
		}
	}

#print Dumper \%conceptPathHash;
	
	
	
#	my %conceptHash0 ;
#        my %conceptHash1 ;
#        my %conceptHash2 ;

#        open CONCEPT_IN, "<$concept_dimension_output_file";

#        while (my $row = <CONCEPT_IN>) {

#                if($row =~ m/^\t([^\t]+)\t([^\t]+)\t([^\t]+)(\t)+/) {
#                        my $concept_path = $3;
#                        if ($concept_path =~ /\\([^\\]+)\\([^\\]+)\\([^\\]+)\\[^\s]+/) {
#                                $conceptHash0{$1} ++;
#                                $conceptHash1{$2} ++;
#                                $conceptHash2{$3} ++;
#                        }
#                }
#        }
#        close CONCEPT_IN;

#        my @conceptLevel0 = keys %conceptHash0;

#        my @conceptLevel1 = keys %conceptHash1;
#        my $nConcept = keys %conceptHash1;

#        my @conceptLevel2 = keys %conceptHash2;
#        $nConcept += keys %conceptHash2;
#	$nConcept += keys %conceptNewHash;

        open CONCEPT_OUT, ">>$concept_dimension_output_file";
#        open I2B2_OUT, ">>$i2b2_table_output_file";
	
	my $nConcept = %conceptPathHash;
        my @conceptIdArray = ConceptDimension::getNewConceptIdList($nConcept, $configurationObject);
        my %LowLevelConcept;
        
	while (my ($fullConceptPath, $v) = each %conceptPathHash) {
	
		if ($fullConceptPath =~ /(\\[^\t\\]+)+\\([^\t\\]+)\\$/) {

		my $conceptName = $2;
		my $currentConceptCd = shift @conceptIdArray;
		
		$LowLevelConcept{$conceptName} = "$fullConceptPath!!!$currentConceptCd";

		my $conceptDimension = new ConceptDimension(CONCEPT_CD => $currentConceptCd, CONCEPT_PATH => $fullConceptPath , SOURCESYSTEM_CD => $currentStudyId);
                print CONCEPT_OUT $conceptDimension->toTableFileLine();

		}	

	}

#	while (my ($k, $v) = each %conceptHash1) {
#                my $fullConceptPath = "\\$conceptLevel0[0]\\$k\\";
#                my $currentConceptCd = shift @conceptIdArray;

#                $LowLevelConcept{$k} = "$fullConceptPath!!!$currentConceptCd";

#                my $conceptDimension = new ConceptDimension(CONCEPT_CD => $currentConceptCd, CONCEPT_PATH => $fullConceptPath , SOURCESYSTEM_CD => $currentStudyId);
#                print CONCEPT_OUT $conceptDimension->toTableFileLine();

#        }


#        while (my ($k, $v) = each %conceptHash2) {
#                my $fullConceptPath = "\\$conceptLevel0[0]\\$conceptLevel1[0]\\$k\\";
#                my $currentConceptCd = shift @conceptIdArray;

#                $LowLevelConcept{$k} = "$fullConceptPath!!!$currentConceptCd";

#                my $conceptDimension = new ConceptDimension(CONCEPT_CD => $currentConceptCd, CONCEPT_PATH => $fullConceptPath , SOURCESYSTEM_CD => $currentStudyId);
#                print  CONCEPT_OUT $conceptDimension->toTableFileLine();


#        }

#	while (my ($k, $v) = each %conceptNewHash) {
#		my $currentConceptCd = shift @conceptIdArray;
#		$LowLevelConcept{$k} = "$v!!!$currentConceptCd";
#		my $conceptDimension = new ConceptDimension(CONCEPT_CD => $currentConceptCd, CONCEPT_PATH => $v , SOURCESYSTEM_CD => $currentStudyId);
#	}
	#print Dumper \%LowLevelConcept;
        close CONCEPT_OUT;
 #       close I2B2_OUT;
        return %LowLevelConcept;
}
###########################################


1;
