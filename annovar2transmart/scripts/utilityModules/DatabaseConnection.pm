#!/usr/bin/perl

package DatabaseConnection;

use strict;
use warnings;

sub getDatabaseUserName
{
	return "biomart_user";
}

sub getDatabasePassword
{
	return "biomart_user";
}

sub getDatabaseConnectionString
{
	return "dbi:Oracle:host=localhost;sid=orcl";
}

sub getNewIdentifiers
{
	my $numberOfIdsToGet 	= shift;
	my $nameOfSequence		= shift;
	
	if(!$numberOfIdsToGet || !$nameOfSequence)
	{
		print("Parameter Missing - numberOfIdsToGet : $numberOfIdsToGet, nameOfSequence - $nameOfSequence");
		die;
	}
	
	my @returnPatientIdArray = ();
	
	my $dbh = DBI->connect(	DatabaseConnection::getDatabaseConnectionString(),
							DatabaseConnection::getDatabaseUserName(),
							DatabaseConnection::getDatabasePassword()) 
							|| die "Database connection not made: $DBI::errstr";
							
	my $sql = qq{ select level,$nameOfSequence.nextval from dual connect by level<= $numberOfIdsToGet};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	
	while ( my @row = $sth->fetchrow_array() ) { push(@returnPatientIdArray, $row[1]); }
	
	$sth->finish(); 
	
	$dbh->disconnect if defined($dbh);
	
	return @returnPatientIdArray;
}

1;