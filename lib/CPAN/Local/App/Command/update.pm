package CPAN::Local::App::Command::update;

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
		@distros = $plugin->gather(@distros);
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
}

__PACKAGE__->meta->make_immutable;
