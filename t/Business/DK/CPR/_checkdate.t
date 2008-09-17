# $Id: _checkdate.t,v 1.1 2006/02/20 21:38:48 jonasbn Exp $

use strict;
use Test::More tests => 5;
use Test::Exception;

#Test 1, load test
BEGIN { use_ok('Business::DK::CPR', qw(_checkdate)); };

#Test 2
ok(_checkdate(150172), 'Ok');

#Test 3
dies_ok{_checkdate()} 'none';

#Test 4
dies_ok{_checkdate("abc")} 'tainted';

#Test 5
dies_ok{_checkdate(310205)} 'bad date';
