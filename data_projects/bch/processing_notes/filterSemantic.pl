#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

my @semanticList = ('T046','T047','T048','T049','T050','T019');

my $srcFile             = $ARGV[0];

my $F;
my $srcFileOut;

open($F, "<", $srcFile ) or die $!;
open($srcFileOut, '>' , "$srcFile.semantic") or die $!;

my $debugCounter =0;

while(my $line = <$F>) {
        my @values = split/\|/,$line,4;

	if($values[0]~~@semanticList)
	{
		print $srcFileOut $values[0] . "|" . $values[2]  . "\n";
	}
}

close($F);
close($srcFileOut);
