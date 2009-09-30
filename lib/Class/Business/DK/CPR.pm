package Class::Business::DK::CPR;

# $Id$

use strict;
use warnings;
use Class::InsideOut qw( private register id );
use Carp qw(croak);
use English qw(-no_match_vars);

use Business::DK::CPR qw(validate);

private number => my %number;     # read-only accessor: number()

sub new {
    my ($class, $number) = @_;
    
    my $self = \( my $scalar );
    
    bless $self, $class;
    
    register( $self );
    
    if ($number) {
        $self->set_number($number);
    } else {
        croak 'You must provide a CPR number';
    }

    return $self;
}

sub number { $number{ id $_[0] } }

sub get_number { $number{ id $_[0] } }

sub set_number {
    
    if ($_[1]) {
        eval { validate($_[1]) };
    
        if ($EVAL_ERROR) {
            croak 'Invalid CPR number parameter';
        } else {
            $number{ id $_[0] } = $_[1];
            return 1;
        }
    } else {
        croak 'You must provide a CPR number';
    }
}

1;