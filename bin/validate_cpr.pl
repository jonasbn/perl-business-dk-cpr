#!/usr/bin/perl

# $Id$

use strict;
use warnings;
use vars qw($VERSION);
use Getopt::Long;
use Business::DK::CPR qw(validate1968 validate2007 validate);

$VERSION = '0.01';

my $verbose = 0;
my $result = GetOptions( 'verbose' => \$verbose );

if ( not $ARGV[0] ) {
    die "usage: validate_cpr.pl [-v] <10 digit CPR number>\n";
}

my $cpr = $ARGV[0];

if ($verbose) {

    my $rv = 0;
    my @algorithm;
    my @gender;

    eval { $rv = validate1968($cpr); 1; }
        or $rv = 0;

    if ( $rv && $rv % 2 ) {
        push @algorithm, '1968';
        push @gender,    'male';
    } elsif ($rv) {
        push @algorithm, '1968';
        push @gender,    'female';
    }

    eval { $rv = validate2007($cpr); 1; }
        or $rv = 0;

    if ( $rv && $rv % 2 ) {
        push @algorithm, '2007';
        push @gender,    'male';
    } elsif ($rv) {
        push @algorithm, '2007';
        push @gender,    'female';
    }

    if ( scalar @algorithm ) {

        print "$cpr is valid for: " . join ', ',     @algorithm;
        print '. gender indicated is: ' . join ', ', @gender;
        print "\n";
    } else {
        print "$cpr is not valid\n";
    }

} else {
    if ( validate($cpr) ) {
        print "$cpr is valid\n";
    } else {
        print "$cpr is not valid\n";
    }
}

exit 0;
