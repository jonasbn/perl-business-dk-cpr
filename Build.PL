# Build.PL for Business-DK-CPR

# $Id: Build.PL,v 1.3 2008-09-09 19:15:28 jonasbn Exp $

use Module::Build;
my $build = Module::Build->new(
	dist_author        => 'Jonas B. Nielsen, (jonasbn) <jonasbn@cpan.org>',
	module_name        => 'Business::DK::CPR',
	dist_version_from  => 'lib/Business/DK/CPR.pm',
	license            => 'artistic',
	create_makefile_pl => 'passthrough',
	create_readme      => 1,
	recursive_test_files => 1,
	requires => {
	    'Exporter'          => '0', #core
		'Carp'              => '0', #core
		'Business::DK::PO'  => '0.02',
		'Business::DK::CVR' => '0.01',
		'Date::Calc'        => '0',
		'Tie::IxHash'       => '0',
	},
    build_requires       => {
        'Test::More' => '0',    #core
        'Test::Exception' => '0',
		'Test::Kwalitee' => '0',
		'Test::Perl::Critic' => '0',
		'Test::Prereq::Build' => '0',
    },
    meta_merge => {
        resources => {
            homepage => 'http://logicLAB.jira.com/browse/BDKCPR',
            bugtracker =>
                'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Business-DK-CPR',
            repository => 'http://logicLAB.jira.com/svn/BDKCPR',
        }
    },
);
$build->create_build_script();
