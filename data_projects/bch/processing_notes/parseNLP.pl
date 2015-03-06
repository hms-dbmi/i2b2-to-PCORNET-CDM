#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Benchmark qw( cmpthese );

my $srcFile = "emerge_asd_15k.txt.pre_pms_dn";

print("DEBUG - parseNLP.pl : Attemping to open input file directory $srcFile\n");

open(F, "<", $srcFile) or die $!;

my %patientHash;
my %conceptHash;

while(my $line = <F>) {
	my @values = split/\|/,$line,10;
	
	$patientHash{$values[2]}++;
	$conceptHash{$values[3]}++;
		
}

close(F);

open my $srcFileOut, '>' , "./outfiles/$srcFile.outp";
while(my($k, $v) = each %patientHash) 
{
	print $srcFileOut "$k,$v\n";
}
close($srcFileOut);

open my $srcFileOut, '>' , "./outfiles/$srcFile.outc";
while(my($k, $v) = each %conceptHash) 
{
	print $srcFileOut "$k,$v\n";
}
close($srcFileOut);







# 
# opendir(D, $srcDirectory) || die "Can't opendir: $!\n";
# 
# while (my $f = readdir(D)) 
# {
# 	if($f =~ m/.txt$/)
# 	{	
# 		open my $currentInputFile, '<', "$srcDirectory$f" || die "Can't openfile: $!\n";
# 	
# 		my @headerArray = split(/\t/,$dataHeader);
# 
# 		$filesAndHeaderCount{$f} = \@headerArray;
# 	}
# }
