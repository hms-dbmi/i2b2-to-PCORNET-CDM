#!/usr/bin/perl

use Data::Dumper;

#This is the directory we will parse to get the column names.
my ($srcDirectory) = @ARGV;

#This is the first line in the column mapping file.
my $columnMappingHeader = "Filename\tCategory Code\tColumn Number\tData Label\tData Label Source\tControlled Vocab Cd\n";

#Name of the column mapping output file.
my $columnMappingFileName = "columnMapping.txt";

#Store the filename and number of columns in it.
my %filesAndHeaderCount = ();

print("DEBUG - create_column_mapping_from_directory.pl : Attemping to open data input directory $srcDirectory\n");

opendir(D, $srcDirectory) || die "Can't opendir: $!\n";

while (my $f = readdir(D)) 
{
	if($f =~ m/.csv$/)
	{	
		open my $currentInputFile, '<', "$srcDirectory$f" || die "Can't openfile: $!\n";
		my $dataHeader = <$currentInputFile>;
		close $currentInputFile;
		
		chomp($dataHeader);
	
		my @headerArray = split(/,/,$dataHeader);

		$filesAndHeaderCount{$f} = \@headerArray;
	}
}

open my $outputColumnMappingFile, '>' , "$columnMappingFileName";

print $outputColumnMappingFile $columnMappingHeader;

#
while(my($k, $v) = each %filesAndHeaderCount) 
{ 
	my @headerArray = @$v;
	
	for my $arrayIndex (0 .. $#headerArray) 
	{
		my $currentHeader = $headerArray[$arrayIndex];
		my $categoryCode = '';
		my $dataLabel = '';	
				
		#The _ should be converted to the hierarchy delimiter. 
		$currentHeader =~ s/\_/+/g;

		#Split on the hierarchy, last item is the data label.
		my @hierarchySplit = split(/\+/,$currentHeader);
		my $splitCount = @hierarchySplit;
		
		if($splitCount == 1)
		{
			$dataLabel = $hierarchySplit[0];
			
			$currentHeader =~ s/\s/_/g;
			
			if($dataLabel eq "Subject_Id")
			{
				$dataLabel = "SUBJ_ID";
			}
			elsif($dataLabel eq "Gender")
			{
				$dataLabel = "SEX";
			}
			else
			{
				$dataLabel = "OMIT";
			}
			
		}
		else
		{
			my @categoryCodeArray = @hierarchySplit;
			
			$dataLabel = pop(@hierarchySplit);
		
			$categoryCode = join('+',@hierarchySplit);
		}
				
		my $fileName = $k;
		my $columnNumber = $arrayIndex+1;

    	print $outputColumnMappingFile "$fileName\t$categoryCode\t$columnNumber\t$dataLabel\t\n";
	}	
}

close $outputColumnMappingFile;
