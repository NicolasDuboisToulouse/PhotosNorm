# PhotosNorm
Basic perl scripts to _normalize_ photos (Exif rotation, Exif corrections...)

## Target platforms
Theses scripts are design to be cross-platform (Linux, Windows. Not tested on MacOS). 

## Dependencies
You need a standard perl setup ([Strawberry Perl](http://strawberryperl.com) on Windows) and some extra modules that can be installed with cpan tool:
* [WxPerl](https://metacpan.org/pod/Wx) (cross-platform GUI. Needed only by 'gui' scripts)
* [Image::ExifTool](https://metacpan.org/pod/Image::ExifTool)
* [Image::JpegTran](https://metacpan.org/pod/Image::JpegTran)
