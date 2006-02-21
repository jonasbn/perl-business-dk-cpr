package Business::DK::CPR;

# $Id: CPR.pm,v 1.4 2006-02-21 21:02:45 jonasbn Exp $

use strict;
use vars qw($VERSION @ISA @EXPORT_OK);
use Carp qw(croak);
use Business::DK::CVR qw(_length _calculate_sum);
use Business::DK::PO qw(_argument _content);
use Date::Calc qw(check_date);

require Exporter;

$VERSION = '0.01';
@ISA = qw(Exporter);
@EXPORT_OK = qw(validate calculate _checkdate);

use constant MODULUS_OPERAND    => 11;
use constant DATE_LENGTH        => 6;

my @controlcifers = qw(4 3 2 7 6 5 4 3 2 1);

sub calculate {
	my $birthdate = shift;
		
	if (! $birthdate) {
		_argument(DATE_LENGTH);
	}
	_content($birthdate);
	_length($birthdate, DATE_LENGTH);
	_checkdate($birthdate);

	my @cprs;	
	for (1 .. 999) {
		my $n = sprintf("%03s", $_);
				
		my $sum = _calculate_sum(($birthdate . $n), \@controlcifers);	
		my $mod = $sum%MODULUS_OPERAND;
		
		my $checkciffer = (MODULUS_OPERAND - $mod);
		
		if ($checkciffer < 10) {
			push @cprs, ($birthdate . $n . $checkciffer);
		}
	}
		
	if (wantarray) {
		return @cprs;
	} else {
		return scalar(@cprs);
	}
}

sub validate {
	my $controlnumber = shift;

	my $controlcode_length = scalar(@controlcifers);

	if (! $controlnumber) {
		_argument($controlcode_length);
	}
	_content($controlnumber);
	_length($controlnumber, $controlcode_length);
	
	my $sum = _calculate_sum($controlnumber, \@controlcifers);
	
	if ($sum%MODULUS_OPERAND) {
		return 0;
	} else {
		return 1;
	}	
}

sub _checkdate {
	my $birthdate = shift;
	
	if (! $birthdate) {
		croak "argument should be provided";				
	}
	
	if (! ($birthdate =~ m/^(\d{2})(\d{2})(\d{2})$/)) {
		croak "argument: $birthdate could not be parsed";			
	}
		
	if (! check_date($3, $2 ,$1)) {
		croak "argument: $birthdate has to be a valid date in the following format: ddmmyy";			
	}
	return 1;
}

1;

__END__

=head1 NAME

Business::DK::CVR - a danish CPR code generator/validator

=head1 VERSION

This documentation describes version 0.01

=head1 SYNOPSIS

	use Business::DK::CPR qw(validate);

	my $rv;
	eval {
		$rv = validate(1501721111);
	};
	
	if ($@) {
		die "Code is not of the expected format - $@";
	}
	
	if ($rv) {
		print "CPR is valid";
	} else {
		print "CPR is not valid";
	}


	use Business::DK::CPR qw(calculate);

	my @cprs = calculate(150172);

	my $number_of_valid_cprs = calculate(150172);


=head1 DESCRIPTION

CPR stands for Central Person Registration and it a social security number used 
in Denmark.

=head2 validate

This function checks a CPR number for validity. It takes a CPR number as 
argument and returns 1 (true) for valid and 0 (false) for invalid.

It dies if the CPR number is malformed or in anyway unpassable, be aware that
the 6 first digits are a date (SEE: B<_checkdate> function below.

NB! it is possible to make fake CPR number, which appear valid, please see 
MOTIVATION and the B<calculation> function. 

=head2 calculate

This function takes an integer representing a date and calculates valid CPR 
numbers for the specified date. In scalar context returns the number of valid 
CPR numbers possible and in list context a list of valid CPR numbers.

If the date malformed, in anyway not valid or unspecified the function dies.

=head1 PRIVATE FUNCTIONS

=head2 _checkdate

This function takes an integer representing a date in the format: ddmmyy.

It check the validity of the date and returns 1 (true) if the date is valid.

It dies if no argument is provided or if the data in invalid or cannot be 
parsed.

=head1 EXPORTS

Business::DK::CPR exports on request:

=over

=item validate

=item calculate

=item _checkdate

=back

=head1 TODO

=over

=item The CPR agency in Denmark are developing a new CPR scheme, due to the 
fact that they are running out of valid CPR numbers.

=back

=head1 TESTS

Coverage of the test suite is at 100%

=head1 BUGS

Please report issues via CPAN RT:

  http://rt.cpan.org/NoAuth/Bugs.html?Dist=Business-DK-CPR

or by sending mail to

  bug-Business-DK-CPR@rt.cpan.org

=head1 SEE ALSO

=over

=item L<http://www.cpr.dk/>

=item L<Business::DK::PO>

=item L<Business::DK::CVR>

=back

=head1 MOTIVATION

I write business related applications. So I need to be able to validate CPR 
numbers once is a while, hence the validation function.

The calculate function is a completely different story. When I was in school
we where programming in Comal80 and some of the guys in my school created 
lists of CPR numbers valid with their own birthdays. The thing was that if you 
got caught riding the train without a valid ticket the personnel would only 
check the validity of you CPR number, so all you have to remember was your 
birthday and 4 more digits not being the 4 last digits of your CPR number.

I guess this was the first hack I ever heard about and saw - I never tried it
out, but back then it really fascinated me and my interest in computers was 
really sparked.

=head1 AUTHOR

Jonas B. Nielsen, (jonasbn) - C<< <jonasbn@cpan.org> >>

=head1 COPYRIGHT

Business-DK-CPR is (C) by Jonas B. Nielsen, (jonasbn) 2006

Business-DK-CPR is released under the artistic license

The distribution is licensed under the Artistic License, as specified
by the Artistic file in the standard perl distribution
(http://www.perl.com/language/misc/Artistic.html).

=cut
