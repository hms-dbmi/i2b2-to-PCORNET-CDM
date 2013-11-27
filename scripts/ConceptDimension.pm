#!/usr/bin/perl

package ConceptDimension;

use strict;
use warnings;
use Carp;

sub new {
    my $class = shift;
    my $self  = { 
    	_UPLOAD_ID 			=> shift,
    	_SOURCESYSTEM_CD 	=> shift,
    	_CONCEPT_CD			=> shift,
    	_CONCEPT_PATH		=> shift,
    	_CONCEPT_BLOB		=> shift,
    	_UPDATE_DATE		=> shift,
    	_NAME_CHAR			=> shift,
    	_DOWNLOAD_DATE		=> shift,
    	_IMPORT_DATE		=> shift
    };
     
    bless $self, $class;
    return $self;
}

sub printColumnHeaders {
	return "UPLOAD_ID\tSOURCESYSTEM_CD\tCONCEPT_CD\tCONCEPT_PATH\tCONCEPT_BLOB\tUPDATE_DATE\tNAME_CHAR\tDOWNLOAD_DATE\tIMPORT_DATE\n";
}

sub toTableFileLine {
	my $self = shift;
    return "$self->{_UPLOAD_ID}\t$self->{_SOURCESYSTEM_CD}\t$self->{_CONCEPT_CD}\t$self->{_CONCEPT_PATH}\t$self->{_CONCEPT_BLOB}\t$self->{_UPDATE_DATE}\t$self->{_NAME_CHAR}\t$self->{_DOWNLOAD_DATE}\t$self->{_IMPORT_DATE}\n";
}

1;

