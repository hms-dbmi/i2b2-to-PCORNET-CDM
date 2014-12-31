#!/usr/bin/perl

use strict;
use warnings;
use autodie;
use Text::CSV;
use Cwd;

# if no dirname in arguments then use current dir.
my ($dirname) = @ARGV;
$dirname = getcwd if not defined $dirname;

opendir DIR, $dirname or die "Impossible to open $dirname: $!";
while (my $f = readdir DIR) {
        next if $f !~ /\.csv$/;
        my $outputFile = $f;
        $outputFile =~ s/csv/txt/;

        print "Processing csv file: $f...";

        my $csv = Text::CSV->new ({ binary => 1 });
        my $tsv = Text::CSV->new ({ binary => 1, sep_char => "\t", eol => "\n" });

        open my $infh,  "<:encoding(utf8)", $f;
        open my $outfh, ">:encoding(utf8)", $outputFile;

        while (my $row = $csv->getline ($infh)) {
                $tsv->print ($outfh, $row);
         }
        print "Done.\n"

}
closedir DIR;