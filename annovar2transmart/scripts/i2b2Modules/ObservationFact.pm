#!/usr/bin/perl

package ObservationFact;

use strict;
use warnings;
use Carp;

our @columnList = ("UPLOAD_ID", "UNITS_CD", "CONCEPT_CD", "VALTYPE_CD", "TVAL_CHAR", "NVAL_NUM", "UPDATE_DATE", "END_DATE", "VALUEFLAG_CD", "ENCOUNTER_NUM", "PATIENT_NUM", "OBSERVATION_BLOB", "LOCATION_CD", "START_DATE", "QUANTITY_NUM", "SOURCESYSTEM_CD", "PROVIDER_ID", "INSTANCE_NUM", "MODIFIER_CD", "DOWNLOAD_DATE", "CONFIDENCE_NUM");

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

sub getNewEncounterIdList {

	my $numberOfIdsToGet = shift;
	my $configurationObject = shift;

	my $lastId = DatabaseConnection::getNewIdentifiersLarge($numberOfIdsToGet, "I2B2DEMODATA.SQ_UP_ENCDIM_ENCOUNTERNUM", $configurationObject);

	my $firstId = $lastId - $numberOfIdsToGet;

	print("DEBUG - ObservationFact.pm : Retrieved ($numberOfIdsToGet), First ID ($firstId), Last ID($lastId) \n");
	
	my @returnEncountertIdArray = ();
	
	for (my $i=$firstId; $i<=$lastId; $i++) {
		push(@returnEncountertIdArray, $i);
	}

	return \@returnEncountertIdArray;
}

1;
