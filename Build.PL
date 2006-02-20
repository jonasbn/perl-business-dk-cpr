# Build.PL for Business-DK-CPR

# $Id: Build.PL,v 1.2 2006-02-20 21:51:03 jonasbn Exp $

use Module::Build;
my $build = Module::Build->new(
	dist_author        => 'Jonas B. Nielsen, (jonasbn) <jonasbn@cpan.org>',
	module_name        => 'Business::DK::CPR',
	dist_version_from  => 'lib/Business/DK/CPR.pm',
	license            => 'artistic',
	create_makefile_pl => 'passthrough',
	requires => {
	    'Exporter'          => 0, #core
		'Carp'              => 0, #core
		'Test::Exception'   => 0,
		'Business::DK::PO'  => 0.02,
		'Business::DK::CVR' => 0.01,
		'Date::Calc'        => 0,
	},
);
$build->create_build_script();
