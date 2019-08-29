# Test exif rotation
# WARN: this test only EXIF update, it does't check the picture itself.
use strict;
use warnings;
use File::Copy;
use Test::More tests => 8;

# Test 1
BEGIN { $| = 1; use_ok('PhotosNorm::ImageTag'); }

my $tmp_file = 't/tmp_rotate_test.jpg';
unlink($tmp_file);



# Test 2 - rotate a non-jpeg file
{
    my $file = 't/data/full.png';
    my $test_name = 'Try to rotate a non-jpg file';
    my $tags = PhotosNorm::ImageTag->new($file);
    ok(0 == $tags->auto_rotate(), $test_name);
}

# Test 3 - rotate file without EXIF info
{
    my $file = 't/data/void.jpg';
    my $test_name = 'rotate without EXIF';
    my $tags = PhotosNorm::ImageTag->new($file);
    ok(2 == $tags->auto_rotate(), $test_name);
}

# Test 4 - rotate file with invalid orientation
{
    my $file = 't/data/rotate_invalid_orient.jpg';
    my $test_name = 'Invalid orientation';
    my $tags = PhotosNorm::ImageTag->new($file);
    ok(0 == $tags->auto_rotate(), $test_name);
}


# Test 5 - rotate file without orientation change
{
    my $file = 't/data/full.jpg';
    my $test_name = 'orientation up todate';
    my $tags = PhotosNorm::ImageTag->new($file);
    ok(2 == $tags->auto_rotate(), $test_name);
}

# Test 6/8 - real rotation
{
    my $file = 't/data/rotate.jpg';
    copy($file, $tmp_file);
    my $test_name = 'Do rotation';
    my $tags = PhotosNorm::ImageTag->new($tmp_file);
    ok(1 == $tags->auto_rotate(), $test_name . ' 1');


    # Check all tags are Ok    
    ok($tags->{exif_tools}->GetValue('EXIF:ExifImageWidth')                 eq 20 &&
       $tags->{exif_tools}->GetValue('EXIF:ExifImageHeight')                eq 10 &&
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
       $tags->{exif_tools}->GetValue('EXIF:Orientation', Raw => 1)          eq 1,
       $test_name . ' 2');

    # Reload tags and check them again
    $tags = PhotosNorm::ImageTag->new($tmp_file);
    ok($tags->{exif_tools}->GetValue('EXIF:ExifImageWidth')                 eq 20 &&
       $tags->{exif_tools}->GetValue('EXIF:ExifImageHeight')                eq 10 &&
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
       $tags->{exif_tools}->GetValue('EXIF:Orientation', Raw => 1)          eq 1,
       $test_name . ' 3');

    unlink($tmp_file);
}
