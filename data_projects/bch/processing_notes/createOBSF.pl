#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Benchmark qw( cmpthese );

my $srcFile = "emerge_asd_15k.txt.pre_pms_dn.out.snowmed.positive";

print("DEBUG - parseNLP.pl : Attemping to open input file directory $srcFile\n");

my $debugCounter = 0;

open(F, "<", $srcFile) or die $!;
open my $srcFileOut, '>' , "$srcFile.obsf";
while(my $line = <F>) {
	my @values = split/\|/,$line,10;

if($values[7]=='1')
{
	my $strippedSnoCode = $values[3];	
	$strippedSnoCode =~ s/SNO://; 

	print $srcFileOut "$values[1],$values[2],$strippedSnoCode,NULL,,\@,T,,,,,,,,,,,,CTAKESEMERGE,,,$values[6]\n";

	#$debugCounter++;
	#last if($debugCounter > 100);
}
}
close(F);
close($srcFileOut);

