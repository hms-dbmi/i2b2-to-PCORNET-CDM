#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Benchmark qw( cmpthese );

my $srcFile 			= $ARGV[0];
my $srcSemanticFilterFile 	= $ARGV[1];
my %validCodeHash;
my $f;
my $debugCounter = 0;

print("DEBUG : Attemping to open input file directory $srcFile\n");

open(my $semanticFilterFile, "<", $srcSemanticFilterFile) or die $!;

while(my $line = <$semanticFilterFile>) {
chomp $line;
        my @values = split/\|/,$line,2;
	$validCodeHash{$values[1]}++;
}

close($semanticFilterFile);

print("DEBUG : Finished gathering semantic type codes\n");

open($f, "<", $srcFile) or die $!;
open my $srcFileOut, '>' , "$srcFile.out.snowmed.positive";

while(my $line = <$f>) {
	my @values = split/\|/,$line,10;

	if($values[3] =~ /SNO\:/ && $values[7]=='1')
	{
		my $bareSNO = $values[3];
		$bareSNO =~ s/SNO\://;

		if(exists $validCodeHash{$bareSNO})
		{
			print $srcFileOut $line;
		}
	}
	#$debugCounter++;
	#last if($debugCounter > 100000);
	
}

close($f);
close($srcFileOut);
