package CPAN::Local::App::Command::update;

# ABSTRACT: Update repository

use Moose;
extends 'MooseX::App::Cmd::Command';

sub execute
{
    my ( $self, $opt, $args ) = @_;

    my $cpan_local = $self->app->cpan_local;

    my @distros;

    ### COLLECT DISTRIBUTIONS TO INJECT ###
    foreach my $plugin ( $cpan_local->plugins_with('-Gather') )
    {
        push @distros, $plugin->gather(@distros);
    }

    ### REMOVE DUPLICATES, ETC. ###
    foreach my $plugin ( $cpan_local->plugins_with('-Prune') )
    {
        @distros = $plugin->prune(@distros);
    }

    ### INJECT ###
    foreach my $plugin ( $cpan_local->plugins_with('-Inject') )
    {
        @distros = $plugin->inject(@distros);
    }

    ### WRITE RELEVANT INDECES ###
    foreach my $plugin ( $cpan_local->plugins_with('-Index') )
    {
        $plugin->index(@distros);
    }

    ### EXECUTE POST-UPDATE ACTIONS ###
    foreach my $plugin ( $cpan_local->plugins_with('-Finalise') )
    {
        $plugin->finalise(@distros);
    }
}

__PACKAGE__->meta->make_immutable;

=pod

=head1 SYNOPSIS

  % lpan update

=head1 DESCRIPTION

Update the repository in the current directory.

=cut
