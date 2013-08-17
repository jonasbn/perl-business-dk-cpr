# $Id$

use strict;
use warnings;
use Env qw($TEST_AUTHOR);
use Test::More;

eval {
    require SVN::Client;
};

TODO: {
	local $TODO = 'These tests are not completely implemented';
	if ($@ and $TEST_AUTHOR) {
    	plan skip_all => 'SVN::Client not installed; skipping';
	} elsif (not $TEST_AUTHOR) {
    	plan skip_all => 'set TEST_AUTHOR to enable';
	} else {
    
    	#TODO
		my @boilerplates = qw(critic.t);

		my $ctx = new SVN::Client(
    		auth => [
        		SVN::Client::get_simple_provider(),
        		SVN::Client::get_simple_prompt_provider( \&simple_prompt, 2 ),
        		SVN::Client::get_username_provider(),
    		],
		);

		foreach my $file (@boilerplates) {
			if (-e $file) {
				$ctx->diff_summarize();
				ok(1);
			}
		}
	}
};