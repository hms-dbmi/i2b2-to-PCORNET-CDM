#!/usr/bin/perl

package i2b2;

use strict;
use warnings;
use Carp;

our @columnList = ("C_HLEVEL","C_FULLNAME","C_NAME","C_SYNONYM_CD","C_VISUALATTRIBUTES","C_TOTALNUM","C_BASECODE","C_METADATAXML","C_FACTTABLECOLUMN","C_TABLENAME","C_COLUMNNAME","C_COLUMNDATATYPE","C_OPERATOR","C_DIMCODE","C_COMMENT","C_TOOLTIP","UPDATE_DATE","DOWNLOAD_DATE","IMPORT_DATE","SOURCESYSTEM_CD","VALUETYPE_CD","I2B2_ID","M_APPLIED_PATH","M_EXCLUSION_CD","C_PATH","C_SYMBOL");
our @columnListForCTL = ("C_HLEVEL","C_FULLNAME","C_NAME","C_SYNONYM_CD","C_VISUALATTRIBUTES","C_TOTALNUM","C_BASECODE","C_METADATAXML","C_FACTTABLECOLUMN","C_TABLENAME","C_COLUMNNAME","C_COLUMNDATATYPE","C_OPERATOR","C_DIMCODE","C_COMMENT","C_TOOLTIP","UPDATE_DATE SYSDATE","DOWNLOAD_DATE","IMPORT_DATE","SOURCESYSTEM_CD","VALUETYPE_CD","I2B2_ID","M_APPLIED_PATH","M_EXCLUSION_CD","C_PATH","C_SYMBOL");

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

	my @returnPatientIdArray = DatabaseConnection::getNewIdentifiers($numberOfIdsToGet, "I2B2METADATA.I2B2_ID_SEQ");

	return @returnPatientIdArray;
}

1;