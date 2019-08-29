# Test saving file
use strict;
use warnings;
use File::Copy;
use Test::More tests => 10;

# Test 1
BEGIN { $| = 1; use_ok('PhotosNorm::ImageTag'); }

my $tmp_file = 't/tmp_save_test.jpg';
unlink($tmp_file);

# Test 2 - save to an non-valid path
{
    my $file = 't/data/void.jpg';
    my $test_name = 'write to invalid path';
    my $tags = PhotosNorm::ImageTag->new($file);
    ok(PhotosNorm::ImageTag::TAG_FAILURE == $tags->save("/path/that/shall/not/exists.jpg"), $test_name);
}

# Test 3 - saving a file without EXIF shall update with/height
{
    my $file = 't/data/void.jpg';
    copy($file, $tmp_file);
    my $test_name = 'Save file without exifs';
    my $save_result_expected =
        PhotosNorm::ImageTag::TAG_NONE |
        PhotosNorm::ImageTag::TAG_DIMENSIONS;
    my $tags = PhotosNorm::ImageTag->new($tmp_file);
    my $save_result = $tags->save();
    if ($save_result != $save_result_expected) {
        diag('Save result expected: "' .  $save_result_expected . "\" but was '$save_result'");
        fail($test_name);
    } else {
        my $tags = PhotosNorm::ImageTag->new($tmp_file);
        ok(($tags->{exif_tools}->GetValue('EXIF:ExifImageWidth') == 10) &&
           ($tags->{exif_tools}->GetValue('EXIF:ExifImageHeight') == 20),
           $test_name);
    }
    unlink($tmp_file);
}

# Test 4 - saving a file with EXIF shall have no changes
{
    my $file = 't/data/full.jpg';
    copy($file, $tmp_file);
    my $test_name = 'Save file with exifs';
    my $save_result_expected =
        PhotosNorm::ImageTag::TAG_NONE;
    my $tags = PhotosNorm::ImageTag->new($tmp_file);
    my $save_result = $tags->save();
    if ($save_result != $save_result_expected) {
        diag('Save result expected: "' .  $save_result_expected . "\" but was '$save_result'");
        fail($test_name);
    } else {
        pass($test_name);
    }
    unlink($tmp_file);
}

# Test 5 - Clone test (save to another file without EXIF change)
{
    my $file = 't/data/full.jpg';
    my $test_name = 'Copy file with exifs';
    my $save_result_expected =
        PhotosNorm::ImageTag::TAG_NONE;
    my $tags = PhotosNorm::ImageTag->new($file);
    my $save_result = $tags->save($tmp_file);
    if ($save_result != $save_result_expected) {
        diag('Save result expected: "' .  $save_result_expected . "\" but was '$save_result'");
        fail($test_name);
    } else {

        my $camera_info = {
            'exposure_bias' => '+1',
            'flash'         => 'Auto, Fired',
            'exposure'      => '1.1',
            'aperture'      => '2.8',
            'camera'        => 'VoidCompagny VoidModel (V0.0)',
            'iso'           => '100',
            'focal'         => '5.1 mm'
        };


        my $tags = PhotosNorm::ImageTag->new($tmp_file);

        # diag 'EXIF:ExifImageWidth =       "' . $tags->{exif_tools}->GetValue('EXIF:ExifImageWidth') . '"';
        # diag 'EXIF:ExifImageHeight =      "' . $tags->{exif_tools}->GetValue('EXIF:ExifImageHeight') . '"';
        # diag 'EXIF:DateTimeOriginal =     "' . $tags->{exif_tools}->GetValue('EXIF:DateTimeOriginal') . '"';
        # diag 'EXIF:CreateDate =           "' . $tags->{exif_tools}->GetValue('EXIF:CreateDate') . '"';
        # diag 'EXIF:ImageDescription =     "' . $tags->{exif_tools}->GetValue('EXIF:ImageDescription') . '"';
        # diag 'EXIF:UserComment =          "' . $tags->{exif_tools}->GetValue('EXIF:UserComment') . '"';
        # diag 'XMP:CropLeft =              "' . $tags->{exif_tools}->GetValue('XMP:CropLeft') . '"';
        # diag 'XMP:CropTop =               "' . $tags->{exif_tools}->GetValue('XMP:CropTop') . '"';
        # diag 'XMP:CropWidth =             "' . $tags->{exif_tools}->GetValue('XMP:CropWidth') . '"';
        # diag 'XMP:CropHeight =            "' . $tags->{exif_tools}->GetValue('XMP:CropHeight') . '"';
        # diag 'EXIF:Make =                 "' . $tags->{exif_tools}->GetValue('EXIF:Make') . '"';
        # diag 'EXIF:Model =                "' . $tags->{exif_tools}->GetValue('EXIF:Model') . '"';
        # diag 'EXIF:Software =             "' . $tags->{exif_tools}->GetValue('EXIF:Software') . '"';
        # diag 'EXIF:ExposureTime =         "' . $tags->{exif_tools}->GetValue('EXIF:ExposureTime', Raw => 1) . '"';
        # diag 'EXIF:FNumber =              "' . $tags->{exif_tools}->GetValue('EXIF:FNumber', Raw => 1) . '"';
        # diag 'EXIF:ExposureCompensation = "' . $tags->{exif_tools}->GetValue('EXIF:ExposureCompensation', Raw => 1) . '"';
        # diag 'EXIF:ISO =                  "' . $tags->{exif_tools}->GetValue('EXIF:ISO', Raw => 1) . '"';
        # diag 'EXIF:FocalLength =          "' . $tags->{exif_tools}->GetValue('EXIF:FocalLength', Raw => 1) . '"';
        # diag 'EXIF:Flash =                "' . $tags->{exif_tools}->GetValue('EXIF:Flash', Raw => 1) . '"';

        ok($tags->{exif_tools}->GetValue('EXIF:ExifImageWidth')                 eq 10 &&
           $tags->{exif_tools}->GetValue('EXIF:ExifImageHeight')                eq 20 &&
           $tags->{exif_tools}->GetValue('EXIF:DateTimeOriginal')               eq '2019:01:01 00:00:00' &&
           $tags->{exif_tools}->GetValue('EXIF:CreateDate')                     eq '2019:01:01 00:00:00' &&
           $tags->{exif_tools}->GetValue('EXIF:ImageDescription')               eq 'A description' &&
           $tags->{exif_tools}->GetValue('EXIF:UserComment')                    eq 'A comment' &&
           $tags->{exif_tools}->GetValue('XMP:CropLeft')                        eq 142 &&
           $tags->{exif_tools}->GetValue('XMP:CropTop')                         eq 242 &&
           $tags->{exif_tools}->GetValue('XMP:CropWidth')                       eq 342 &&
           $tags->{exif_tools}->GetValue('XMP:CropHeight')                      eq 442 &&
           $tags->{exif_tools}->GetValue('EXIF:Make')                           eq 'VoidCompagny' &&
           $tags->{exif_tools}->GetValue('EXIF:Model')                          eq 'VoidModel' &&
           $tags->{exif_tools}->GetValue('EXIF:Software')                       eq 'V0.0' &&
           $tags->{exif_tools}->GetValue('EXIF:ExposureTime', Raw => 1)         eq 1.1 &&
           $tags->{exif_tools}->GetValue('EXIF:FNumber', Raw => 1)              eq 2.8 &&
           $tags->{exif_tools}->GetValue('EXIF:ExposureCompensation', Raw => 1) eq 1 &&
           $tags->{exif_tools}->GetValue('EXIF:ISO', Raw => 1)                  eq 100 &&
           $tags->{exif_tools}->GetValue('EXIF:FocalLength', Raw => 1)          eq 5.1 &&
           $tags->{exif_tools}->GetValue('EXIF:Flash', Raw => 1)                eq 25 &&
           $tags->title()                                                       eq 'A description' &&
           $tags->comment()                                                     eq 'A comment' &&
           $tags->date()                                                        eq '2019:01:01 00:00:00' &&
           $tags->timestamp()                                                   eq 1546297200 &&
           $tags->width()                                                       eq 10 &&
           $tags->height()                                                      eq 20 &&
           $tags->crop_left()                                                   eq 142 &&
           $tags->crop_top()                                                    eq 242 &&
           $tags->crop_width()                                                  eq 342 &&
           $tags->crop_height()                                                 eq 442 &&
           eq_hash($tags->camera(), $camera_info),
           $test_name);
    }
    unlink($tmp_file);
}


# Test 6 - saving a file with invalid date field shall correct it
{
    my $file = 't/data/invalid_date_field.jpg';
    copy($file, $tmp_file);
    my $test_name = 'Save file with invalid date field';
    my $save_result_expected =
        PhotosNorm::ImageTag::TAG_NONE |
        PhotosNorm::ImageTag::TAG_DATE;
    my $tags = PhotosNorm::ImageTag->new($tmp_file);
    my $save_result = $tags->save();
    if ($save_result != $save_result_expected) {
        diag('Save result expected: "' .  $save_result_expected . "\" but was '$save_result'");
        fail($test_name);
    } else {

        my $tags = PhotosNorm::ImageTag->new($tmp_file);

        ok($tags->{exif_tools}->GetValue('EXIF:DateTimeOriginal')               eq '2019:01:01 00:00:00' &&
           $tags->{exif_tools}->GetValue('EXIF:CreateDate')                     eq '2019:01:01 00:00:00' &&
           $tags->date()                                                        eq '2019:01:01 00:00:00',
           $test_name);
    }
    unlink($tmp_file);
}

# Test 7 - Update date
{
    my $file = 't/data/full.jpg';
    copy($file, $tmp_file);
    my $test_name = 'Update date';
    my $save_result_expected =
        PhotosNorm::ImageTag::TAG_NONE |
        PhotosNorm::ImageTag::TAG_DATE;
    my $tags = PhotosNorm::ImageTag->new($tmp_file);

    $tags->date('2019:01:01 10:10:10');

    my $save_result = $tags->save();
    if ($save_result != $save_result_expected) {
        diag('Save result expected: "' .  $save_result_expected . "\" but was '$save_result'");
        fail($test_name);
    } else {

        my $tags = PhotosNorm::ImageTag->new($tmp_file);


        ok($tags->{exif_tools}->GetValue('EXIF:DateTimeOriginal')               eq '2019:01:01 10:10:10' &&
           $tags->{exif_tools}->GetValue('EXIF:CreateDate')                     eq '2019:01:01 10:10:10' &&
           $tags->date()                                                        eq '2019:01:01 10:10:10',
           $test_name);
    }
    unlink($tmp_file);
}


# Test 8 - Update title
{
    my $file = 't/data/full.jpg';
    copy($file, $tmp_file);
    my $test_name = 'Update title';
    my $save_result_expected =
        PhotosNorm::ImageTag::TAG_NONE |
        PhotosNorm::ImageTag::TAG_TITLE;
    my $tags = PhotosNorm::ImageTag->new($tmp_file);

    $tags->title('A new title');

    my $save_result = $tags->save();
    if ($save_result != $save_result_expected) {
        diag('Save result expected: "' .  $save_result_expected . "\" but was '$save_result'");
        fail($test_name);
    } else {

        my $tags = PhotosNorm::ImageTag->new($tmp_file);

        ok($tags->{exif_tools}->GetValue('EXIF:ImageDescription')               eq 'A new title' &&
           $tags->title()                                                       eq 'A new title',
           $test_name);
    }
    unlink($tmp_file);
}

# Test 9 - Update comment
{
    my $file = 't/data/full.jpg';
    copy($file, $tmp_file);
    my $test_name = 'Update comment';
    my $save_result_expected =
        PhotosNorm::ImageTag::TAG_NONE |
        PhotosNorm::ImageTag::TAG_COMMENT;
    my $tags = PhotosNorm::ImageTag->new($tmp_file);

    $tags->comment('A new comment');

    my $save_result = $tags->save();
    if ($save_result != $save_result_expected) {
        diag('Save result expected: "' .  $save_result_expected . "\" but was '$save_result'");
        fail($test_name);
    } else {

        my $tags = PhotosNorm::ImageTag->new($tmp_file);

        ok($tags->{exif_tools}->GetValue('EXIF:UserComment')               eq 'A new comment' &&
           $tags->comment()                                                eq 'A new comment',
           $test_name);
    }
    unlink($tmp_file);
}


# Test 10 - Update crop
{
    my $file = 't/data/full.jpg';
    copy($file, $tmp_file);
    my $test_name = 'Update crop';
    my $save_result_expected =
        PhotosNorm::ImageTag::TAG_NONE |
        PhotosNorm::ImageTag::TAG_CROP;
    my $tags = PhotosNorm::ImageTag->new($tmp_file);

    $tags->crop_top(1042);
    $tags->crop_width(2042);

    my $save_result = $tags->save();
    if ($save_result != $save_result_expected) {
        diag('Save result expected: "' .  $save_result_expected . "\" but was '$save_result'");
        fail($test_name);
    } else {

        my $tags = PhotosNorm::ImageTag->new($tmp_file);

        ok($tags->{exif_tools}->GetValue('XMP:CropTop')                         eq 1042 &&
           $tags->{exif_tools}->GetValue('XMP:CropWidth')                       eq 2042 &&
           $tags->crop_top()                                                    eq 1042 &&
           $tags->crop_width()                                                  eq 2042,
           $test_name);
    }
    unlink($tmp_file);
}

1;
