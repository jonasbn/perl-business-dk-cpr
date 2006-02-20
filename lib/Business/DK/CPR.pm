package Business::DK::CPR;

# $Id: CPR.pm,v 1.2 2006-02-20 21:51:03 jonasbn Exp $

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

Business::DK::CVR - a danish CPR (Central Person Registraion) code generator/validator

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 validate

=head2 calculate

=head1 BUGS

Please report issues via CPAN RT:

  http://rt.cpan.org/NoAuth/Bugs.html?Dist=Business-DK-CPR

or by sending mail to

  bug-Business-DK-CPR@rt.cpan.org

=head1 SEE ALSO

=over

=item L<http://www.cpr.dk/>

=item L<Business::DK::PO>

=item L<Business::DK::CPR>

=back

=head1 AUTHOR

Jonas B. Nielsen, (jonasbn) - C<< <jonasbn@cpan.org> >>

=head1 COPYRIGHT

Business-DK-CPR is (C) by Jonas B. Nielsen, (jonasbn) 2006

Business-DK-CPR is released under the artistic license

The distribution is licensed under the Artistic License, as specified
by the Artistic file in the standard perl distribution
(http://www.perl.com/language/misc/Artistic.html).

=cut
