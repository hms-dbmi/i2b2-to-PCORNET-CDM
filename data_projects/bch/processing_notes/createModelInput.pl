#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Time::Local;
use Time::Piece;
use POSIX;

my $srcFile 		= $ARGV[0];
my $outDir 		= $ARGV[1];
my $patientBirthDateFile= $ARGV[2];
my $debugFlag 		= $ARGV[3];

my $F;
my $patientFile;

print("DEBUG - parseNLP.pl : Attemping to open input file directory $srcFile\n");

open($F, "<", $patientBirthDateFile ) or die $!;

my %patientBirthDateHash;

while(my $line = <$F>) {
chomp $line;
	#my @values = split/\|/,$line,2;
	
	#$patientBirthDateHash{$values[0]} = $values[1];


	my $start = timegm 0,0,0,1,0,80;
	my $end = timegm 0,0,0,1,0,12;
	my $randodate = scalar gmtime $start + rand $end - $start;
	$patientBirthDateHash{$line} = $randodate;

}

close($F);

open($F, "<", $srcFile ) or die $!;

my $debugCounter =0;

while(my $line = <$F>) {
	my @values = split/\|/,$line,10;

	my $patientBirthDate = $patientBirthDateHash{$values[2]};
	my $factDate	     = $values[5];

	my $format = '%a %b %d %H:%M:%S %Y';
	my $format2 = '%Y-%d-%M %H:%M:%S';

	my $diff = Time::Piece->strptime($patientBirthDate, $format) - Time::Piece->strptime($factDate, $format2);

	$diff = ceil(abs $diff/(365*24*60*60));

	my $ageDir = "$outDir/$diff";

	if(!-d $ageDir) 
	{
		mkdir $ageDir or die "Error creating directory: $ageDir";
	}

	if(-e "$ageDir/$values[2]")
	{
		open($patientFile, ">>", "$ageDir/$values[2]" ) or die $!;	
		print $patientFile " $values[3]";
	}
	else
	{
		open($patientFile, ">", "$ageDir/$values[2]" ) or die $!;	
		print $patientFile "$values[2],$diff,$values[3]"; 
	}		

	close($patientFile);
}

close($F);

