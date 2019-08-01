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

#
# Create a new PhotosNorm::ImageTag from $file.
# If $file doesn't exist or is not an image (mimetype), the create will fail (return undef)
#
sub new
{
    my ($pkg, $file) = @_;

    my $exif_tool = new Image::ExifTool;
    $exif_tool->Options(Unknown => 1, Charset => 'UTF8');

    return undef if (!$exif_tool->ExtractInfo($file));
    return undef if ($exif_tool->GetValue('MIMEType') !~ /^image/);

    my $self = bless( { file => $file, exif_tools => $exif_tool }, $pkg);

    # Read dimension from file header (not from tag informations)
    $self->{width} = $self->_read_exif_tag_int('ImageWidth');
    $self->{height} = $self->_read_exif_tag_int('ImageHeight');
    return undef if (!$self->{width} || !$self->{height});

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
    $self->{crop}->{top} = $self->_read_exif_tag('CropTop');
    $self->{crop}->{left} = $self->_read_exif_tag('CropLeft');
    $self->{crop}->{width} = $self->_read_exif_tag('CropWidth');
    $self->{crop}->{height} = $self->_read_exif_tag('CropHeight');

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
    
    
    return $self;
}


# TODO accessors (take care of r/w or ro)

# TODO Save ExifImageWidth, ExifImageHeight, DateTimeOriginal, CreateDate, ...


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
