#!/usr/bin/perl

package ConceptDimension;

use strict;
use warnings;
use Carp;
use Data::Dumper;

our @columnList = ("UPLOAD_ID","SOURCESYSTEM_CD","CONCEPT_CD","CONCEPT_PATH","CONCEPT_BLOB","UPDATE_DATE","NAME_CHAR","DOWNLOAD_DATE","IMPORT_DATE");

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

sub getNewConceptIdList {

	my $numberOfIdsToGet = shift;
	my $configurationObject = shift;

	my $lastId;

	if($configurationObject->{DEBUG})
	{
		$lastId = $numberOfIdsToGet + 1;
	}
	else
	{
		$lastId = DatabaseConnection::getNewIdentifiersLarge($numberOfIdsToGet, "I2B2DEMODATA.CONCEPT_ID", $configurationObject);
	}
	
	my $firstId = $lastId - $numberOfIdsToGet;

	print("DEBUG - ConceptDimension.pm : Retrieved ($numberOfIdsToGet), First ID ($firstId), Last ID($lastId) \n");
	
	my @returnConceptIdArray = ();
	
	for (my $i=$firstId; $i<=$lastId; $i++) {
		push(@returnConceptIdArray, $i);
	}

	return @returnConceptIdArray;
}

1;
