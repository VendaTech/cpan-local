package CPAN::Local::Plugin;

# ABSTRACT: Base class for plugins

use strict;
use warnings;

use Moose;
with 'MooseX::Role::Loggable';
use namespace::clean -except => 'meta';

has 'root' =>
(
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'distribution_class' =>
(
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

sub create_distribution
{
    my $self = shift;
    return $self->distribution_class->new(@_);
}

sub requires_distribution_roles
{
    return;
}

__PACKAGE__->meta->make_immutable;
