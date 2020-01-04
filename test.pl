#!/usr/bin/env perl
BEGIN {
    my $soft_home = ($0 =~ /(.*)[\\\/]/) ? $1 : '.';
    unshift @INC, "$soft_home/lib";
}


use strict;
use warnings;
use PhotosNorm::GuiLogger;
#use PhotosNorm::Logger;

$|=1;

sub test_log
{
    my ($logger, $text1, $text2, $text3) = @_;

    sleep(1);
    $logger->log($text1);
    sleep(1);
    $logger->lognl($text2);
    sleep(1);
    $logger->log($text3);
}




my $logger = PhotosNorm::GuiLogger->new("The logger");
$logger->run(\&test_log, "Hello", "All", "World");

# my $logger = PhotosNorm::Logger->new();
# test_log($logger, "Hello", "All", "World");