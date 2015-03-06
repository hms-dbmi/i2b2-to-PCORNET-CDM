#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my $srcFile = "../load_nlp_data/emerge_asd_15k.txt.pre_pms_dn.out.snowmed";

print("DEBUG - parseNLP.pl : Attemping to open input file directory $srcFile\n");

open(F, "<", $srcFile) or die $!;

my $debugCounter = 0;

my %conceptHash;

my %yearsConceptHash;
my %yearsFactHash;

while(my $line = <F>) {
	my @values = split/\|/,$line,10;
	my @yearvalues = split/\-/,$values[5],2;

	$conceptHash{$values3}++;

	$yearsPatientHash{$yearvalues[0]}{$values[2]}++;
	$yearsConceptHash{$yearvalues[0]}{$values[3]}++;	
	$yearsFactHash{$yearvalues[0]}++;	

	$debugCounter++;

	last if($debugCounter > 1000);
	
}


close(F);

open my $srcFileOut, '>' , "./outfiles/$srcFile.outpy";
while(my($k, $v) = each %yearsPatientHash) 
{
	while(my($k2,$v2) = each %$v){
		print $srcFileOut "$k,$k2,$v2\n";	
	}

}
close($srcFileOut);

open my $srcFileOut, '>' , "./outfiles/$srcFile.outcy";
while(my($k, $v) = each %yearsConceptHash) 
{
	while(my($k2,$v2) = each %$v){
		print $srcFileOut "$k,$k2,$v2\n";	
	}
}
close($srcFileOut);

open my $srcFileOut, '>' , "$srcFile.outfy";
while(my($k, $v) = each %yearsFactHash) 
{

	print $srcFileOut "$k,$v\n";	

}
close($srcFileOut);

