# Test loading file
use strict;
use warnings;
use Test::More tests => 6;

# Test 1
BEGIN { $| = 1; use_ok('PhotosNorm::ImageTag'); }

# Test 2-4
ok(! defined(PhotosNorm::ImageTag->new('do_not_exist.jpg')), "file doesn't exist");
ok(! defined(PhotosNorm::ImageTag->new('t/data/binary.jpg')), "unsuported exittool file");
ok(! defined(PhotosNorm::ImageTag->new('t/data/data.json')), "suported but not an image");

# Test 5
{
    my $file = 't/data/void.jpg';
    my $test_name = 'valid image without tags';
    my $void_tags = PhotosNorm::ImageTag->new($file);
    if (defined($void_tags)) {

      my $camera_info = {
          'exposure_bias' => 'Unknown',
          'exposure'      => 'Unknown',
          'flash'         => 'Unknown',
          'iso'           => 'Unknown',
          'camera'        => 'Unknown',
          'aperture'      => 'Unknown',
          'focal'         => 'Unknown'
        };

        ok(
            !defined($void_tags->title()) &&
            !defined($void_tags->comment()) &&
            !defined($void_tags->date()) &&
            $void_tags->width() == 10 &&
            $void_tags->height() == 20 &&
            eq_hash($void_tags->camera(), $camera_info) &&
            !defined($void_tags->crop_left()) &&
            !defined($void_tags->crop_top()) &&
            !defined($void_tags->crop_width()) &&
            !defined($void_tags->crop_height()),
            $test_name);

    } else {
        diag("Cannot load file '$file'");
        fail($test_name);
    }
}

# Test 6
{
    my $file = 't/data/full.jpg';
    my $test_name = 'valid image with tags';
    my $full_tags = PhotosNorm::ImageTag->new($file);
    if (defined($full_tags)) {

      my $camera_info = {
          'exposure_bias' => '+1',
          'flash'         => 'Auto, Fired',
          'exposure'      => '1.1',
          'aperture'      => '2.8',
          'camera'        => 'VoidCompagny VoidModel (V0.0)',
          'iso'           => '100',
          'focal'         => '5.1 mm'
        };

        ok(
            $full_tags->title() eq 'A description' &&
            $full_tags->comment() eq 'A comment' &&
            $full_tags->date() eq '2019:01:01 00:00:00' &&
            $full_tags->width() == 10 &&
            $full_tags->height() == 20 &&
            eq_hash($full_tags->camera(), $camera_info) &&
            $full_tags->crop_left() == 142 &&
            $full_tags->crop_top() == 242 &&
            $full_tags->crop_width() == 342 &&
            $full_tags->crop_height() == 442,
            $test_name);

    } else {
        diag("Cannot load file '$file'");
        fail($test_name);
    }
}


1;
