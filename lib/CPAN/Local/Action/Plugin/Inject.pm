package CPAN::Local::Action::Plugin::Inject;

use strict;
use warnings;

use Path::Class qw(file dir);
use File::Path;
use File::Copy;
use Dist::Metadata;
use CPAN::Local::Util;

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
        my $distro_path = CPAN::Local::Util::calculate_dist_path(
            authorid => $distro->{authorid},
            filename => $distro->{filename},
        );

        my $path = file( $self->root, $distro_path )->dir;
        $path->mkpath;

        ### COPY DISTRIBUTION ###
        my $filename = file($distro->{filename})->basename;
        my $filepath = file( $path, $filename );
        File::Copy::copy( $distro->{filename}, $filepath->stringify ) or warn $!;

        $distro->{filename} = $filepath->stringify;
        $distro->{path} = $path->stringify;

        $distro->{meta} = Dist::Metadata->new(
            file => $distro->{filename}
        )->meta;

        push @injected, $distro;
    }

    return @injected;
}



__PACKAGE__->meta->make_immutable;
