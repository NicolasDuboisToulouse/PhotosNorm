# Dubois Nicolas (c) 2019
# MIT Licence
#
# Reusable basic functions
#
package PhotosNorm::Main;
use strict;
use warnings;
use File::Basename;


# Files readed from arguments
our @files;

# Return default help string
sub help
{
    my ($description) = @_;
    if (defined $description) {
        $description = "\n" . $description;
    } else {
        $description = '';
    }

    my $soft = basename($0);


    return << "END_HELP";
USAGE: $soft -h | --help
       $soft <image> [ <image> ... ]
       $soft <folder>
$description
  -h
  --help
     Display this help screen. If you provide images, they will be ignored.

  <image> [ <image> ... ]
     Apply the correction on all provided images.

  <folder>
     Will look for images (by extension) in proved folder and apply the needed corrections.
     Only one folder is supported. The lookup is not recursive.

END_HELP
}

sub usage
{
    my ($logger, $description) = @_;
    $logger->msg(help($description));
    return 0;
}


# Parse arguments
sub parse_args
{
    my ($logger, $help_description, @argv) = @_;

    while (my $arg = shift @argv) {
        exit usage($logger, $help_description) if ($arg eq '-h' || $arg eq '--help');

        if ($arg =~ /^-/) {
            $logger->msg("Unkown option '$arg'!");
            exit 1;
        }

        push(@files, $arg);
    }

    exit usage($logger, $help_description) if (@files == 0);
}


1;

