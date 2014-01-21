#!/usr/bin/perl

package i2b2;

use strict;
use warnings;
use Carp;

our @columnList = ("C_HLEVEL","C_FULLNAME","C_NAME","C_SYNONYM_CD","C_VISUALATTRIBUTES","C_TOTALNUM","C_BASECODE","C_METADATAXML","C_FACTTABLECOLUMN","C_TABLENAME","C_COLUMNNAME","C_COLUMNDATATYPE","C_OPERATOR","C_DIMCODE","C_COMMENT","C_TOOLTIP","DOWNLOAD_DATE","IMPORT_DATE","SOURCESYSTEM_CD","VALUETYPE_CD","I2B2_ID","M_APPLIED_PATH","M_EXCLUSION_CD","C_PATH","C_SYMBOL");
our @columnListForCTL = ("C_HLEVEL","C_FULLNAME","C_NAME","C_SYNONYM_CD","C_VISUALATTRIBUTES","C_TOTALNUM","C_BASECODE","C_METADATAXML CHAR(10000)","C_FACTTABLECOLUMN","C_TABLENAME","C_COLUMNNAME","C_COLUMNDATATYPE","C_OPERATOR","C_DIMCODE","C_COMMENT","C_TOOLTIP","DOWNLOAD_DATE","IMPORT_DATE","SOURCESYSTEM_CD","VALUETYPE_CD","I2B2_ID","M_APPLIED_PATH","M_EXCLUSION_CD","C_PATH","C_SYMBOL","UPDATE_DATE SYSDATE");

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

sub printColumnHeadersInListForCTL {
	return "(" . join(",", @columnListForCTL) . ")\n";
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


sub getNewI2b2IdList {

	my $numberOfIdsToGet = shift;
	my $configurationObject = shift;

	my $lastId = DatabaseConnection::getNewIdentifiersLarge($numberOfIdsToGet, "I2B2METADATA.I2B2_ID_SEQ", $configurationObject);

	my $firstId = $lastId - $numberOfIdsToGet;

	print("DEBUG - i2b2.pm : Retrieved ($numberOfIdsToGet), First ID ($firstId), Last ID($lastId) \n");
	
	my @returni2b2IdArray = ();
	
	for (my $i=$firstId; $i<=$lastId; $i++) {
		push(@returni2b2IdArray, $i);
	}

	return @returni2b2IdArray;
}

1;