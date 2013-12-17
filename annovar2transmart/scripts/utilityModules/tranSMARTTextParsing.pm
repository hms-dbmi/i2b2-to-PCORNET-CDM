#!/usr/bin/perl

package tranSMARTTextParsing;

use strict;
use warnings;

sub generateMasterMappingHash {
	
	my $basePath = shift;
	
	my %mappingFileHash = ();
	
	my $masterMappingFile = $basePath . "mapping_files/master_mapping";
	
	print("DEBUG - tranSMARTTextParsing.pm : Attemping to open master mapping file $masterMappingFile\n");
	
	open master_mapping, "<$masterMappingFile"; 
	my $header = <master_mapping>;

	while (<master_mapping>)
	{	
		my $line = $_;
		chomp $line;
		if($line =~ m/^([^\t]+)\t([^\t]+)/)
		{
			$mappingFileHash{$1} = $2
		}
	}
	
	return %mappingFileHash;

}



1;