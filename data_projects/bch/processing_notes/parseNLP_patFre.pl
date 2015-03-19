#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my $srcFile = "/mnt/nfs/data/AUTISM/CLINICAL_NOTES/CTAKES/working/load_nlp_data/emerge_asd_15k.txt.pre_pms_dn.out.snowmed";

print("DEBUG - parseNLP.pl : Attemping to open input file directory $srcFile\n");

open(F, "<", $srcFile) or die $!;

my %conceptHash;
my %patientHash;

my $debugCounter = 0;

while(my $line = <F>) {

	my @values = split/\|/,$line,10;

        $conceptHash{$values[3]}{$values[2]}++;
	$patientHash{$values[2]}++;

	#$debugCounter++;
	#last if($debugCounter>1000);

}

close(F);

open my $srcFileOut, '>' , "$srcFile.outpff";
while(my($k, $v) = each %conceptHash)
{
	my $keyCount = keys(%$v);
	print $srcFileOut "$k,$keyCount\n";
}
close($srcFileOut);

open $srcFileOut, '>' , "$srcFile.outcff";
while(my($k, $v) = each %conceptHash)
{
        my $keyCount = keys(%$v);
        print $srcFileOut "$k,$keyCount\n";
}
close($srcFileOut);

my $keyCount = keys(%patientHash);

print("COUNT : $keyCount\n");

