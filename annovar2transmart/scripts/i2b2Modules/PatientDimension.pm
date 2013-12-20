#!/usr/bin/perl

package PatientDimension;

use strict;
use warnings;
use Carp;

our @columnList = ("ZIP_CD","UPLOAD_ID","DEATH_DATE","UPDATE_DATE","AGE_IN_YEARS_NUM","SEX_CD","PATIENT_BLOB","RACE_CD","RELIGION_CD","PATIENT_NUM","IMPORT_DATE","INCOME_CD","VITAL_STATUS_CD","LANGUAGE_CD","SOURCESYSTEM_CD","MARITAL_STATUS_CD","BIRTH_DATE","DOWNLOAD_DATE","STATECITYZIP_PATH");

sub new {
    my $class = shift;
    my %params  = @_;
    my $self = {};
    
    foreach(@columnList)
    {	
    	$self->{$_} = $params{$_};
    }
    
    bless $self, $class;
    return $self;
}

sub printColumnHeaders {
	return join("\t", @columnList) . "\n";
}

sub printColumnHeadersInList {
	return "(\"" . join("\",\"", @columnList) . "\")\n";
}

sub toTableFileLine {
	my $self = shift;
	
	my $lineToReturn = "";
	
	foreach(@columnList)
    {
    	my $currentValue = $self->{$_} // "";
    	
    	$lineToReturn = $lineToReturn . $currentValue . "\t";
    }
	
	#Remove last tab.
	chop($lineToReturn);
	
	#Add a new line and return.
    return $lineToReturn . "\n";
}

sub getNewPatientIdList {

	my $numberOfIdsToGet = shift;

	my @returnPatientIdArray = DatabaseConnection::getNewIdentifiers($numberOfIdsToGet, "I2B2DEMODATA.SEQ_PATIENT_NUM");

	return @returnPatientIdArray;
}

1;
