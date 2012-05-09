package CPAN::Local::App::Command::init;

use Moose;
extends 'MooseX::App::Cmd::Command';
use namespace::clean -except => 'meta';

sub execute
{
	my ( $self, $opt, $args ) = @_;
    $_->initialise for $self->app->cpan_local->plugins_with('-Initialise');
}

__PACKAGE__->meta->make_immutable;
