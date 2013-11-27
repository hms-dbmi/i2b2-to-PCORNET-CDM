#!/usr/bin/perl

package PatientDimension;

use strict;
use warnings;
use Carp;

sub new {
    my $class = shift;
    my $self  = { 
    	_ZIP_CD				=> shift,
    	_UPLOAD_ID			=> shift,
    	_DEATH_DATE			=> shift,
    	_UPDATE_DATE		=> shift,
    	_AGE_IN_YEARS_NUM	=> shift,
    	_SEX_CD				=> shift,
    	_PATIENT_BLOB		=> shift,
    	_RACE_CD			=> shift,
    	_RELIGION_CD		=> shift,
    	_PATIENT_NUM		=> shift,
    	_IMPORT_DATE		=> shift,
    	_INCOME_CD			=> shift,
    	_VITAL_STATUS_CD	=> shift,
    	_LANGUAGE_CD		=> shift,
    	_SOURCESYSTEM_CD	=> shift,
    	_MARITAL_STATUS_CD	=> shift,
    	_BIRTH_DATE			=> shift,
    	_DOWNLOAD_DATE		=> shift,
    	_STATECITYZIP_PATH	=> shift
    };
     
    bless $self, $class;
    return $self;
}

sub printColumnHeaders {
	return "ZIP_CD\tUPLOAD_ID\tDEATH_DATE\tUPDATE_DATE\tAGE_IN_YEARS_NUM\tSEX_CD\tPATIENT_BLOB\tRACE_CD\tRELIGION_CD\tPATIENT_NUM\tIMPORT_DATE\tINCOME_CD\tVITAL_STATUS_CD\tLANGUAGE_CD\tSOURCESYSTEM_CD\tMARITAL_STATUS_CD\tBIRTH_DATE\tDOWNLOAD_DATE\tSTATECITYZIP_PATH\n";
}

sub toTableFileLine {
	my $self = shift;
    return "$self->{_ZIP_CD}\t$self->{_UPLOAD_ID}\t$self->{_DEATH_DATE}\t$self->{_UPDATE_DATE}\t$self->{_AGE_IN_YEARS_NUM}\t$self->{_SEX_CD}\t$self->{_PATIENT_BLOB}\t$self->{_RACE_CD}\t$self->{_RELIGION_CD}\t$self->{_PATIENT_NUM}\t$self->{_IMPORT_DATE}\t$self->{_INCOME_CD}\t$self->{_VITAL_STATUS_CD}\t$self->{_LANGUAGE_CD}\t$self->{_SOURCESYSTEM_CD}\t$self->{_MARITAL_STATUS_CD}\t$self->{_BIRTH_DATE}\t$self->{_DOWNLOAD_DATE}\t$self->{_STATECITYZIP_PATH}\n";
}

1;
