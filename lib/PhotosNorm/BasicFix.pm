# Dubois Nicolas (c) 2019
# MIT Licence
#
# Make some basic correction on picture(s) if needed:
# * Access rights (Unix-only)
# * Exif tags Width and Height (They shall match the real image dimensions)
# * Exif tags DateTimeOriginal and CreateDate (Some camera use CreateDate)
# * Rotation of the image according to Exif Orientation (jpeg-only)
#
package PhotosNorm::BasicFix;
use strict;
use warnings;
use PhotosNorm::ImageTag;
use File::Basename;
use MIME::Types;

sub help
{
    return << 'END_HELP';
  Make some basic correction on picture(s) if needed:
  * Access rights (Unix-only)
  * Exif tags Width and Height (They shall match the real image dimensions)
  * Exif tags DateTimeOriginal and CreateDate (Some camera use CreateDate)
  * Rotation of the image according to Exif Orientation (jpeg-only)
END_HELP

}

# $logger: @see PhotosNorm::Logger or PhotosNorm::GuiLogger
# @files: either a list of file or one (and only one) directory
sub fix
{
    my ($logger, @files) = @_;

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

    # Process files
    foreach my $file (@files) {
        _fix_one($logger, $file);
    }
}

#
# Fix one file
# TODO: missing information 'no EXIF data' (do we shall update EXIF dimensions ?)
# TODO: rotation: distinction between unsuported file, rotation error (safe or critical).
# TODO: tag write: warn on potential file corruption
#
sub _fix_one
{
    my ($logger, $file) = @_;

    my $has_change = 0;
    my $result;

    $logger->log(basename($file) . ": ");

    my $tags = PhotosNorm::ImageTag->new($file);
    if (!$tags) {
        $logger->lognl("Unsuported file!");
        return 0;
    }


    $result = $tags->update_access_rights();
    if ($result == 0) {
        $logger->log("Cannot update rights! ");
    } elsif ($result == 1) {
        $logger->log("Access rights updated, ");
        $has_change = 1;
    };


    $result = $tags->auto_rotate($file);
    if ($result == 0) {
        $logger->log("Rotation fail! ");
    } elsif ($result == 1) {
         $logger->log("Rotation done, ");
        $has_change = 1;
    }

    $result = $tags->save();
    if ($result == 0) {
         $logger->log("Save file fail! ");
    } else {
        if ($result & PhotosNorm::ImageTag::TAG_DIMENSIONS) {
            $logger->log("Upate EXIF Dimensions, ");
            $has_change = 1;
        }
        if ($result & PhotosNorm::ImageTag::TAG_DATE) {
            $logger->log("Upate EXIF Date, ");
            $has_change = 1;
        }
    }

    if ($has_change) {
        $logger->lognl("done.");
    } else {
        $logger->lognl("ok.");
    }
}


1;


