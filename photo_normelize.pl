#!/usr/bin/env perl
#
# Update some stuff on an image:
# - access rights (Unix-only)
# - Exif tags Width and Height (They shall match the real image dimensions)
# - Exif tags DateTimeOriginal and CreateDate (Some camera use CreateDate)
# - Rotation of the image according to Exif Orientation (jpeg-only)
#
BEGIN {
    my $soft_home = ($0 =~ /(.*)[\\\/]/) ? $1 : '.';
    unshift @INC, "$soft_home/lib";
}

use strict;
use warnings;
use PhotosNorm::ImageTag;
use File::Basename;
use MIME::Types;
use File::Spec;


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


# Load directory if needed (update @file)
if (@files == 1 && -d $files[0]) {
    my $dir = pop(@files);
    opendir(DIR, $dir) or die $!;
    my $mt = MIME::Types->new;
    while (my $file = readdir(DIR)) {
        $file = File::Spec->catfile($dir, $file);
        push(@files, $file) if (-f $file && $mt->mimeTypeOf($file) =~ /^image/);
    }
    closedir(DIR);
}


#
# Normelize  one file
# TODO: make a re-usable module (and new result display system)
# TODO: missing information 'no EXIF data' (do we shall update EXIF dimensions ?)
# TODO: rotation: distinction between unsuported file, rotation error (safe or critical).
# TODO: tag write: warn on potential file corruption 
#
sub normalize
{
    my ($file) = @_;

    my $has_change = 0;
    my $result;

    print basename($file) . ": ";

    my $tags = PhotosNorm::ImageTag->new($file);
    if (!$tags) {
        print "Unsuported file!\n";
        return 0;
    }

    
    $result = $tags->update_access_rights();
    if ($result == 0) {
        print "Cannot update rights! ";
    } elsif ($result == 1) {
        print "Access rights updated, "; 
        $has_change = 1;      
    };
    

    $result = $tags->auto_rotate($file);
    if ($result == 0) {
        print "Rotation fail! ";
    } elsif ($result == 1) {
        print "Rotation done, ";
        $has_change = 1;
    }

    $result = $tags->save();
    if ($result == 0) {
        print "Save file fail! ";
    } else {
        if ($result & PhotosNorm::ImageTag::TAG_DIMENSIONS) {
            print "Upate EXIF Dimensions, ";
            $has_change = 1;
        }
        if ($result & PhotosNorm::ImageTag::TAG_DATE) {
            print "Upate EXIF Date, ";
            $has_change = 1;
        }
    }

    if ($has_change) {
        print "done.\n";
    } else {
        print "ok. \n";
    }
}

#
# Normalize input files
#
foreach my $file (@files) {
    normalize($file);
}

1;
