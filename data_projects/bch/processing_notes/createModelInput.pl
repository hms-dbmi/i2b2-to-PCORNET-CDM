#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Time::Local;
use Time::Piece;
use POSIX;
use DBI;

my $srcFile 		= $ARGV[0];
my $outDir 		= $ARGV[1];
my $debugFlag 		= $ARGV[3];

my $F;
my $patientFile;

print("DEBUG - parseNLP.pl : Attemping to open input file directory $srcFile\n");

my %patientBirthDateHash;

my $dbh = DBI->connect('dbi:Oracle:host=dwtst.tch.harvard.edu;sid=DWTST;port=1521', 'BIOMART_USER', 'dwtst') or die "Couldn't open database: $DBI::errstr; stopped";

my $sql = qq{ SELECT PD.PATIENT_NUM,TO_CHAR(TO_TIMESTAMP(PD.BIRTH_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),'DD-MON-YY HH12.MI.SS') FROM TM_WZ.DISTINCT_PATIENTS DP INNER JOIN TM_LZ.PATIENT_DIMENSION_I2B2_MTM PD ON PD.PATIENT_NUM = DP.PATIENT_NUM }; 
my $sth = $dbh->prepare($sql);
$sth->execute();

my($patientNum, $birthDate);                     
$sth->bind_columns(undef, \$patientNum, \$birthDate);

while( $sth->fetch() ) {
		$patientBirthDateHash{$patientNum} = $birthDate;

	}
$sth->finish();         


#Precreate the age directories.
my $directoryCounter=1;

while($directoryCounter<16)
{
	my $ageDir = "$outDir/$directoryCounter";
	if(!-d $ageDir)
        {
        	mkdir $ageDir or die "Error creating directory: $ageDir";
        }

	$directoryCounter++;

}


open($F, "<", $srcFile ) or die $!;

my $debugCounter =0;

while(my $line = <$F>) {
	my @values = split/\|/,$line,10;

	my $patientBirthDate = $patientBirthDateHash{$values[2]};
	my $factDate	     = $values[5];

	my $format = '%d-%b-%y %H.%M.%S';
	my $format2 = '%Y-%d-%M %H:%M:%S';

	my $diff = Time::Piece->strptime($patientBirthDate, $format) - Time::Piece->strptime($factDate, $format2);

	$diff = ceil(abs $diff/(365*24*60*60));

	if ($diff < 16)
	{	
		my $ageDir = "$outDir/$diff";

		my $strippedSNOMED = $values[3];
		$strippedSNOMED =~ s/SNO\://g;

		open($patientFile, ">>", "$ageDir/$values[2]" ) or die $!;	
		print $patientFile " $strippedSNOMED";

		close($patientFile);
	}

}

close($F);

