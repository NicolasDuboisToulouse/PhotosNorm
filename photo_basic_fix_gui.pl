#!/usr/bin/env perl
#
# @see PhotosNorm::BasicFix
#
BEGIN {
    my $soft_home = ($0 =~ /(.*)[\\\/]/) ? $1 : '.';
    unshift @INC, "$soft_home/lib";
}

use strict;
use warnings;
use PhotosNorm::GuiLogger;
use PhotosNorm::BasicFix;
use PhotosNorm::Main;

my $title = "Photo Basic Fix";

my $logger = PhotosNorm::GuiLogger->new($title);

PhotosNorm::Main::parse_args($logger, PhotosNorm::BasicFix::help(), @ARGV);

$logger->run(\&PhotosNorm::BasicFix::fix, @PhotosNorm::Main::files);


1;
