#!/usr/bin/perl

package ConceptDimensionFile;

use strict;
use warnings;
use Carp;

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

	my $numericVariantConceptHash;
	my $numericIndividualConceptHash;
	
	my $textVariantConceptHash;
	my $textIndividualConceptHash;
	
	my $concept_dimension_output_file 	= 	$configurationObject->{CONCEPT_DIMENSION_OUT_FILE};
	my $variant_data_file	 			= 	$configurationObject->{VARIANT_DATA_FILE};
	my $patient_data_directory			= 	$configurationObject->{PATIENT_DATA_DIRECTORY};
	$currentStudyId						=	$configurationObject->{STUDY_ID};
	
	#We could have many different types of mapping files. To that end we'll have a file to map our mapping files. This hash is {filename} = filetype
	my %mappingFileHash = tranSMARTTextParsing::generateMasterMappingHash($configurationObject->{BASE_PATH});
	
	while(my($k, $v) = each %mappingFileHash) 
	{
		if($v eq "VARIANT")		{$textVariantConceptHash 	= _parseMappingFileTextPassVariant($configurationObject->{BASE_PATH}, $k, $variant_data_file);}
		if($v eq "INDIVIDUAL")	{$textIndividualConceptHash = _parseMappingFileTextPassPatient($configurationObject, $k, $patient_data_directory);}
	}
	
	print("DEBUG - ConceptDimensionFile.pm : Attemping to open output file $concept_dimension_output_file\n");

	my $totalConceptCount = 0;
	
	#Count each line in the mapping files. Maybe we should merge the counts into the functions below.
	$totalConceptCount = _countLinesInMappingFiles(\%mappingFileHash, $configurationObject->{BASE_PATH});

	#We'll need a concept for each of the items in the concept hashes we extracted from the data file.
	$totalConceptCount += _countItemsInConceptHash($textVariantConceptHash);
	$totalConceptCount += _countItemsInConceptHash($textIndividualConceptHash);

	#Now that we know the total concept count, pre-fetch the concept_ids.
	my @conceptIdArray = ConceptDimension::getNewConceptIdList($totalConceptCount, $configurationObject);

	open my $concept_dimension_out, ">$concept_dimension_output_file";

	print $concept_dimension_out ConceptDimension->printColumnHeaders();

	#After we've created the hash of mapping files we'll iterate over them and extract the numeric concepts and build hashes to be used when building the fact files.
	while(my($k, $v) = each %mappingFileHash) 
	{ 
		if($v eq "INDIVIDUAL") 	{$numericIndividualConceptHash 	= _parseMappingFileSecondPass($configurationObject->{BASE_PATH}, $k, $concept_dimension_out, \@conceptIdArray);}
		if($v eq "VARIANT") 	{$numericVariantConceptHash 	= _parseMappingFileSecondPass($configurationObject->{BASE_PATH}, $k, $concept_dimension_out, \@conceptIdArray);}
	}

	#We need to create the text concepts from the hashes we created earlier.
	_createConceptsFromConceptHash($textVariantConceptHash, \@conceptIdArray, $concept_dimension_out);
	_createConceptsFromConceptHash($textIndividualConceptHash, \@conceptIdArray, $concept_dimension_out);

	close($concept_dimension_out);
	
	print("*************************************************************\n");
	print("\n");

	return ($numericIndividualConceptHash, $numericVariantConceptHash, $textIndividualConceptHash, $textVariantConceptHash);
}

#Each text field in the mapping file needs to have a concept for each distinct value in the actual data.
#In this first pass of the mapping file we extract the text fields and find the unique values that they are populated with in the variant data file.
sub _parseMappingFileTextPassVariant {
	my $basePath 				= shift;
	my $currentMappingFile 		= shift;
	my $dataFileToParse			= shift;
	
	my %textAttributeHash		= ();
	my %idPathHash				= ();
	
	my $field_mapping_file = $basePath . "mapping_files/$currentMappingFile";

	print("DEBUG - ConceptDimensionFile.pm : Attemping to open mapping file $field_mapping_file\n");

	open field_mapping, "<$field_mapping_file" || die "Can't opedir: $!\n";

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
				$textAttributeHash{$1} = ();
				$idPathHash{$1} = $2;
			}

		}
	}

	close(field_mapping);
	
	print("DEBUG - ConceptDimensionFile.pm : Attemping to open data input file $dataFileToParse\n");
	
	open my $data_file, "<", "$dataFileToParse" || die "Can't open file: $!\n";;
	
	my $dataHeader = <$data_file>;
	
	my @headerArray = split(/\t/,$dataHeader);

	#Make a hash so we know the column index for each of our column names.
	my %headerHash;
	%headerHash = map { $headerArray[$_] => $_ } 0..$#headerArray;

	#For every line we grab the unique values for our text field hash.
	while (<$data_file>)
	{
		my @line = split(/\t/, $_);

		#Loop through the text hash and add the value to the distinct hash.
		while(my($columnId, $columnHash) = each %textAttributeHash) 
		{
			if(!(exists $headerHash{$columnId})) {die("Could not map a header to an entry in the mapping file! $columnId");}
	
			$textAttributeHash{$columnId}{$line[$headerHash{$columnId}]} = "$idPathHash{$columnId}$line[$headerHash{$columnId}]\\";		
			
		}
		
	}
	close($data_file);

	return \%textAttributeHash;	

}

sub _parseMappingFileTextPassPatient {
	my $configurationObject 	= shift;
	my $currentMappingFile 		= shift;
	my $dataDirectoryToParse	= shift;
	
	my %textAttributeHash		= ();
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
				$textAttributeHash{$1} = ();
				$idPathHash{$1} = $2;
			}

		}
	}

	close(field_mapping);
	
	print("DEBUG - ConceptDimensionFile.pm : Attemping to open data input directory $dataDirectoryToParse\n");
	
	#Open the directory with annotated genomic files.
	opendir(D, $dataDirectoryToParse) || die "Can't opedir: $!\n";

	while (my $f = readdir(D)) 
	{
		if($f =~ m/(.*)$configurationObject->{PATIENT_FILE_SUFFIX}$/)
		{	
			open my $currentPatientANNOVARFile, "<$dataDirectoryToParse$f";

			my $dataHeader = <$currentPatientANNOVARFile>;
			
			chomp($dataHeader);
			
			my @headerArray = split(/\t/,$dataHeader);

			#Make a hash so we know the column index for each of our column names.
			my %headerHash;
			%headerHash = map { $headerArray[$_] => $_ } 0..$#headerArray;

			#For every line we grab the unique values for our text field hash.
			while (<$currentPatientANNOVARFile>)
			{	
				chomp($_);
				my @line = split(/\t/, $_);

				#Loop through the text hash and add the value to the distinct hash.
				while(my($columnId, $columnHash) = each %textAttributeHash) 
				{
					if(!(exists $headerHash{$columnId})) {die("Could not map a header to an entry in the mapping file! $columnId");}
				
					$textAttributeHash{$columnId}{$line[$headerHash{$columnId}]} = "$idPathHash{$columnId}$line[$headerHash{$columnId}]\\";
				}	
		
			}

			close $currentPatientANNOVARFile;
		}
	}
	
	return \%textAttributeHash;	

}

sub _parseMappingFileSecondPass {

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
				$conceptHash{$currentIndexField} = $currentConceptId;

				#Create the concept object.
				my $conceptDimension = new ConceptDimension(CONCEPT_CD => $currentConceptId, CONCEPT_PATH => $currentConcept, SOURCESYSTEM_CD => $currentStudyId);
	
				#Write the entry for the concept_dimension table.
				print $concept_dimension_out $conceptDimension->toTableFileLine();
			}

		}
	}

	close(field_mapping);
	return \%conceptHash;

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

###########################################


1;