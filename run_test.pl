#!/usr/bin/env perl
BEGIN {
    my $soft_home = ($0 =~ /(.*)[\\\/]/) ? $1 : '.';
    unshift @INC, "$soft_home/lib";
}

use strict;
use warnings;
use Test::Harness;


my @tests;
$Test::Harness::verbose = 0;


while (my $arg = shift(@ARGV))
{
    if ($arg eq '-h' || $arg eq '--help') {
        print "USAGE: run_test.pl [-v] [ test1 [ test2 ... ] ]\n";
        exit 0;
    }
    elsif ($arg eq '-v') {
        $Test::Harness::verbose = 1;
        next;
    }
    elsif($arg =~ /^-/) {
        die "Unkwown option '$arg'!\n";        
    }
    
    push(@tests, $arg);
}


@tests = grep(-f, <t/*.t>) if ($#tests lt 0);
    

Test::Harness::runtests(@tests);
