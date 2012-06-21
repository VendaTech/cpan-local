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

sub gather
{
	my $self = shift;

    my @distros;

    my $index = CPAN::Index::API->new_from_uri($self->uri);

    foreach my $distro ( $index->distribution_list )
    {
        # find out if it already exists in our repo
        next if -e file($self->repo, $distro_path);

        # determine uri for the distro
        my $dist_uri = URI->new($self->uri);
        my @existing_segments = $dist_uri->path_segments;
        my $distro_path = file($distro->path);
        my @distro_segments = ($distro_path->dir->dir_list, $distro_path->basename);
        $dist_uri->path_segments(@existing_segments, @distro_segments);
        
        # add to list
        push @distros, CPAN::Local::Distribution->new_from_uri($dist_uri->as_string);
    }

    return @distros;
}

__PACKAGE__->meta->make_immutable;
