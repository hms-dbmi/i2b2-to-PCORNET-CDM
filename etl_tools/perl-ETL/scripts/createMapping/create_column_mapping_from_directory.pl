#!/usr/bin/perl

use Data::Dumper;
use Scalar::Util qw(looks_like_number);

#This is the directory we will parse to get the column names.
my $srcDirectory = $ARGV[0];
my $topLevelNode = $ARGV[1];

#This is the first line in the column mapping file.
my $columnMappingHeader = "HEADER\tPATH\tDATATYPE\n";

#Store the filename and number of columns in it.
my %filesAndHeaderCount = ();

#This will be a hash of columns that we won't use.
my %omitColumnsHash = ();
my %specialColumnsHash = ();

my @masterMappingArray 		= ();
my %tempFieldTypeHash		= ();
my %finalFieldTypeHash		= ();


###################
#Read file that omits columns into an array.
open my $omitColumns, '<' , "columns.omit" || die "Can't openfile: $!\n";

while (<$omitColumns>)
{	
	my $line = $_;
	
	chomp $line;
	
	$omitColumnsHash{$line} = 1;
}
	
close $omitColumns;
###################

###################
#Read file that omits columns into an array.
open my $specialColumns, '<' , "columns.special" || die "Can't openfile: $!\n";

while (<$specialColumns>)
{	
	my $line = $_;
	
	chomp $line;
	
	my @conceptPathIdSplit = split(/\t/,$line);
	
	$specialColumnsHash{$conceptPathIdSplit[0]} = $conceptPathIdSplit[1];
}
	
close $specialColumns;
###################


print("DEBUG - create_column_mapping_from_directory.pl : Attemping to open data input directory $srcDirectory\n");

opendir(D, $srcDirectory) || die "Can't opendir: $!\n";

while (my $f = readdir(D)) 
{
	if($f =~ m/.txt$/)
	{	
		open my $currentInputFile, '<', "$srcDirectory$f" || die "Can't openfile: $!\n";
		my $dataHeader = <$currentInputFile>;
		
		chomp($dataHeader);
	
		my @headerArray = split(/\t/,$dataHeader);

		$filesAndHeaderCount{$f} = \@headerArray;
		
		#This section does automatic detection of column types.
		my $rowCount = 0;
		
		while (<$currentInputFile>)
		{
			my $line = $_;
	
			chomp $line;
	
			my @fieldSplit = split(/\t/,$line);
			
			for my $i (0 .. $#fieldSplit)
			{
				my $fieldType = "T";
				
				if (looks_like_number($fieldSplit[$i]))
				{
					$fieldType = "N";
				}
				  
				if(exists $fieldTypeHash{$headerArray[$i]}) 
				{
					$fieldTypeHash{$headerArray[$i]} = $fieldTypeHash{$headerArray[$i]} . $fieldType;
				}
				else 
				{

					$fieldTypeHash{$headerArray[$i]} = $fieldType;
				}				  
			}
				
			$rowCount = $rowCount + 1;
			
			if($rowCount > 20) 
			{
				#Consolidate the column types.
				while(my($k, $v) = each %fieldTypeHash) 		
				{
					my $numericCount = ($v =~ tr/N//);

					if($numericCount > 10)
					{
						$finalFieldTypeHash{$k} = "N";
					}
					else
					{
						$finalFieldTypeHash{$k} = "T";					
					}
				}
				
				$rowCount = 0;
				break;
			}
		}

		close $currentInputFile;
	}
}

while(my($k, $v) = each %filesAndHeaderCount) 
{ 
	my @headerArray = @$v;

	push(@masterMappingArray,$k);

	open my $outputColumnMappingFile, '>' , "$k.map" || die "Can't openfile: $!\n";;

	print $outputColumnMappingFile $columnMappingHeader;

	for my $arrayIndex (0 .. $#headerArray) 
	{
		my $currentHeader = $headerArray[$arrayIndex];
		my $categoryCode = '';
		my $dataLabel = '';	
		
		if (!exists $omitColumnsHash{$currentHeader})
		{
			if(!exists $specialColumnsHash{$currentHeader})
			{
				$currentHeader =~ s/\./+/g;
		
				#Split on the hierarchy, last item is the data label.
				my @hierarchySplit = split(/\+/,$currentHeader);
				my $splitCount = @hierarchySplit;

				if($splitCount == 1)
				{
					$dataLabel = $hierarchySplit[0];
			
					$currentHeader =~ s/\s/_/g;
				
					($categoryCode = $k) =~ s/\.[^.]+$//;

				}
				else
				{
					$dataLabel = pop(@hierarchySplit);
		
					$categoryCode = join('+',@hierarchySplit);
				}
				
				my $fileName = $k;
				my $columnNumber = $arrayIndex+1;
				my $columnType = "T";

				#Pull column type from auto detection above.
				if(exists $fieldTypeHash{$headerArray[$arrayIndex]})
				{
					$columnType = $finalFieldTypeHash{$headerArray[$arrayIndex]};
				}

				print $outputColumnMappingFile "$headerArray[$arrayIndex]\t$topLevelNode\\\\$categoryCode\\\\$dataLabel\\\\\t$columnType\n";

    		}
    		else
    		{
    			print "Special Header\n";
    			print $outputColumnMappingFile "$headerArray[$arrayIndex]\t$specialColumnsHash{$currentHeader}\t$specialColumnsHash{$currentHeader}\n";
    		}
    	}
    	else
    	{
    		print "Skipping Header - $currentHeader\n";
    	}
	}
	
	close $outputColumnMappingFile;
		
}

###################
#Write master mapping file.
open my $masterMappingFile, '>' , "master_mapping" || die "Can't openfile: $!\n";

print $masterMappingFile "mappingfile	mappingtype\n";

foreach(@masterMappingArray)
{
	print $masterMappingFile "$_.map	INDIVIDUAL\n";
}

close $masterMappingFile;
###################

