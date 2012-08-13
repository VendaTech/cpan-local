package CPAN::Local::Distribution::Role::Metadata;

# ABSTRACT: Read a distribution's metadata

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

=pod

=head1 ATTRIBUTES

=head2 metadata

L<CPAN::Meta> object representing the distribution's metadata.

=cut
