#!/usr/bin/perl

package configurationObject;

use strict;
use warnings;
use Carp;

sub new {
    my $class = shift;
    my %params  = @_;
    my $self = {};
    
    $self->{'BASE_PATH'} 								= $params{'BASE_PATH'};
    $self->{'STUDY_ID'} 								= $params{'STUDY_ID'};
    $self->{'PATIENT_DATA_DIRECTORY'} 					= $self->{'BASE_PATH'} . $params{'PATIENT_DATA_DIRECTORY'};
    $self->{'MAPPING_FILE_DIRECTORY'} 					= $self->{'BASE_PATH'} . $params{'MAPPING_FILE_DIRECTORY'};
    $self->{'CONCEPT_DIMENSION_OUT_FILE'} 				= $self->{'BASE_PATH'} . $params{'CONCEPT_DIMENSION_OUT_FILE'};
    $self->{'PATIENT_DIMENSION_OUT_FILE'} 				= $self->{'BASE_PATH'} . $params{'PATIENT_DIMENSION_OUT_FILE'};
    $self->{'I2B2_OUT_FILE'} 							= $self->{'BASE_PATH'} . $params{'I2B2_OUT_FILE'};
    $self->{'OBSERVATION_FACT_OUT_FILE'} 				= $self->{'BASE_PATH'} . $params{'OBSERVATION_FACT_OUT_FILE'};
    $self->{'CONCEPT_COUNT_OUT_FILE'} 					= $self->{'BASE_PATH'} . $params{'CONCEPT_COUNT_OUT_FILE'};
    $self->{'CONCEPTS_FOLDERS_PATIENTS_OUT_FILE'} 		= $self->{'BASE_PATH'} . $params{'CONCEPTS_FOLDERS_PATIENTS_OUT_FILE'};    
    $self->{'PATIENT_MAPPING_OUT_FILE'} 				= $self->{'BASE_PATH'} . $params{'PATIENT_MAPPING_OUT_FILE'};    
    $self->{'SUBJECT_PREFIX'} 							= $params{'SUBJECT_PREFIX'};
    $self->{'SQLLDR_LOGIN_STRING'} 						= $params{'SQLLDR_LOGIN_STRING'};
    $self->{'DATABASE_CONNECTION_STRING'} 				= $params{'DATABASE_CONNECTION_STRING'};
    $self->{'DATABASE_USERNAME'} 						= $params{'DATABASE_USERNAME'};
    $self->{'DATABASE_PASSWORD'} 						= $params{'DATABASE_PASSWORD'};
    $self->{'PATIENT_FILE_SUFFIX'} 						= $params{'PATIENT_FILE_SUFFIX'};
    $self->{'DEBUG'} 									= $params{'DEBUG'};
    $self->{'FACT_SET'} 								= $params{'FACT_SET'};    
        
    bless $self, $class;
    return $self;
}


1;