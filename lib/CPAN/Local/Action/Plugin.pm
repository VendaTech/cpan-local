package CPAN::Local::Action::Plugin;

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
    is      => 'ro',
    isa     => 'Str',
    default => 'CPAN::Local::Distribution',
);

__PACKAGE__->meta->make_immutable;
