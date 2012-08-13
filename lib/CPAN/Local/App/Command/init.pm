package CPAN::Local::App::Command::init;

# ABSTRACT: Initialize an empty repository

use Moose;
extends 'MooseX::App::Cmd::Command';
use namespace::clean -except => 'meta';

sub execute
{
    my ( $self, $opt, $args ) = @_;
    $_->initialise for $self->app->cpan_local->plugins_with('-Initialise');
}

__PACKAGE__->meta->make_immutable;

=pod

=head1 SYNOPSIS

  % lpan init

=head1 DESCRIPTION

Initiate a new repository in the current directory.

=cut
