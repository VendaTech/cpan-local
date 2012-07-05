package CPAN::Local::Action::Plugin::Mirror;

use strict;
use warnings;

use CPAN::Local::Distribution;
use CPAN::Index::API;
use Path::Class qw(file);

use Moose;
extends 'CPAN::Local::Action::Plugin';
with 'CPAN::Local::Action::Role::Gather';
use namespace::clean -except => 'meta';

has uri => 
(
	is       => 'ro',
	isa      => 'Str',
    required => 1,
);

has cache => 
(
	is        => 'ro',
	isa       => 'Str',
    predicate => 'has_cache',
);

sub gather
{
	my $self = shift;

    my @distros;

    my $index = CPAN::Index::API->new_from_uri( $self->uri );

    foreach my $distro ( $index->distribution_list )
    {
        # find out if it already exists in our repo
        next if -e file( $self->repo, $distro->path );

        # determine uri for the distro
        my $distro_uri = _expand_distro_uri( $self->uri, $distro->path );

        # add to list
        my %args = ( uri => $distro_uri );
        $args{cache} = $self->cache if $self->has_cache;
        push @distros, $self->distribution_class->new( %args );
    }

    return @distros;
}

sub _expand_distro_uri {
    my ( $repo_uri, $distro_path ) = @_;

    my $distro_uri  = URI->new( $repo_uri );
    my $distro_file = file( $distro_path );
    
    my @existing_segments = $distro_uri->path_segments;
    my @distro_segments   = ( $distro_file->dir->dir_list, $distro_file->basename );
    
    $distro_uri->path_segments( @existing_segments, @distro_segments );

    return $distro_uri->as_string;
}

__PACKAGE__->meta->make_immutable;
