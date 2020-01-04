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
use File::Basename;

#
# Some help
#
sub usage
{
    my $soft = basename($0);
    print << "END_USAGE";
USAGE: $soft -h | --help
       $soft <image> [ <image> ... ]
       $soft <folder>

  Make some basic correction on picture(s) if needed:
  * Access rights (Unix-only)
  * Exif tags Width and Height (They shall match the real image dimensions)
  * Exif tags DateTimeOriginal and CreateDate (Some camera use CreateDate)
  * Rotation of the image according to Exif Orientation (jpeg-only)

  -h
  --help
     Display this help screen. If you provide images, they will be ignored.

  <image> [ <image> ... ]
     Apply the correction on all provided images.

  <folder>
     Will look for images (by extension) in proved folder and apply the needed corrections.
     Only one folder is supported. The lookup is not recursive.

END_USAGE
    return 0;
}


#
# Parse args
#
my @files;
while (my $arg = shift @ARGV) {
    exit usage() if ($arg eq '-h' || $arg eq '--help');

    if ($arg =~ /^-/) {
        printf "Unkown option '$arg'!";
        exit 1;
    }

    push(@files, $arg);
}

exit usage() if (@files == 0);

my $logger = PhotosNorm::Logger->new();
PhotosNorm::BasicFix::fix($logger, @files);


1;
