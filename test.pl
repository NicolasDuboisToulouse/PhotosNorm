#!/usr/bin/env perl
BEGIN {
    my $soft_home = ($0 =~ /(.*)[\\\/]/) ? $1 : '.';
    unshift @INC, "$soft_home/lib";
}


use strict;
use warnings;
use PhotosNorm::GuiLogger;

$|=1;

print "BEGIN\n";

my $logger = PhotosNorm::GuiLogger->new("The logger");

print "MAIN\n";
$logger->run();

print "END\n";
