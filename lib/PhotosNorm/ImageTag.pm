# Dubois Nicolas (c) 2019
# MIT Licence
#
# Simple wrapper to exiftool to manage
# a subset of predefined tags.
#
package PhotosNorm::ImageTag;
use strict;
use warnings;
use Image::ExifTool;
use Image::JpegTran;
use File::Copy qw(copy);
use POSIX qw(mktime);


#
# Tags properties.
#
use constant {
    TAG_NONE       => 0,
    TAG_DIMENSIONS => 1,
    TAG_DATE       => 2,
    TAG_TITLE      => 4,
    TAG_COMMENT    => 8,
    TAG_CROP       => 16,
};


#
# Create a new PhotosNorm::ImageTag from $file.
# If $file doesn't exist or is not an image (mimetype), the create will fail (return undef)
#
sub new
{
    my ($pkg, $file) = @_;

    my $self = bless( { file => $file }, $pkg );

    return undef if (!$self->_read_exif_tags());

    return $self;
}

#
# Accessors. Some are r/w other ro.
# Most of accessors may return undef.
# No checks is done on setters.
#

# rw
sub title
{
    $_[0]->{title} = $_[1] if (@_ == 2);
    return $_[0]->{title};
}

# rw
sub comment
{
    $_[0]->{comment} = $_[1] if (@_ == 2);
    return $_[0]->{comment};
}

# rw
sub date
{
    $_[0]->{date} = $_[1] if (@_ == 2);
    return $_[0]->{date};
}

# rw
# get/set date field with an unix timestamp
sub timestamp
{
    my ($self, $timestamp) = @_;
    if (defined($timestamp)) {
        my ($sec, $min, $hour, $mday, $mon, $year) = localtime($timestamp);
        $self->date(sprintf("%d:%02d:%02d %02d:%02d:%02d",
                            $year + 1900, $mon + 1, $mday, $hour, $min, $sec));
    }
    my ($year, $mon, $day, $hour, $min, $sec) = split(/[:\/ ]/, $self->date());
    return mktime($sec, $min, $hour, $day, $mon - 1, $year - 1900, 0, 0);
}

# ro
# never undef.
sub width
{
    return $_[0]->{width};
}

# ro
# never undef.
sub height
{
    return $_[0]->{height};
}

# ro
# return hash { camera, iso, flash, exposure, focal, exposure_bias, aperture }
# Nothing can be undef ('unkwown' by default)
sub camera
{
    return $_[0]->{camera_infos};
}


# rw
# return crop informations to create thumbnail.
sub crop_left
{
    $_[0]->{crop}->{left} = $_[1] if (@_ == 2);
    return $_[0]->{crop}->{left};
}
sub crop_top
{
    $_[0]->{crop}->{top} = $_[1] if (@_ == 2);
    return $_[0]->{crop}->{top};
}
sub crop_width
{
    $_[0]->{crop}->{width} = $_[1] if (@_ == 2);
    return $_[0]->{crop}->{width};
}
sub crop_height
{
    $_[0]->{crop}->{height} = $_[1] if (@_ == 2);
    return $_[0]->{crop}->{height};
}


#
# Save modified tags.
# On success, return a bitset of TAG_* constants.
# On failure, return undef.
#
# $taget_file is optional.
# if defined :
#  - The $target_file shall not exists,
#  - The $target_file content will be filed with file used to load tags and their modifications,
#  - Current tags will not be modified (a new call to save() will return the same bitset).
# else :
#  - Tags will be writed to file used to load tags,
#  - Tags will be re-loaded (a new call to save() will return 0).
#
#
sub save
{
    my ($self, $target_file) = @_;

    my $updated_tags = TAG_NONE;

    # Update exif dimensions if they are invalid
    if (! defined($self->{exif_tools}->GetValue('ExifImageWidth')) ||
        $self->{exif_tools}->GetValue('ExifImageWidth') ne $self->{width}) {
        $self->{exif_tools}->SetNewValue('ExifImageWidth' => $self->{width});
        $updated_tags |= TAG_DIMENSIONS;
    }
    if (! defined($self->{exif_tools}->GetValue('ExifImageHeight')) ||
        $self->{exif_tools}->GetValue('ExifImageHeight') ne $self->{height}) {
        $self->{exif_tools}->SetNewValue('ExifImageHeight' => $self->{height});
        $updated_tags |= TAG_DIMENSIONS;
    }

    #Update date
    if (defined($self->{date})) {
        if (! defined($self->{exif_tools}->GetValue('DateTimeOriginal')) ||
            $self->{exif_tools}->GetValue('DateTimeOriginal') ne $self->{date}) {
            $self->{exif_tools}->SetNewValue('DateTimeOriginal' => $self->{date});
            $updated_tags |= TAG_DATE;
        }
        # According to EXIF standard, this tag is the last modification date. So it should not be updated.
        # But some tools use this tag instead of the DateTimeOriginal one.
        if (! defined($self->{exif_tools}->GetValue('CreateDate')) ||
            $self->{exif_tools}->GetValue('CreateDate') ne $self->{date}) {
            $self->{exif_tools}->SetNewValue('CreateDate' => $self->{date});
            $updated_tags |= TAG_DATE;
        }
    }

    # Update title
    if (defined($self->{title}) && (
            ! defined($self->{exif_tools}->GetValue('ImageDescription')) ||
            $self->{exif_tools}->GetValue('ImageDescription') ne $self->{title}
        )) {
        $self->{exif_tools}->SetNewValue('ImageDescription' => $self->{title});
        $updated_tags |= TAG_TITLE;
    }

    # Update comment
    if (defined($self->{comment}) && (
            ! defined($self->{exif_tools}->GetValue('UserComment')) ||
            $self->{exif_tools}->GetValue('UserComment') ne $self->{comment}
        )) {
        $self->{exif_tools}->SetNewValue('UserComment' => $self->{comment});
        $updated_tags |= TAG_COMMENT;
    }

    #Update crop information
    if (defined($self->{crop}->{left}) && (
            ! defined($self->{exif_tools}->GetValue('XMP:CropLeft')) ||
            $self->{exif_tools}->GetValue('XMP:CropLeft') ne $self->{crop}->{left}
        )) {
        $self->{exif_tools}->SetNewValue('XMP:CropLeft' => $self->{crop}->{left});
        $updated_tags |= TAG_CROP;
    }
    if (defined($self->{crop}->{top}) && (
            ! defined($self->{exif_tools}->GetValue('XMP:CropTop')) ||
            $self->{exif_tools}->GetValue('XMP:CropTop') ne $self->{crop}->{top}
        )) {
        $self->{exif_tools}->SetNewValue('XMP:CropTop' => $self->{crop}->{top});
        $updated_tags |= TAG_CROP;
    }
    if (defined($self->{crop}->{width}) && (
            ! defined($self->{exif_tools}->GetValue('XMP:CropWidth')) ||
            $self->{exif_tools}->GetValue('XMP:CropWidth') ne $self->{crop}->{width}
        )) {
        $self->{exif_tools}->SetNewValue('XMP:CropWidth' => $self->{crop}->{width});
        $updated_tags |= TAG_CROP;
    }
    if (defined($self->{crop}->{height}) && (
            ! defined($self->{exif_tools}->GetValue('XMP:CropHeight')) ||
            $self->{exif_tools}->GetValue('XMP:CropHeight') ne $self->{crop}->{height}
        )) {
        $self->{exif_tools}->SetNewValue('XMP:CropHeight' => $self->{crop}->{height});
        $updated_tags |= TAG_CROP;
    }

    # Save file
    return undef if (! $self->{exif_tools}->WriteInfo($self->{file}, $target_file));
    $self->_read_exif_tags() if (!$target_file);

    return $updated_tags;
}


#
# Rotate image according to EXIF rotation tag.
# Only works for jpeg files.
# Return:
# 0 - error, no change(not a jpeg, invalid exif oritentation or not rw),
# 1 - Image rotated and orientation tag updated,
# 2 - No change (orientation is good or EXIF tag not found).
#
# Note: modified tags are not saved to the file.
#       You still need to call 'save'.
#
sub auto_rotate
{
    my ($self) = @_;

    # Use a temp file in the same folder.
    my $tmp_file = $self->{file} . '_ImgTag_Rotate_TMP_';

    my $result = (sub {

        # Remove existing temp file
        if (-e $tmp_file) { return 0 if !unlink($tmp_file); }

        # Load orientation
        return 0 if ($self->{exif_tools}->GetValue('MIMEType') ne 'image/jpeg');
        my $orientation = $self->{exif_tools}->GetValue('Orientation', 'Raw');
        return 2 if (!defined($orientation) || $orientation eq '1');

        # Compute transformation
        my $transform = undef;
        if    ($orientation eq '2') { $transform = [flip => 'horizontal']; }
        elsif ($orientation eq '3') { $transform = [rotate => 180];        }
        elsif ($orientation eq '4') { $transform = [flip => 'vertical'];   }
        elsif ($orientation eq '5') { $transform = ['transpose' => 1];     }
        elsif ($orientation eq '6') { $transform = [rotate => 90];         }
        elsif ($orientation eq '7') { $transform = ['transverse' => 1];    }
        elsif ($orientation eq '8') { $transform = [rotate => 270];        }
        else {return 0;} # invalid orientation.

        # Rotate
        jpegtran($self->{file} => $tmp_file, @$transform, copy => 'all');
        return 0 if (! -s $tmp_file);

        # Update Tags (Exif dimensions are modified by jpegtran but not orientation)
        my $exif_tool = new Image::ExifTool;
        $exif_tool->Options(Unknown => 1, Charset => 'UTF8');
        $exif_tool->ExtractInfo($tmp_file);
        $exif_tool->SetNewValue('Orientation' => 1, Type => 'Raw');
        $exif_tool->SetNewValue('IFD1:Orientation'); # Delete if exists
        return 0 if !$exif_tool->WriteInfo($tmp_file);

        # Overwrite source file
        return 0 if !copy($tmp_file, $self->{file});

        # Update internal data
        $self->{exif_tools}->ExtractInfo($self->{file});
        $self->{width} = $self->_read_exif_tag_int('ImageWidth');
        $self->{height} = $self->_read_exif_tag_int('ImageHeight');

        return 1;
                  })->();

    unlink($tmp_file);
    return $result;
}



#
# Read tags. Return 0 on error.
# This function will overwrite all readed tags.
#
sub _read_exif_tags
{
    my ($self) = @_;

    # Load tags
    my $exif_tool = new Image::ExifTool;
    $exif_tool->Options(Unknown => 1, Charset => 'UTF8');

    return 0 if (!$exif_tool->ExtractInfo($self->{file}));
    return 0 if ($exif_tool->GetValue('MIMEType') !~ /^image/);

    $self->{exif_tools} = $exif_tool;

    # Read dimension from file header (not from tag informations)
    $self->{width} = $self->_read_exif_tag_int('ImageWidth');
    $self->{height} = $self->_read_exif_tag_int('ImageHeight');
    return 0 if (!$self->{width} || !$self->{height});

    # Read date. Check several fields because some camera doesn't follow EXIF standard
    my $date = $self->_read_exif_tag('DateTimeOriginal');
    $date = $self->_read_exif_tag('CreateDate')              if (!$date);
    $date = $self->_read_exif_tag('CreationDate')            if (!$date);
    $date = $self->_read_exif_tag('SubSecDateTimeOriginal')  if (!$date);
    $date = $self->_read_exif_tag('DateTimeCreated')         if (!$date);
    $date = $self->_read_exif_tag('DateTimeDigitized')       if (!$date);
    $date = $self->_read_exif_tag('SubSecCreateDate')        if (!$date);
    $self->{date} = $date;

    # Read title and comment
    $self->{title} = $self->_read_exif_tag('ImageDescription');
    $self->{comment} = $self->_read_exif_tag('UserComment');

    # Crop information to build thumbnail (non-standard tags, specific to this tool)
    $self->{crop}->{left} = $self->_read_exif_tag('XMP:CropLeft');
    $self->{crop}->{top} = $self->_read_exif_tag('XMP:CropTop');
    $self->{crop}->{width} = $self->_read_exif_tag('XMP:CropWidth');
    $self->{crop}->{height} = $self->_read_exif_tag('XMP:CropHeight');

    #Get camera description
    my $make = $self->_read_exif_tag('Make') || '';
    my $model = $self->_read_exif_tag('Model') || '';
    my $soft = $self->_read_exif_tag('Software');
    $self->{camera_infos}->{camera} = $make . (($make ne '' && $model ne '')? ' ': '') .
        $model .  (($soft)? " ($soft)" : '');
    if (!$self->{camera_infos}->{camera}) {
        $self->{camera_infos}->{camera} = 'Unknown';
    }

    #Get exposure
    $self->{camera_infos}->{exposure} =
        $self->_read_exif_tag('ExposureTime') ||
        $self->_read_exif_tag('ShutterSpeed') ||
        $self->_read_exif_tag('ShutterSpeedValue') ||
        'Unknown';


    #Get aperture
    $self->{camera_infos}->{aperture} =
        $self->_read_exif_tag('FNumber') ||
        $self->_read_exif_tag('Aperture') ||
        $self->_read_exif_tag('LensAperture') ||
        $self->_read_exif_tag('ApertureValue') ||
        'Unknown';


    #Get Exposure Bias
    $self->{camera_infos}->{exposure_bias} =
        $self->_read_exif_tag('ExposureCompensation');
    $self->{camera_infos}->{exposure_bias} = 'Unknown'
        if (! defined($self->{camera_infos}->{exposure_bias}));

    #Get ISO
    $self->{camera_infos}->{iso} =
        $self->_read_exif_tag('ISO') ||
        'Unknown';

    #Get Focale
    $self->{camera_infos}->{focal} =
        $self->_read_exif_tag('FocalLength') ||
        'Unknown';

    #Get Flash
    $self->{camera_infos}->{flash} =
        $self->_read_exif_tag('Flash') ||
        'Unknown';

    1;
}



#
# Read a tag. Return undef if tag not set.
#
sub _read_exif_tag
{
    my ($self, $tag_name) = @_;
    my $value = $self->{exif_tools}->GetValue($tag_name);
    utf8::decode($value) if (defined($value));
    return $value;
}

#
# Read a tag and convet it to interger (no checks).
# Return undef if tag not set.
#
sub _read_exif_tag_int
{
    my ($self, $tag_name) = @_;
    my $value = $self->_read_exif_tag($tag_name);
    return int($value) if (defined($value));
    return undef;
}

1;
