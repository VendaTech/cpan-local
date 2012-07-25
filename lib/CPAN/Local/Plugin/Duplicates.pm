package CPAN::Local::Plugin::Duplicates;

use strict;
use warnings;

use Moose;
extends 'CPAN::Local::Plugin';
with 'CPAN::Local::Role::Clean';
use namespace::clean -except => 'meta';

sub clean
{
	my ( $self, @distros ) = @_;
    
    my (%paths, @cleaned);

    foreach my $distro ( @distros )
    {
        next if $paths{$distro->path}++;
        push @cleaned, $distro;
    }

    return @cleaned;
}

__PACKAGE__->meta->make_immutable;
