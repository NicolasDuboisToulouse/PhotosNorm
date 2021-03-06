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
use PhotosNorm::Logger;
use PhotosNorm::BasicFix;
use PhotosNorm::Main;

my $logger = PhotosNorm::Logger->new();

PhotosNorm::Main::parse_args($logger, PhotosNorm::BasicFix::help(), @ARGV);

PhotosNorm::BasicFix::fix($logger, @PhotosNorm::Main::files);


1;
