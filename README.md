# PhotosNorm
Basic perl scripts to do some _normalization_ on photos:
* Correct some invalid metadata (i.e EXIF) tags (Nothing done for most recent cameras),
* Rotate photos according to metadata orientation,
* Fix rights (Linux only),
* Display and set some metadata: _Date_, _Title_, _Comment_,
* Rename files with date and title metadata.

## Target platforms
Theses scripts are design to be cross-platform (Linux, Windows. Not tested on MacOS). 

## Dependencies
You need a standard perl setup ([Strawberry Perl](http://strawberryperl.com) on Windows) and some extra modules that can be installed with cpan tool:
* [Wx](https://metacpan.org/pod/Wx) (WxPerl is a cross-platform GUI. Needed only by _gui_ scripts)
* [Image::ExifTool](https://metacpan.org/pod/Image::ExifTool)
* [Image::JpegTran](https://metacpan.org/pod/Image::JpegTran)
