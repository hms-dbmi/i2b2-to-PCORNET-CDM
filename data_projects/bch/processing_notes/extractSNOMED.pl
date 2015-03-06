#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Benchmark qw( cmpthese );

my $srcFile = "./load_nlp_data/emerge_asd_15k.txt.pre_pms_dn";

print("DEBUG - parseNLP.pl : Attemping to open input file directory $srcFile\n");
my $f;
open($f, "<", $srcFile) or die $!;
open my $srcFileOut, '>' , "$srcFile.out.snowmed.positive";

while(my $line = <$f>) {
	my @values = split/\|/,$line,10;
	
	if($values[3] =~ /SNO\:/ && $values[7]=='1')
	{
		print $srcFileOut $line;
	}
	
}

close($f);
close($srcFileOut);
