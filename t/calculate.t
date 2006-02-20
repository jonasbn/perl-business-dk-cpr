# $Id: calculate.t,v 1.1 2006-02-20 21:38:48 jonasbn Exp $

use strict;
use Test::More tests => 825;
use Test::Exception;

#Test 1, load test
BEGIN { use_ok('Business::DK::CPR', qw(calculate validate)) };

#Test 2
dies_ok{calculate()} 'no arguments';

#Test 3
dies_ok{calculate(1501721)} 'too long';

#Test 4
dies_ok{validate("150172a")} 'unclean';

#Test 5
dies_ok{validate(0)} 'zero';

#Test 6
is(calculate(150172), 818);

#Test 7
ok(my @cprs = calculate(150172));

foreach (@cprs) {
	ok(validate($_));
}
