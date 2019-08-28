# Test updating rights
# Note: TODO: plan test depending on OS
use strict;
use warnings;
use File::Copy;
use Test::More;

# Test 1
BEGIN { $| = 1; use_ok('PhotosNorm::ImageTag'); }

my $tmp_file = 't/tmp_update_right_test.jpg';
my $fileperm = 0;
my $tags = undef;

unlink($tmp_file);
copy('t/data/full.jpg', $tmp_file);

# Windows OS
if ($^O eq 'MSWin32') {
    $tags = PhotosNorm::ImageTag->new($tmp_file);
    ok($tags->update_access_rights() == 2, "Update rights return expected value for Windows OS.");
    unlink($tmp_file);
    done_testing();
    exit 0;
}

fail("****** TEST HAS TO BE VALIDATES ON LINUX ************");

# Check update rights to 0777
chmod(0777, $tmp_file);
$fileperm = (stat($tmp_file))[2] & 07777;
ok($fileperm == 0777, "set file permission on temp file to 777 (stat)");

$tags = PhotosNorm::ImageTag->new($tmp_file);
$fileperm = $tags->{exif_tools}->GetValue('File:FilePermissions', 'Raw') & 07777;
ok($fileperm == 0777, "set file permission on temp file to 777 (exiftool)");

# Check auto_update rights from 0777 to 0644
ok($tags->update_access_rights() == 1, "Update rights return expected value.");

# Check rights are realy 0644
$fileperm = $tags->{exif_tools}->GetValue('File:FilePermissions', 'Raw') & 07777;
ok($fileperm == 0644, "file permission is the expected ones (existing exiftool)");

$fileperm = (stat($tmp_file))[2] & 07777;
ok($fileperm == 0644, "file permission is the expected ones (stat)");

$tags = PhotosNorm::ImageTag->new($tmp_file);
$fileperm = $tags->{exif_tools}->GetValue('File:FilePermissions', 'Raw') & 07777;
ok($fileperm == 0644, "file permission is the expected ones (new exiftool)");

# Check auto_update rights without change 0644 to 0644
ok($tags->update_access_rights() == 2, "Update rights return expected value.");

# Check rights are realy 0644
$fileperm = $tags->{exif_tools}->GetValue('File:FilePermissions', 'Raw') & 07777;
ok($fileperm == 0644, "file permission is the expected ones (existing exiftool)");

$fileperm = (stat($tmp_file))[2] & 07777;
ok($fileperm == 0644, "file permission is the expected ones (stat)");

$tags = PhotosNorm::ImageTag->new($tmp_file);
$fileperm = $tags->{exif_tools}->GetValue('File:FilePermissions', 'Raw') & 07777;
ok($fileperm == 0644, "file permission is the expected ones (new exiftool)");


unlink($tmp_file);

done_testing();
