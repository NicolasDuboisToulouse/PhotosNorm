#!/usr/bin/env perl
use strict;
use warnings;
use Image::ExifTool;

my $exifTool = new Image::ExifTool;
$exifTool->Options(Unknown => 1, Duplicates => 1, Sort => 'Group0', Sort2 => 'Tag');

$exifTool->ExtractInfo($ARGV[0]) || exit;
my $info = $exifTool->GetInfo();

my $group = '';
my $tag;
foreach $tag ($exifTool->GetFoundTags('Group0')) {
    if ($group ne $exifTool->GetGroup($tag)) {
        $group = $exifTool->GetGroup($tag);
        print "---- $group ----\n";
    }
    my $val = $info->{$tag};
    if (ref $val eq 'SCALAR') {
        if ($$val =~ /^Binary data/) {
            $val = "($$val)";
        } else {
            my $len = length($$val);
            $val = "(Binary data $len bytes)";
        }
    }
    printf("%-40s : %s\n", "$group:" . $exifTool->GetDescription($tag), $val);
}

0;
