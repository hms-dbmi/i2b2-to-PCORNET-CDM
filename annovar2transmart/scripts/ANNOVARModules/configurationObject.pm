#!/usr/bin/perl

package configurationObject;

use strict;
use warnings;
use Carp;

sub new {
    my $class = shift;
    my %params  = @_;
    my $self = {};
    
    $self->{'BASE_PATH'} 					= $params{'BASE_PATH'};
    $self->{'STUDY_ID'} 					= $params{'STUDY_ID'};
    $self->{'VARIANT_DATA_FILE'} 			= $self->{'BASE_PATH'} . $params{'VARIANT_DATA_FILE'};
    $self->{'PATIENT_DATA_DIRECTORY'} 		= $self->{'BASE_PATH'} . $params{'PATIENT_DATA_DIRECTORY'};
	$self->{'VARIANT_DATA_DIRECTORY'} 		= $self->{'BASE_PATH'} . $params{'VARIANT_DATA_DIRECTORY'};
    $self->{'MAPPING_FILE_DIRECTORY'} 		= $self->{'BASE_PATH'} . $params{'MAPPING_FILE_DIRECTORY'};
    $self->{'CONCEPT_DIMENSION_OUT_FILE'} 	= $self->{'BASE_PATH'} . $params{'CONCEPT_DIMENSION_OUT_FILE'};
    $self->{'PATIENT_DIMENSION_OUT_FILE'} 	= $self->{'BASE_PATH'} . $params{'PATIENT_DIMENSION_OUT_FILE'};
    $self->{'I2B2_OUT_FILE'} 				= $self->{'BASE_PATH'} . $params{'I2B2_OUT_FILE'};
    $self->{'OBSERVATION_FACT_OUT_FILE'} 	= $self->{'BASE_PATH'} . $params{'OBSERVATION_FACT_OUT_FILE'};
    $self->{'SUBJECT_PREFIX'} 				= $params{'SUBJECT_PREFIX'};
    $self->{'SQLLDR_LOGIN_STRING'} 			= $params{'SQLLDR_LOGIN_STRING'};
    
    bless $self, $class;
    return $self;
}


1;