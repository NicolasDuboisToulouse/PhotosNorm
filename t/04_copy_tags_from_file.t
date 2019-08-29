# Test copy tag from another file
use strict;
use warnings;
use File::Copy;
use Test::More tests => 8;

# Test 1
BEGIN { $| = 1; use_ok('PhotosNorm::ImageTag'); }

my $tmp_file = 't/tmp_copy_tags_from_file.jpg';
unlink($tmp_file);


# Test 2 - Try to copy tags from an non-existing file
{
    my $tags = PhotosNorm::ImageTag->new('t/data/void.jpg');
    ok($tags->copy_tags_from_file('A/non/existing/file.jpg') == 0,
       'Copy from a non existing file');
}

# Test 3/5 - Copy tags without erasing
{
    my $test_name = 'Copy tags without erasing';

    copy('t/data/void.jpg', $tmp_file);
    my $tags = PhotosNorm::ImageTag->new($tmp_file);

    # Add a tag not defined in full.jpg
    $tags->{exif_tools}->SetNewValue('Exif:Artist' => 'A good man');
    $tags->save();

    # Copy tags from full.jpg
    ok($tags->copy_tags_from_file('t/data/full.jpg') == 1,
       $test_name . ' - 1');

    # Check we have full data from full.jpg
    my $camera_info = {
        'exposure_bias' => '+1',
        'flash'         => 'Auto, Fired',
        'exposure'      => '1.1',
        'aperture'      => '2.8',
        'camera'        => 'VoidCompagny VoidModel (V0.0)',
        'iso'           => '100',
        'focal'         => '5.1 mm'
    };

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
       $test_name . ' - 2');


    #Check we still have Artist tag
    ok($tags->{exif_tools}->GetValue('EXIF:Artist') eq 'A good man',
       $test_name . ' - 3');

}


# Test 6/8 - Copy tags without erasing
{
    my $test_name = 'Copy tags with erasing';

    copy('t/data/void.jpg', $tmp_file);
    my $tags = PhotosNorm::ImageTag->new($tmp_file);

    # Add a tag not defined in full.jpg
    $tags->{exif_tools}->SetNewValue('Exif:Artist' => 'A good man');
    $tags->save();

    # Copy tags from full.jpg
    ok($tags->copy_tags_from_file('t/data/full.jpg', 1) == 1,
       $test_name . ' - 1');

    # Check we have full data from full.jpg
    my $camera_info = {
        'exposure_bias' => '+1',
        'flash'         => 'Auto, Fired',
        'exposure'      => '1.1',
        'aperture'      => '2.8',
        'camera'        => 'VoidCompagny VoidModel (V0.0)',
        'iso'           => '100',
        'focal'         => '5.1 mm'
    };

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
       $test_name . ' - 2');


    #Check we do not have Artist tag anymore
    ok(! defined($tags->{exif_tools}->GetValue('EXIF:Artist')),
       $test_name . ' - 3');

}

unlink($tmp_file);



