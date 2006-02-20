# $Id: validate.t,v 1.1 2006-02-20 21:38:48 jonasbn Exp $

use strict;
use Test::More tests => 9;
use Test::Exception;

#Test 1
BEGIN { use_ok('Business::DK::CPR', qw(validate)) };

#Test 2
ok(validate(1501722363), 'Ok');

#Test 3
ok(validate(1501721111), 'Ok, generated');

#Test 4
dies_ok {validate()} 'no arguments';

#Test 5
dies_ok {validate(123456789)} 'too short, 9';

#Test 6
dies_ok {validate(12345678901)} 'too long, 11';

#Test 7
dies_ok {validate("abcdefg1")} 'unclean';

#Test 8
dies_ok {validate(0)} 'zero';

#Test 9
ok(! validate("1501729993"), 'invalid');
