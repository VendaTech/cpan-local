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
        my $path = file( $self->root, $distro->path )->dir;
        $path->mkpath;

        my $injected_filename = file(
			$path, file($distro->filename)->basename
		)->stringify;
        
		unless ( File::Copy::copy( $distro->filename, $injected_filename ) )
		{
			$self->log($!);
			next;
		}
		
        my $provides = Dist::Metadata->new(
            file => $injected_filename
        )->meta->provides;

		my %provides = { $_ => $provides->{$_}{version} } keys %$provides;

        unless ( %provides )
        {
            my $distnameinfo = CPAN::DistnameInfo->new(
                file($distro->filename)->basename
            );
            
            my ($fake_package = $distnameinfo->dist) =~ s/-/::/;

            $provides{$fake_package} = $distnameinfo->version;
        }

        push @injected, CPAN::Local::Distribution->new(
			filename => $injected_filename,
			authorid => $distro->authorid,
			provides => \%provides,
		);
    }

    return @injected;
}



__PACKAGE__->meta->make_immutable;
