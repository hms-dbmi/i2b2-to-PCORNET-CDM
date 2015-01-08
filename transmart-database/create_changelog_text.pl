#!/usr/bin/perl

my ($srcDirectory) = @ARGV;

opendir(D, $srcDirectory) || die "Can't opendir: $!\n";

print("     <changeSet author=\"mmcduffie (generated)\" id=\"1\" objectQuotingStrategy=\"QUOTE_ALL_OBJECTS\" runOnChange=\”true\”>\n");

while (my $f = readdir(D)) 
{
	if($f =~ m/.sql$/)
	{	
		print("       <sqlFile path='$srcDirectory$f'/>\n");
	}
}
print("     </changeSet>\n");
