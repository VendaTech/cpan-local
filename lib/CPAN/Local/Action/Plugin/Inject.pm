package CPAN::Local::Action::Plugin::Inject;

use strict;
use warnings;

use Path::Class qw(file dir);
use File::Path;
use File::Copy;
use Dist::Metadata;
use CPAN::Local::Distribution;

use Moose;
extends 'CPAN::Local::Action::Plugin';
with 'CPAN::Local::Action::Role::Inject';
use namespace::clean -except => 'meta';

has config => 
(
	is        => 'ro',
	isa       => 'Str',
	predicate => 'has_config',
);

sub inject
{
    my ( $self, @distros ) = @_;

    my @injected;

    foreach my $distro (@distros)
    {
        ### CREATE AUTHOR DIRECTORY ###
        my $authordir = file( $self->root, $distro->path )->dir;
        $authordir->mkpath;

        ### COPY DISTRIBUTION ###
        my $new_filepath = file( $authordir, file( $distro->filename )->basename )->stringify;

        if ( File::Copy::copy( $distro->filename, $new_filepath ) )
        {
            push @injected, CPAN::Local::Distribution->new(
                filename => $new_filepath,
                authorid => $distro->authorid,
                path     => $distro->path,
            );
        }
        else
        {
			$self->log($!);
			next;
        }
    }

    return @injected;
}

__PACKAGE__->meta->make_immutable;
