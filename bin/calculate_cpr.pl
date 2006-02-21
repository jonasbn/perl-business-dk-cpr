#!/usr/bin/perl -w

# $Id: calculate_cpr.pl,v 1.1 2006-02-21 21:06:31 jonasbn Exp $

use strict;
use Business::DK::CPR qw(calculate);

my $arg = $ARGV[0];
chomp($arg);
my @cprs = calculate($arg);

foreach (@cprs) {
	print "$_\n";
}

exit(0);
