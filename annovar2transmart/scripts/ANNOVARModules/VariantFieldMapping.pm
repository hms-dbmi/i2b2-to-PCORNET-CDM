#!/usr/bin/perl

package VariantFieldMapping;

use strict;
use warnings;
use Carp;

our @columnList = ("","","","","");

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

