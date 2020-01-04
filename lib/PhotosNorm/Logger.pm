# Dubois Nicolas (c) 2019
# MIT Licence
#
# A really basic logger
#
package PhotosNorm::Logger;
use strict;
use warnings;

sub new
{
    return bless({}, $_[0]);
}

sub log
{
    my($self, $text) = @_;
    print $text;
}

sub lognl
{
    my($self, $text) = @_;
    $self->log($text . "\n");
}

1;
