#!usr/bin/perl

#script to mine  design notes and sources for each part out of the partsRegistry:Design HTML page 

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

$designnotesdir = $ENV{APP_ROOT} . "/Design_Notes/";

#LOAD IDs
$id_file = $ENV{APP_ROOT} . "/All_Available_Part_IDs.txt";
open (IDS, $id_file);
@id_array = <IDS>;
close IDS;

#Test IDs
#@id_array = (B1202, K416001, K416000);

foreach $id (@id_array){

$input = $id;
$query = "";
$html = "";
$design_notes = "";


#print "ID:    ";
#$input = <STDIN>;

#$input = uc $input;

if ($input =~ /^\n$/ ) {print "Adios. \n\n"; exit;}

chomp $input;

$query = $input;


#Add BBa_ to query if it doesn't have it
if ($query =~ m/BBa_/ )
{} else { 
$query = "BBa_" . $query;
}


#If exists already, skip it
my $infile = $designnotesdir . $query . ".txt";

if (-e "$infile"){goto LAST;}


#If in the Blanks File already, skip it
open (BLANKS, $designnotesdir . "Blank_Design_Notes.txt");
@blanks = <BLANKS>;
close BLANKS;
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

if ($parse == 1){ our $design_notes = $line; }

if ($line =~ m/Design_Notes/){ $parse = 1;
} else {$parse = 0;}


NEXT:
}




$design_notes =~ s/\t//;

#remove HTML formatting if there is any
$design_notes =~ s/<(?:[^>'"]*|(['"]).*?\1)*>//gs;


print "Design Notes:  " . $design_notes . "\n\n\n";

if ($design_notes =~ /^$/) { &print_to_blank_desc; goto LAST;}
if ($design_notes =~ /Source/){&print_to_blank_desc; goto LAST; }
#print "Does this look OK?\n\n\n";

#if (<STDIN> =~ m/^\n/){
&print_desc_file;
#} else { &print_to_messed_up }

#if (<STDIN> =~ m/^\n/){}else{exit;}}


LAST:
}
########## SUBS ##############


sub print_desc_file {

$outfile = $designnotesdir . $query . ".txt";

print "Outfile : " . $outfile . "\n";

open(OUT, ">$outfile");
print OUT $design_notes;
close OUT;

print "\n\nDone saving file \n\n";

}



sub print_to_blank_desc {

$outfile = $designnotesdir . "Blank_Design_Notes.txt";

print "Printing $query to the Blank Design Notes file\n\n";

open (OUT, ">>$outfile");
print OUT $query . "\n";
close OUT;


}
