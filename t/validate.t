# $Id: validate.t,v 1.2 2006-02-20 22:28:54 jonasbn Exp $

use strict;
use Test::More tests => 10;
use Test::Exception;

#Test 1
BEGIN { use_ok('Business::DK::CPR', qw(validate validate1968 validate2001)) };

#Test 2
ok(validate(1501721111), 'Ok, generated');

#Test 3
dies_ok {validate()} 'no arguments';

#Test 4
dies_ok {validate(123456789)} 'too short, 9';

#Test 5
dies_ok {validate(12345678901)} 'too long, 11';

#Test 6
dies_ok {validate("abcdefg1")} 'unclean';

#Test 7
dies_ok {validate(0)} 'zero';

#Test 8
ok(! validate("1501720001"), 'invalid');
ok(! validate2001("1501720001"), 'invalid');
ok(! validate1968("1501720001"), 'invalid');