package Business::DK::CPR;

# $Id: CPR.pm,v 1.9 2008-09-09 19:15:44 jonasbn Exp $

use strict;
use warnings;
use vars qw($VERSION @EXPORT_OK);
use Carp qw(croak);
use Business::DK::CVR qw(_length _calculate_sum);
use Business::DK::PO qw(_argument _content);
use Date::Calc qw(check_date);
use Hash::Merge qw( merge );
use base 'Exporter';

$VERSION   = '0.04';
@EXPORT_OK = qw(
    validate calculate _checkdate validate1968 validate2001 generate validateCPR
);

use constant MODULUS_OPERAND => 11;
use constant DATE_LENGTH     => 6;
use constant VALID           => 1;
use constant INVALID         => 0;

my @controlcifers = qw(4 3 2 7 6 5 4 3 2 1);
my %female_seeds  = (
    4 => 9994,
    2 => 9998,
    6 => 9996,
);

my %male_seeds = (
    1 => 9997,
    3 => 9999,
    5 => 9995,
);

sub calculate {
    my $birthdate = shift;

    _assert_date($birthdate);

    my @cprs;
    for ( 1 .. 999 ) {
        my $n = sprintf '%03s', $_;

        my $sum = _calculate_sum( ( $birthdate . $n ), \@controlcifers );
        my $mod = $sum % MODULUS_OPERAND;

        my $checkciffer = ( MODULUS_OPERAND - $mod );

        if ( $checkciffer < 10 ) {
            push @cprs, ( $birthdate . $n . $checkciffer );
        }
    }

    if (wantarray) {
        return @cprs;
    } else {
        return scalar @cprs;
    }
}

sub _assert_date {
    my $birthdate = shift;

    if ( !$birthdate ) {
        _argument(DATE_LENGTH);
    }
    _content($birthdate);
    _length( $birthdate, DATE_LENGTH );
    _checkdate($birthdate);

    return 1;
}

sub validateCPR {
    return validate(shift);
}

sub validate {
    my $controlnumber = shift;

    if ( validate1968($controlnumber) ) {
        return VALID;
    } else {
        return validate2001($controlnumber);
    }
}

sub validate2001 {
    my $controlnumber = shift;

    _assert_controlnumber($controlnumber);

    my $control = substr $controlnumber, 6, 4;

    my %seeds = %{ merge( \%female_seeds, \%male_seeds ) };

    foreach my $seed ( keys %seeds ) {
        my $s = $seed;

        while (1) {
            $s += 6;
            if ( $s > $seeds{$seed} ) {
                last;
            }

            if ( $control eq sprintf '%04d', $s ) {
                return VALID;
            }
        }
    }

    return INVALID;
}

sub validate1968 {
    my $controlnumber = shift;

    _assert_controlnumber($controlnumber);

    my $sum = _calculate_sum( $controlnumber, \@controlcifers );

    #Note this might look like it is turned upside down but no rest from the
    #modulus calculation indicated validity
    if ( $sum % MODULUS_OPERAND ) {
        return INVALID;
    } else {
        return VALID;
    }
}

sub _assert_controlnumber {
    my $controlnumber = shift;

    my $controlcode_length = scalar @controlcifers;

    if ( not $controlnumber ) {
        _argument($controlcode_length);
    }
    _content($controlnumber);
    _length( $controlnumber, $controlcode_length );

    return 1;
}

sub _checkdate {
    my $birthdate = shift;

    if ( not $birthdate ) {
        croak 'argument for birthdate should be provided';
    }

    if (not($birthdate =~ m{^ #beginning of line
              (\d{2}) #day of month, 2 digit representation, 01-31
              (\d{2}) #month, 2 digit representation jan 01 - dec 12
              (\d{2}) #year, 2 digit representation
              $ #end of line
              }xm
        )
        )
    {
        croak "argument: $birthdate could not be parsed";
    }

    if ( not check_date( $3, $2, $1 ) ) {
        croak
            "argument: $birthdate has to be a valid date in the following format: ddmmyy";
    }
    return 1;
}

sub generate {
    my $birthdate = shift;
    my $sex = shift || undef;

    _assert_date($birthdate);

    my @cprs;
    my %seeds;

    if ( defined $sex ) {
        if ( $sex eq 'male' ) {
            %seeds = %male_seeds;
        } elsif ( $sex eq 'female' ) {
            %seeds = %female_seeds;
        } else {
            carp("Unknown sex: $sex, assuming no sex");
            $sex = undef;
        }
    }

    if ( not $sex ) {
        %seeds = %{ merge( \%female_seeds, \%male_seeds ) };
    }

    foreach my $seed ( keys %seeds ) {
        my $s = $seed;
        while ( $s < $seeds{$seed} ) {
            $s += 6;
            push @cprs, ( $birthdate . sprintf '%04d', $s );
        }
    }

    if (wantarray) {
        return @cprs;
    } else {
        return scalar @cprs;
    }
}

1;

__END__

=head1 NAME

Business::DK::CPR - a Danish CPR code generator/validator

=head1 VERSION

This documentation describes version 0.04

=head1 SYNOPSIS

    use Business::DK::CPR qw(validate);

    my $rv;
    eval { $rv = validate(1501721111); };

    if ($@) {
        die "Code is not of the expected format - $@";
    }

    if ($rv) {
        print 'CPR is valid';
    } else {
        print 'CPR is not valid';
    }

    use Business::DK::CPR qw(calculate);

    my @cprs = calculate(150172);

    my $number_of_valid_cprs = calculate(150172);


=head1 DESCRIPTION

CPR stands for Central Person Registration and it the social security number used in Denmark.

=head1 SUBROUTINES AND METHODS

=head2 validate

This function checks a CPR number for validity. It takes a CPR number as argument and returns 1 (true) for valid and 0 (false) for invalid.

It dies if the CPR number is malformed or in any way unparsable, be aware that the 6 first digits are representing a date (SEE: L</_checkdate> function below). The date indicate the person's birthday, the last 4 digits are representing a serial number and a control cifer.

L</validate1968> is the old form of CPR number. It is validated using modulus 11.

The new format introduced in 2001 can be validated using L</validate2001>.

The L</validate> subroutine wraps both validators and checks using against both.

NB! it is possible to make fake CPR number, which appear valid, please see MOTIVATION and the L</calculate> function. 

L</validate> is also exported as: L</validateCPR>.

=head2 validateCPR

Better name for export. This is just a wrapper for L</validate>

=head2 validate1968

=head2 validate2001

=head2 generate

This is a wrapper around calculate, so the naming is uniform to
L<Business::DK::CVR>

=head2 calculate

This function takes an integer representing a date and calculates valid CPR numbers for the specified date. In scalar context returns the number of valid CPR numbers possible and in list context a list of valid CPR numbers.

If the date is malformed or in any way invalid or unspecified the function dies.

=head1 PRIVATE FUNCTIONS

=head2 _assertdate

This subroutine takes a digit integer representing a date in the format: DDMMYY.

The date is checked for definedness, contents and length and finally, the correctness of the date.

The subroutine returns 1 indicating true upon successful assertion or
dies upon failure.

=head2 _checkdate

This subroutine takes a digit integer representing a date in the format: DDMMYY.

The subroutine returns 1 indicating true upon successful check or
dies upon failure.

=head2 _assert_controlnumber

This subroutine takes an 10 digit integer representing a CPR. The CPR is tested for definedness, contents and length.

The subroutine returns 1 indicating true upon successful assertion or
dies upon failure.

=head1 EXPORTS

Business::DK::CPR exports on request:

=over

=item validate

=item validateCPR

=item validate1968

=item validate2001

=item calculate

=item generate

=item _checkdate

=back

=head1 DIAGNOSTICS

=head1 DEPENDENCIES

=over

=item L<Business::DK::PO>

=item L<Business::DK::CVR>

=back

=head1 CONFIGURATION AND ENVIRONMENT

=head1 INCOMPATIBILITIES

=head1 TODO

=over

=item Nothing to do, please refer to the distribution TODO file

=back

=head1 TEST AND QUALITY

Coverage of the test suite is at 100%

---------------------------- ------ ------ ------ ------ ------ ------ ------
File                           stmt   bran   cond    sub    pod   time  total
---------------------------- ------ ------ ------ ------ ------ ------ ------
blib/lib/Business/DK/CPR.pm   100.0  100.0  100.0  100.0  100.0  100.0  100.0
Total                         100.0  100.0  100.0  100.0  100.0  100.0  100.0
---------------------------- ------ ------ ------ ------ ------ ------ ------

=head1 BUGS AND LIMITATIONS

No known bugs at this time. No known limitations apart from the obvious ones
in the CPR system.

=head1 BUG REPORTING

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

I write business related applications. So I need to be able to validate CPR numbers once is a while, hence the validation function.

The calculate function is however a different story. When I was in school we where programming in Comal80 and some of the guys in my school created lists of CPR numbers valid with their own birthdays. The thing was that if you got caught riding the train without a valid ticket the personnel would only check the validity of you CPR number, so all you have to remember was your birthday and 4 more digits not being the actual last 4 digits of your CPR number.

I guess this was the first hack I ever heard about and saw - I never tried it out, but back then it really fascinated me and my interest in computers was really sparked.

=head1 AUTHOR

Jonas B. Nielsen, (jonasbn) - C<< <jonasbn@cpan.org> >>

=head1 COPYRIGHT

Business-DK-CPR is (C) by Jonas B. Nielsen, (jonasbn) 2006-2008

=head1 LICENSE

Business-DK-CPR is released under the artistic license

The distribution is licensed under the Artistic License, as specified
by the Artistic file in the standard perl distribution
(http://www.perl.com/language/misc/Artistic.html).

=cut
