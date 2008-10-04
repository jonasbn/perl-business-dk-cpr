# $Id: validate.t,v 1.2 2006/02/20 22:28:54 jonasbn Exp $

use strict;
use Test::More tests => 14;
use Test::Exception;

#Test 1
use_ok('Business::DK::CPR', qw(validate2007));

#Test 2
ok(validate2007(1501729996), 'Ok');

#Test 3
dies_ok {validate2007()} 'no arguments';

#Test 4
dies_ok {validate2007(123456789)} 'too short, 9';

#Test 5
dies_ok {validate2007(12345678901)} 'too long, 11';

#Test 6
dies_ok {validate2007('abcdefg1')} 'unclean';

#Test 7
dies_ok {validate2007(0)} 'zero';

#Test 8-14
my $birthday = '150172';

my $i = 0;
while ($i < 7) {
    my $cpr = $birthday . sprintf('%04d', $i);
    ok(! validate2007($cpr), "invalid CPR: $cpr");
    $i++;
}
