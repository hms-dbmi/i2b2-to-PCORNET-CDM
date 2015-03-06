#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my $srcFile = "/mnt/nfs/data/AUTISM/CLINICAL_NOTES/CTAKES/working/load_nlp_data/emerge_asd_15k.txt.pre_pms_dn.out.snowmed";

print("DEBUG - parseNLP.pl : Attemping to open input file directory $srcFile\n");

open(F, "<", $srcFile) or die $!;

my %patientHash;
my %conceptHash;

my %yearsPatientHash;
my %yearsConceptHash;
my %yearsFactHash;

my $debugCounter = 0;

while(my $line = <F>) {

	my @values = split/\|/,$line,10;
	my @yearvalues = split/\-/,$values[5],2;

        $patientHash{$values[2]}++;
        $conceptHash{$values[3]}++;

	$yearsPatientHash{$yearvalues[0]}{$values[2]}++;
	$yearsConceptHash{$yearvalues[0]}{$values[3]}++;	
	$yearsFactHash{$yearvalues[0]}++;	

	$debugCounter++;
	#last if($debugCounter>1000);

}

close(F);

open my $srcFileOut, '>' , "$srcFile.outp";
while(my($k, $v) = each %patientHash)
{
        print $srcFileOut "$k,$v\n";
}
close($srcFileOut);

open $srcFileOut, '>' , "$srcFile.outc";
while(my($k, $v) = each %conceptHash)
{
        print $srcFileOut "$k,$v\n";
}
close($srcFileOut);


open $srcFileOut, '>' , "$srcFile.outpy";
while(my($k, $v) = each %yearsPatientHash) 
{
	while(my($k2,$v2) = each %$v){
		print $srcFileOut "$k,$k2,$v2\n";	
	}

}
close($srcFileOut);

open $srcFileOut, '>' , "$srcFile.outcy";
while(my($k, $v) = each %yearsConceptHash) 
{
	while(my($k2,$v2) = each %$v){
		print $srcFileOut "$k,$k2,$v2\n";	
	}
}
close($srcFileOut);

open $srcFileOut, '>' , "$srcFile.outfy";
while(my($k, $v) = each %yearsFactHash) 
{

	print $srcFileOut "$k,$v\n";	

}
close($srcFileOut);

