#!usr/bin/perl
#
# script that processes a Biobrick XML file and prints every Biobrick ID
#
#usage:
#perl getXMLparts.pl
#

#use warnings;
#use strict;

use XML::Simple;
use Data::Dumper;

START:

print "\nEnter Part ID(s) : ";

$input = <STDIN>;
$input = uc $input;

if ($input =~ /^\n$/ ) {print "Adios. \n\n"; exit;}

@queries = split(/\s/, $input);


print "\n IDs = @queries \n\n";

foreach my $query (@queries) {

#Add BBa_ to query if it doesn't have it
if ($query =~ m/BBa_/ )
{} else { 
$query = "BBa_" . $query;
}

#Load part xml file into temp xml hash

my $infile = "/Users/Rover/Perl/Registry/PARTS/" . $query . ".xml";
unless (-e $infile) { print "Can't find part file, want to look it up on the Registry? [Y/N]\n";
 if (<STDIN> =~ /Y|y/) { &download_XML($query) }
}

my $partfile = XMLin($infile) ;

# print "\n\n Querying $query  at  $infile \n\n";


#for each part in file (should only be one), list important data
foreach my $part ($partfile->{part_list}->{part}) {

#Edit Part Details 
my $short_name = $part->{part_short_name};
my $desc = $part->{part_short_desc};
my $status = $part->{part_status};
my $results = $part->{part_results};

if ($results =~ /None/){ $results = " -  But No Results Yet"} 
elsif ($results =~ /HASH/){ $results = " -  No results"}
else {$results = " &  " . $results}

my $sequence = $part->{sequences}->{seq_data};
$sequence =~ s/\n//;
$seq_length = length($sequence);

#Print Part Info
print $short_name . " : " . $seq_length . "bp" . " : " . $desc . "\n";
print $status . " " . $results . "\n";
print $sequence . "\n\n";



}
#Dump hashed xml file if you want to look at it :
#print Dumper($partfile);


}

goto START;

# Subroutine to download XML file from Registry and save it to PARTS

sub download_XML {

use LWP::Simple;

my $ID = @_[0];

chomp $ID;
my $page = "http://www.partsregistry.org/cgi/xml/part.cgi?part=" . $ID;

print "\n\n" . "Getting :   ". $page . "\n\n"; 
my $data = get("$page");
#print $data . "\n\n\n";

#Check to make sure file exists. If not, go back to ID entry
$xmldata = XMLin($data);
if (($xmldata->{part_list}->{ERROR}) =~ m/Part/){ print "Biobrick Not Found, it must not exist!\n"; goto START;}

print "Biobrick Found, downloading information and saving it to your computer.\n\n";

my $outfile = "/Users/Rover/Perl/Registry/PARTS/" . $ID . ".xml";


print "Outfile : " . $outfile . ".xml \n\n\n";

open(OUT, ">$outfile");
print OUT $data;
close OUT;


print "\n\nDone downloading file \n\n";

}





