package CPAN::Local::Action::Plugin::Inject;

use strict;
use warnings;

use Path::Class qw(file dir);
use File::Path;
use File::Copy;
use Dist::Metadata;
use CPAN::Local::Util;
use CPAN::Local::Distribution;

use Moose;
with 'CPAN::Local::Action::Role::Inject';
use namespace::clean -except => 'meta';

has config => 
(
	is        => 'ro',
	isa       => 'Str',
	predicate => 'has_config',
);

has root =>
(
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

sub inject
{
    my ( $self, @distros ) = @_;

    my @injected;

    foreach my $distro (@distros)
    {
        ### CREATE AUTHOR DIRECTORY ###
        my $path = file( $self->root, $distro->path )->dir;
        $path->mkpath;

        ### COPY DISTRIBUTION ###
        my $new_filepath = file( $path, file( $distro->filename )->basename )->stringify;

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
            warn $!;
        }
    }

    return @injected;
}



__PACKAGE__->meta->make_immutable;
