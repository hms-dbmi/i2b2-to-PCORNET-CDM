#!/usr/bin/perl

use Data::Dumper;

#This is the directory we will parse to get the column names.
my $srcDirectory = $ARGV[0];
my $topLevelNode = $ARGV[1];

#This is the first line in the column mapping file.
my $columnMappingHeader = "HEADER\tPATH\tDATATYPE\n";

#Store the filename and number of columns in it.
my %filesAndHeaderCount = ();

#This will be a hash of columns that we won't use.
my %omitColumnsHash = ();

my @masterMappingArray = ();

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


print("DEBUG - create_column_mapping_from_directory.pl : Attemping to open data input directory $srcDirectory\n");

opendir(D, $srcDirectory) || die "Can't opendir: $!\n";

while (my $f = readdir(D)) 
{
	if($f =~ m/.txt$/)
	{	
		open my $currentInputFile, '<', "$srcDirectory$f" || die "Can't openfile: $!\n";
		my $dataHeader = <$currentInputFile>;
		close $currentInputFile;
		
		chomp($dataHeader);
	
		my @headerArray = split(/\t/,$dataHeader);

		$filesAndHeaderCount{$f} = \@headerArray;
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
		
			$currentHeader =~ s/\./+/g;
		
			#Split on the hierarchy, last item is the data label.
			my @hierarchySplit = split(/\+/,$currentHeader);
			my $splitCount = @hierarchySplit;

			if($splitCount == 1)
			{
				$dataLabel = $hierarchySplit[0];
			
				$currentHeader =~ s/\s/_/g;
				
				if($dataLabel eq "src_subject_id")
				{
					$dataLabel = "SUBJ_ID";
				}
				elsif($dataLabel eq "Gender")
				{
					$dataLabel = "SEX";
				}
				else
				{
					$dataLabel = $hierarchySplit[0];
				}
				
				($categoryCode = $k) =~ s/\.[^.]+$//;

			}
			elsif($currentHeader eq "measure+individual")
			{
				$dataLabel = "SUBJ_ID";
			}				
			else
			{
				$dataLabel = pop(@hierarchySplit);
		
				$categoryCode = join('+',@hierarchySplit);
			}
				
			my $fileName = $k;
			my $columnNumber = $arrayIndex+1;

			if($dataLabel eq "SUBJ_ID")
			{
				print $outputColumnMappingFile "$headerArray[$arrayIndex]\tSUBJECT_ID\tSUBJECT_ID\n";
    		}
    		else
    		{
    			print $outputColumnMappingFile "$headerArray[$arrayIndex]\t$topLevelNode\\\\$categoryCode\\\\$dataLabel\\\\\tT\n";
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

