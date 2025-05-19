requires 'Exporter';
requires 'Carp';
requires 'Business::DK::CVR';
requires 'English';
requires 'Date::Calc';
requires 'Tie::IxHash';
requires 'Class::InsideOut';
requires 'Params::Validate';
requires 'Readonly';
requires 'perl', '5.010';

on 'test', sub {
    requires 'File::Spec';
    requires 'IO::Handle';
    requires 'IPC::Open3';
    requires 'Pod::Coverage::TrustPod';
    requires 'Test::Fatal';
    requires 'Test::Kwalitee', '1.28';
    requires 'Test::More';
    requires 'Test::Exception';
    requires 'Test::Pod', '1.52';
    requires 'Test::Pod::Coverage', '1.10';
    requires 'Test::Tester', '1.302213';
    requires 'Perl::Critic::Bangs';
    requires 'Test::NoPlan';
};

on 'configure', sub {
    requires 'ExtUtils::MakeMaker';
};

on 'develop', sub {
    requires 'Pod::Coverage::TrustPod';
    requires 'Test::CPAN::Changes', '0.500005';
    requires 'Test::CPAN::Meta::JSON', '0.16';
    requires 'Test::Kwalitee', '1.28';
    requires 'Test::Perl::Critic';
    requires 'Test::Pod', '1.52';
    requires 'Test::Pod::Coverage', '1.10';
};
