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
	    'Exporter'          => 0, #core
		'Carp'              => 0, #core
		'Test::Exception'   => 0,
		'Business::DK::PO'  => 0.02,
		'Business::DK::CVR' => 0.01,
		'Date::Calc'        => 0,
		'Hash::Merge'		=> 0,
	},
);
$build->create_build_script();
