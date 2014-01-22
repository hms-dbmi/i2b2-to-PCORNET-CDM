#!/usr/bin/perl

package DatabaseConnection;

use strict;
use warnings;
use DBI;

sub getNewIdentifiers
{
	my $numberOfIdsToGet 	= shift;
	my $nameOfSequence		= shift;
	my $configurationObject = shift;
	
	if(!$numberOfIdsToGet || !$nameOfSequence)
	{
		print("Parameter Missing - numberOfIdsToGet : $numberOfIdsToGet, nameOfSequence - $nameOfSequence\n");
		die;
	}
	
	my @returnNewIdArray = ();
	
	my $dbh = DBI->connect(	$configurationObject->{DATABASE_CONNECTION_STRING},
							$configurationObject->{DATABASE_USERNAME},
							$configurationObject->{DATABASE_PASSWORD}) 
							|| die "Database connection not made: $DBI::errstr";
							
	my $sql = qq{ select level,$nameOfSequence.nextval from dual connect by level<= $numberOfIdsToGet};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	
	while ( my @row = $sth->fetchrow_array() ) { push(@returnNewIdArray, $row[1]); }
	
	$sth->finish(); 
	
	$dbh->disconnect if defined($dbh);
	
	print("DEBUG - DatabaseConnection.pm : Retrieved ($numberOfIdsToGet) \n");
	
	return @returnNewIdArray;
}

sub getNewIdentifiersLarge
{
	my $numberOfIdsToGet 	= shift;
	my $nameOfSequence		= shift;
	my $configurationObject = shift;
	
	if(!$numberOfIdsToGet || !$nameOfSequence)
	{
		print("Parameter Missing - numberOfIdsToGet : $numberOfIdsToGet, nameOfSequence - $nameOfSequence");
		die;
	}
	
	if($numberOfIdsToGet < 1)
	{
		print("Number of IDs to get came out negative, ending!");
		die;
	}
	
	my @returnPatientIdArray = ();
	
	my $dbh = DBI->connect(	$configurationObject->{DATABASE_CONNECTION_STRING},
							$configurationObject->{DATABASE_USERNAME},
							$configurationObject->{DATABASE_PASSWORD}) 
							|| die "Database connection not made: $DBI::errstr";				

	$dbh->do(qq{ alter sequence $nameOfSequence increment by $numberOfIdsToGet});
	
	my $lastId = $dbh->selectrow_array(qq{ select $nameOfSequence.nextval from dual});

	$dbh->do(qq{ alter sequence $nameOfSequence increment by 1});
	
	$dbh->disconnect if defined($dbh);
	
	return $lastId;
}

sub getPatientSubjectHash {

	my $configurationObject = shift;

	my %subjectPatientHash = ();

	my $dbh = DBI->connect(	$configurationObject->{DATABASE_CONNECTION_STRING},
							$configurationObject->{DATABASE_USERNAME},
							$configurationObject->{DATABASE_PASSWORD}) 
							|| die "Database connection not made: $DBI::errstr";

	my $sql = qq{ select patient_num,sourcesystem_cd from PATIENT_DIMENSION WHERE SOURCESYSTEM_CD LIKE '$configurationObject->{SUBJECT_PREFIX}%'};
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	
	while ( my @row = $sth->fetchrow_array() ) { $subjectPatientHash{$row[1]} = $row[0]; }
	
	$sth->finish(); 
	
	$dbh->disconnect if defined($dbh);

	return \%subjectPatientHash;

}

1;