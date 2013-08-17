# $Id$

use strict;
use warnings;
use Data::Dumper;
use autodie;
use String::Diff qw( diff );

my $workingdirectory = '/tmp/blada';

use SVN::Client;
my $ctx = SVN::Client->new(
    auth => [
        SVN::Client::get_simple_provider(),
        SVN::Client::get_simple_prompt_provider( \&simple_prompt, 2 ),
        SVN::Client::get_username_provider()
    ]
);

my $receiver = sub {
    my( $path, $info, $pool ) = @_;
    print "Current revision of $path is ", $info->rev, "\n";
};

$ctx->checkout("https://logiclab.jira.com/svn/OPENLAB/trunk/boilerplates", $workingdirectory, 'HEAD', 0);

opendir(DIR, $workingdirectory);
my @boilerplates = grep { -f "$workingdirectory/$_" } readdir(DIR);
closedir DIR;
	
my %bps;
my %files;

foreach my $boilerplate (@boilerplates) {		
	open FIN, '<', "$workingdirectory/$boilerplate";
	$bps{$boilerplate} = join '', <FIN>;
	close FIN; 
	
	if (-e "t/$boilerplate" && -f _) {
		open FIN2, '<', "t/$boilerplate";
		$files{$boilerplate} = join '', <FIN2>;
		close FIN2; 	
	}

	my $diff = diff($files{$boilerplate}, $bps{$boilerplate},
      remove_open => '<del>',
      remove_close => '</del>',
      append_open => '<ins>',
      append_close => '</ins>',
    );
    #print "$diff->[0]\n";# this is <del>Perl</del>
    print "$diff->[1]\n";# this is <ins>Ruby</ins>

	my (@ins) = $diff->[1] =~ m/(<ins>)/gsmx;
	
	print STDERR "We have: ".scalar @ins." diffs\n";
	
	if (scalar @ins > 1) {
		open FOUT, '>', "t/$boilerplate";
		print FOUT $bps{$boilerplate};
		close FOUT; 	
	}
	
	#assert that file is present in project
}
