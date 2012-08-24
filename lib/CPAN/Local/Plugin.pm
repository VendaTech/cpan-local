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

=pod

=head1 ATTRIBUTES

=head2 root

Repository root.

=head2 distribution_class

Base class for distribution objects.

=head1 METHODS

=head2 requires_distribution_roles

Empty class method. If overriden in a subclass should return a list of
distribution roles required by the respective plugin.

=cut
