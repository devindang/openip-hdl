#!/usr/bin/perl

use strict;
use warnings;
use File::Find;

my $dir = '.';

find(\&search, $dir);

sub search {
# make clean
    if (-f $_ && $_ eq 'makefile') {
        print "find $_\n";
        system("make clean");
    }
# clean scripts
    if (-f $_ && $_ eq 'clean.sh') {
        print "find $_\n";
        system("sh clean.sh");
    }
}

