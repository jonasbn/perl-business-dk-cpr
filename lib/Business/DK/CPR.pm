package Business::DK::CPR;

# $Id: CPR.pm,v 1.9 2008-09-09 19:15:44 jonasbn Exp $

use strict;
use warnings;
use vars qw($VERSION @EXPORT_OK);
use Carp qw(croak carp);
use Business::DK::CVR qw(_length _calculate_sum);
use Business::DK::PO qw(_argument _content);
use Date::Calc qw(check_date);
use base 'Exporter';
use integer;
use Tie::IxHash;

$VERSION   = '0.07';
@EXPORT_OK = qw(
    validate
    validateCPR
    generate
    validate1968
    generate1968
    validate2007
    generate2007
    calculate
    _checkdate
);

use constant MODULUS_OPERAND_1968 => 11;
use constant MODULUS_OPERAND_2007 => 6;
use constant DATE_LENGTH          => 6;
use constant VALID                => 1;
use constant VALID_MALE           => 1;
use constant VALID_FEMALE         => 2;
use constant INVALID              => 0;
use constant FEMALE               => 'female';
use constant MALE                 => 'male';

my @controlcifers = qw(4 3 2 7 6 5 4 3 2 1);

my %female_seeds;
tie %female_seeds, 'Tie::IxHash',
    4 => { max => 9994, min => 10 },
    2 => { max => 9998, min => 8 },
    6 => { max => 9996, min => 12 };

my %male_seeds;
tie %male_seeds, 'Tie::IxHash',
    1 => { max => 9997, min => 7 },
    3 => { max => 9999, min => 9 },
    5 => { max => 9995, min => 11 };

sub merge {
    my ( $left_hashref, $right_hashref ) = @_;

    my %hash = %{$right_hashref};

    foreach ( keys %{$left_hashref} ) {
        $hash{$_} = $left_hashref->{$_};
    }

    return \%hash;
}

sub calculate {
    my $birthdate = shift;

    _assert_date($birthdate);

    my @cprs;
    for ( 1 .. 999 ) {
        my $n = sprintf '%03s', $_;

        my $sum = _calculate_sum( ( $birthdate . $n ), \@controlcifers );
        my $mod = $sum % MODULUS_OPERAND_1968;

        my $checkciffer = ( MODULUS_OPERAND_1968 - $mod );

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

    return VALID;
}

sub validateCPR {
    return validate(shift);
}

sub validate {
    my $controlnumber = shift;

    my $rv;
    if ( $rv = validate1968($controlnumber) ) {
        return $rv;
    } else {
        return validate2007($controlnumber);
    }
}

sub validate2007 {
    my $controlnumber = shift;

    _assert_date( substr $controlnumber, 0, DATE_LENGTH );

    _assert_controlnumber($controlnumber);

    my $control = substr $controlnumber, DATE_LENGTH, 4;

    my $remainder = $control % MODULUS_OPERAND_2007;

    my %seeds = %{ merge( \%male_seeds, \%female_seeds ) };

    if ( my $series = $seeds{$remainder} ) {
        if ( $control < $seeds{$remainder}->{min} ) {
            return INVALID;
        } elsif ( $control > $seeds{$remainder}->{max} ) {
            return INVALID;
        }
    } elsif ( ( $control == 0 or $control == 6 ) && $remainder == 0 ) {
        return INVALID;
    }

    if ( $female_seeds{$remainder} ) {
        return VALID_FEMALE;
    } elsif ( $male_seeds{$remainder} ) {
        return VALID_MALE;
    } elsif ( $remainder == 0 ) {
        if ( _is_equal($control) ) {
            return VALID_FEMALE;
        } else {
            return VALID_MALE;
        }
    } else {
        return INVALID;
    }
}

sub validate1968 {
    my $controlnumber = shift;

    _assert_date( substr $controlnumber, 0, DATE_LENGTH );
    _assert_controlnumber($controlnumber);

    my $sum = _calculate_sum( $controlnumber, \@controlcifers );

    #Note this might look like it is turned upside down but no rest from the
    #modulus calculation indicated validity
    if ( $sum % MODULUS_OPERAND_1968 ) {
        return INVALID;
    } else {
        if ( _is_equal($sum) ) {
            return VALID_MALE;
        } else {
            return VALID_FEMALE;
        }
    }
}

sub _is_equal {
    my $operand = shift;

    return ( not( $operand % 2 ) );
}

sub _assert_controlnumber {
    my $controlnumber = shift;

    my $controlcode_length = scalar @controlcifers;

    if ( not $controlnumber ) {
        _argument($controlcode_length);
    }
    _content($controlnumber);
    _length( $controlnumber, $controlcode_length );

    return VALID;
}

sub _checkdate {
    my $birthdate = shift;

    if ( not $birthdate ) {
        croak 'argument for birthdate should be provided';
    }

    if (not($birthdate =~ m{\A #beginning of line
              (\d{2}) #day of month, 2 digit representation, 01-31
              (\d{2}) #month, 2 digit representation jan 01 - dec 12
              (\d{2}) #year, 2 digit representation
              \Z #end of line
              }xsm
        )
        )
    {
        croak "argument: $birthdate could not be parsed";
    }

    if ( not check_date( $3, $2, $1 ) ) {
        croak
            "argument: $birthdate has to be a valid date in the format: ddmmyy";
    }
    return VALID;
}

sub generate {
    my ( $birthdate, $gender ) = @_;

    my %cprs;

    my @cprs1968 = generate1968( $birthdate, $gender );
    my @cprs2007 = generate2007( $birthdate, $gender );

    %cprs = map { $_ => 1 } @cprs1968;
    %cprs = map { $_ => 1 } @cprs2007;

    if (wantarray) {
        return keys %cprs;
    } else {
        return scalar keys %cprs;
    }
}

sub generate2007 {
    my $birthdate = shift;
    my $gender = shift || undef;

    _assert_date($birthdate);

    my @cprs;
    my %seeds;

    if ( defined $gender ) {
        if ( $gender eq MALE ) {
            %seeds = %male_seeds;
        } elsif ( $gender eq FEMALE ) {
            %seeds = %female_seeds;
        } else {
            carp("Unknown gender: $gender, assuming no gender");
            $gender = undef;
        }
    }

    if ( not $gender ) {
        %seeds = %{ merge( \%female_seeds, \%male_seeds ) };
    }

    foreach my $seed ( keys %seeds ) {
        my $s = $seeds{$seed}->{min};
        while ( $s < $seeds{$seed}->{max} ) {
            $s += MODULUS_OPERAND_2007;
            push @cprs, ( $birthdate . sprintf '%04d', $s );
        }
    }

    if (wantarray) {
        return @cprs;
    } else {
        return scalar @cprs;
    }
}

sub generate1968 {
    my $birthdate = shift;
    my $gender = shift || undef;

    _assert_date($birthdate);

    my @cprs;
    my @malecprs;
    my @femalecprs;

    my $checksum = 0;

    while ( $checksum < 9999 ) {

        my $cpr = $birthdate . sprintf '%04d', $checksum;

        if ( my $rv = validate1968($cpr) ) {

            if ( defined $gender and $rv ) {
                if ( $rv == VALID_MALE ) {
                    push @malecprs, $cpr;
                } elsif ( $rv == VALID_FEMALE ) {
                    push @femalecprs, $cpr;
                }

            } else {
                push @cprs, $cpr;
            }
        }
        $checksum++;
    }

    if ( $gender eq FEMALE ) {
        @cprs = @femalecprs;
    } elsif ( $gender eq MALE ) {
        @cprs = @malecprs;
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

Business::DK::CPR - Danish CPR code generator/validator

=head1 VERSION

This documentation describes version 0.06

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


    #Using with Params::Validate
    #See also examples/
    
    use Params::Validate qw(:all);
    use Business::DK::CPR qw(validateCPR);
        
    sub check_cpr {
        validate( @_,
        { cpr =>
            { callbacks =>
                { 'validate_cpr' => sub { validateCPR($_[0]); } } } } );
        
        print $_[1]." is a valid CPR\n";
    
    }

=head1 DESCRIPTION

CPR stands for Central Person Registration and is the social security number
used in Denmark.

=head1 SUBROUTINES AND METHODS

All methods are exported by explicit request. None are exported implicitly.

=head2 validate

This function checks a CPR number for validity. It takes a CPR number as
argument and returns:

=over

=item * 1 (true) for valid male CPR number

=item * 2 (true) for a valid female CPR number

=item * 0 (false) for invalid CPR number

=back

It dies if the CPR number is malformed or in any way unparsable, be aware that
the 6 first digits are representing a date (SEE: L</_checkdate> function below).

In brief, the date indicate the person's birthday, the last 4 digits are
representing a serial number and control cipher.

For a more thorough discussion on the format of CPR numbers please refer to the
L<SEE ALSO> section.

L</validate1968> is the old form of the CPR number. It is validated using
modulus 11.

The new format introduced in 2001 (put to use in 2007, hence the name used
throughout this package) can be validated using L</validate2007> and generate
using L</validate2007>.

The L</validate> subroutine wraps both validators and checks using against both.

The L</generate> subroutine wraps both generators and accumulated the results.

NB! it is possible to make fake CPR numbers that appear valid, please see
MOTIVATION and the L</calculate> function.

L</validate> is also exported as: L</validateCPR>, which is less imposing.

=head2 validateCPR

Better name for export. This is just a wrapper for L</validate>

=head2 validate1968

Validation against the original CPR algorithm introduced in 1968.

=head2 validate2007

Validation against the CPR algorithm introduced in 2007.

=head2 generate

This is a wrapper around calculate, so the naming is uniform to
L<Business::DK::CVR>

This function takes an integer representing a date and calculates valid CPR
numbers for the specified date. In scalar context returns the number of valid
CPR numbers possible and in list context a list of valid CPR numbers.

If the date is malformed or in any way invalid or unspecified the function dies.

=head2 generate1968

Specialized generator for validate1968 compatible CPR numbers. See: L</generate>

=head2 generate2007

Specialized generator for validate2007 compatible CPR numbers. See: L</generate>

=head2 calculate

See L</generate> and L</generate1968>. This is the old name for L</generate1968>.
It is just kept for backwards compatibility and it calls L</generate>.

=head2 merge

Mimics L<Hash::Merge>'s L<Hash::Merge/merge> function. Takes two references to
hashes and returns a single reference to a hash containing the merge of the two
with the left parameter having precendence. The precedence has not meaning on
the case in this module, but then the behaviour is documented.

=head1 PRIVATE FUNCTIONS

=head2 _assertdate

This subroutine takes a digit integer representing a date in the format: DDMMYY.

The date is checked for definedness, contents and length and finally, the
correctness of the date.

The subroutine returns 1 indicating true upon successful assertion or
dies upon failure.

=head2 _checkdate

This subroutine takes a digit integer representing a date in the format: DDMMYY.

The subroutine returns 1 indicating true upon successful check or
dies upon failure.

=head2 _assert_controlnumber

This subroutine takes an 10 digit integer representing a CPR. The CPR is tested
for definedness, contents and length.

The subroutine returns 1 indicating true upon successful assertion or
dies upon failure.

=head1 EXPORTS

Business::DK::CPR exports on request:

=over

=item * L</validate>

=item * L</validateCPR>

=item * L</validate1968>

=item * L</validate2007>

=item * L</calculate>

=item * L</generate>

=item * L</_checkdate>

=back

=head1 DIAGNOSTICS

=over

=item * 'argument for birthdate should be provided', a data parameter has to be
provided. 

This error is thrown from L</_checkdate>, which is used for all general parameter
validation.

=item * 'argument: <birthdate> could not be parsed', the date provided is not
represented by 6 digits (see also below).

This error is thrown from L</_checkdate>, which is used for all general parameter
validation.

=item * 'argument: <birthdate> has to be a valid date in the format: ddmmyy',
the date format used for CPR numbers has to adhere to ddmmyy in numeric format
like so: 311210, day in a two digit representation: 01-31, month also two digit
representation: 01-12 and finally year in a two digit representation: 00-99.

This error is thrown from L</_checkdate>, which is used for all general parameter
validation.

=item * 'Unknown gender: <gender>, assuming no gender', this is just a warning
issued if a call to L</generate2007> has not been provided with a gender
parameter

=back

=head1 DEPENDENCIES

=over

=item * L<Business::DK::PO>

=item * L<Business::DK::CVR>

=item * L<Exporter>

=item * L<Carp>

=item * L<Test::Exception>

=item * L<Date::Calc>

=item * L<Tie::IxHash>

=back

=head1 CONFIGURATION AND ENVIRONMENT

This module requires no special configuration or environment.

=head1 INCOMPATIBILITIES

There are no known incompatibilies in this package.

=head1 TODO

=over

=item * Nothing to do, please refer to the distribution TODO file for the general
wish list and ideas for future expansions and experiments.

=back

=head1 TEST AND QUALITY

The distribution uses the TEST_AUTHOR environment variable to run some
additional tests, which are interesting to the the author, these can be disabled
by not defining or setting the environment variable to something not positive.

=head2 TESTCOVERAGE

Coverage of the test suite is at 89.1% for release 0.04, the coverage report
was generated with the TEST_AUTHOR flag enabled (SEE: L</TEST AND QUALITY>)

    ---------------------------- ------ ------ ------ ------ ------ ------ ------
    File                           stmt   bran   cond    sub    pod   time  total
    ---------------------------- ------ ------ ------ ------ ------ ------ ------
    blib/lib/Business/DK/CPR.pm    74.2   41.9   53.8  100.0  100.0   72.9   70.3
    .../Class/Business/DK/CPR.pm   89.1   85.7   77.8   71.4  100.0   27.1   86.0
    Total                          77.6   50.0   63.6   91.3  100.0  100.0   74.1
    ---------------------------- ------ ------ ------ ------ ------ ------ ------

=head2 PERL::CRITIC

This section describes use of L<Perl::Critic> from a perspective of documenting
additions and exceptions to the standard use.

=over

=item * L<Perl::Critic::Policy::Miscellanea::ProhibitTies>

This package utilizes L<Tie::IxHash> (SEE: L</DEPENDENCIES>), this module
relies on tie.

=item * L<Perl::Critic::Policy::NamingConventions::NamingConventions::Capitalization>

CPR is an abreviation for 'Centrale Person Register' (Central Person Register)
and it is kept in uppercase.

Used to be: L<Perl::Critic::Policy::NamingConventions::ProhibitMixedCaseSubs>

=item * L<Perl::Critic::Policy::ValuesAndExpressions::ProhibitConstantPragma>

Constants are good in most cases, see also:
L<http://logicLAB.jira.com/wiki/display/OPEN/Perl-Critic-Policy-ValuesAndExpressions-ProhibitConstantPragma>

=item * L<Perl::Critic::Policy::ValuesAndExpressions::ProhibitMagicNumbers>

Some values and boundaries are defined for certain intervals of numbers, these
are currently kept as is. Perhaps with a refactoring of the use of constants to
use of L<Readonly> will address this.

=back

=head1 BUGS AND LIMITATIONS

No known bugs at this time.

Business::DK::CPR has some obvious flaws. The package can only check for
validity and format, whether a given CPR has been generated by some random
computer program and just resemble a CPR or whether a CPR has ever been assigned
to a person is not possible without access to central CPR database an access,
which is costly, limited and monitored.

There are no other known limitations apart from the obvious flaws in the CPR
system (See: L</SEE ALSO>).

=head1 BUG REPORTING

Please report issues via CPAN RT:

  http://rt.cpan.org/NoAuth/Bugs.html?Dist=Business-DK-CPR

or by sending mail to

  bug-Business-DK-CPR@rt.cpan.org

=head1 SEE ALSO

=over

=item * L<http://www.cpr.dk/>

=item * L<Class::Business::DK::CPR>

=item * L<Data::FormValidator::Constraints::Business::DK::CPR>

=item * L<Business::DK::PO>

=item * L<Business::DK::CVR>

=item * L<http://logicLAB.jira.com/wiki/display/OPEN/Perl-Critic-Policy-ValuesAndExpressions-ProhibitConstantPragma>

=back

=head1 MOTIVATION

I write business related applications. So I need to be able to validate CPR
numbers once is a while, hence the validation function.

The calculate/generate1968 function is however a different story. When I was in
school we where programming in Comal80 and some of the guys in my school created
lists of CPR numbers valid with their own birthdays. The thing was that if you
got caught riding the train without a valid ticket the personnel would only
check the validity of you CPR number, so all you have to remember was your
birthday and 4 more digits not being the actual last 4 digits of your CPR
number.

I guess this was the first hack I ever heard about and saw - I never tried it
out, but back then it really fascinated me and my interest in computers was
really sparked.

=head1 AUTHOR

Jonas B. Nielsen, (jonasbn) - C<< <jonasbn@cpan.org> >>

=head1 COPYRIGHT

Business-DK-CPR is (C) by Jonas B. Nielsen, (jonasbn) 2006-2010

=head1 LICENSE

Business-DK-CPR is released under the artistic license

The distribution is licensed under the Artistic License, as specified
by the Artistic file in the standard perl distribution
(http://www.perl.com/language/misc/Artistic.html).

=cut
