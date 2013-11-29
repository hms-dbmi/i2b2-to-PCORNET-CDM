#!/usr/bin/perl

package VariantFieldMapping;

use strict;
use warnings;
use Carp;

our @columnList = ("VARIANT_FILE_VARIABLE_COLUMN","VARIANT_FILE_VALUE_COLUMN","COLUMN_DELIMITER","VARIABLE_NAME","CONCEPT_PATH","CONCEPT_CD");

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

1;

