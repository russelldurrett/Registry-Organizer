#!usr/bin/perl

#script to mine sources for each part out of the partsRegistry:Design HTML page 

#!usr/bin/perl
#


use warnings;
#use strict;

use FindBin;
use File::Spec;
use Cwd;

#use XML::Simple;
#use Data::Dumper;


$ENV{APP_ROOT} = Cwd::realpath(File::Spec->rel2abs($FindBin::Bin)) ;
use lib  ( "$ENV{APP_ROOT}/lib" );

$sourcesdir = $ENV{APP_ROOT} . "/Sources/";


#Load Blank IDs from File
open (BLANKS, $sourcesdir . "Blank_Sources.txt");
@blanks = <BLANKS>;
close BLANKS;


$id_file = $ENV{APP_ROOT} . "/All_Available_Part_IDs.txt";
open (IDS, $id_file);
@id_array = <IDS>;
close IDS;

#Test Array
#@id_array = (B1202, K416001, K416000);

foreach $id (@id_array){

$input = $id;
$query = "";
$html = "";
$sources = "";

if ($input =~ /^\n$/ ) {print "Adios. \n\n"; exit;}

chomp $input;

$query = $input;


#Add BBa_ to query if it doesn't have it
if ($query =~ m/BBa_/ )
{} else { 
$query = "BBa_" . $query;
}


#If exists already, skip it
my $infile = $sourcesdir . $query . ".txt";

if (-e "$infile"){goto LAST;}


#If in the Blanks File already, skip it
if (grep {$_ =~ /$query/} @blanks) {goto LAST;}



#Sub to download data

use LWP::Simple;

my $page = "http://www.partsregistry.org/Part:" . $query . ":Design";

print "\n\n" . "Getting :   ". $page . "\n\n"; 

$html = get("$page");


#parsing HTML

$parse = 0;

my @html_lines = split ('\n', $html);

foreach $line (@html_lines) {

#if previous line had /sources/
if ($parse == 1){ our $sources = $line; }

#if line /sources/, parse = true
if ($line =~ m/Sources/){ $parse = 1;
} else {$parse = 0;}


NEXT:
}




$sources =~ s/\t//;

#remove HTML formatting if there is any
$sources =~ s/<(?:[^>'"]*|(['"]).*?\1)*>//gs;


print "Sources:  " . $sources . "\n\n\n";

if ($sources =~ /^$/) { &print_to_blank_desc; goto LAST;}
#if ($sources =~ /Source/){&print_to_blank_desc; goto LAST; }
#print "Does this look OK?\n\n\n";

#if (<STDIN> =~ m/^\n/){
&print_desc_file;
#} else { &print_to_messed_up }

#if (<STDIN> =~ m/^\n/){}else{exit;}}


LAST:
}
########## SUBS ##############


sub print_desc_file {

$outfile = $sourcesdir . $query . ".txt";

print "Outfile : " . $outfile . "\n";

open(OUT, ">$outfile");
print OUT $sources;
close OUT;

print "\n\nDone saving file \n\n";

}


sub print_to_blank_desc {

$outfile = $sourcesdir . "Blank_Sources.txt";

print "Printing $query to the Blank Sources file\n\n";

open (OUT, ">>$outfile");
print OUT $query . "\n";
close OUT;


}
