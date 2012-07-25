package CPAN::Local::Distribution::Role::Metadata;

use strict;
use warnings;

use Dist::Metadata;
use Moose::Role;

has metadata => ( is => 'ro', isa => 'CPAN::Meta', lazy_build => 1 );

sub _build_metadata
{
    my $self = shift;
    return Dist::Metadata->new( file => $self->filename )->meta;
}

1;
