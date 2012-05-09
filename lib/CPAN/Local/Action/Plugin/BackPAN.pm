package CPAN::Local::Action::Plugin::BackPAN;

use strict;
use warnings;

use CPAN::Index::API;
use File::Path qw(make_path);
use Path::Class qw(file dir);
use File::Temp;
use URI;
use LWP::Simple;
use CPAN::DistnameInfo;

use Moose;
with 'CPAN::Local::Action::Role::Gather';
use namespace::clean -except => 'meta';

has config => 
(
	is        => 'ro',
	isa       => 'Str',
	predicate => 'has_config',
);

has distros =>
(
	is         => 'ro',
	isa        => 'ArrayRef',
	lazy_build => 1,
	traits     => ['Array'],
	handles    => { distro_list => 'elements' },
);

has remote => 
(
	is      => 'ro',
	isa     => 'Str',
	default => 'http://backpan.perl.org/'
);

has cache => 
(
	is         => 'ro',
	isa        => 'Str',
	lazy_build => 1,
);

sub _build_distros
{
	my $self = shift;

	my @distros;

	if ( $self->has_config )
	{
		foreach my $line ( file( $self->config )->slurp )
		{
			chomp $line;
			my $distro = CPAN::DistnameInfo->new($line);
			push @distros, $distro;
		}
	}

	return \@distros;
}

sub _build_cache 
{
    return File::Temp::tempdir( CLEANUP => 0 );
}

sub gather
{
	my ($self, @distros) = @_;

	foreach my $distro ( $self->distro_list )
	{
       my $path = file($self->cache, $distro->filename);
        
        unless ( -e $path ) {	
			my $uri = URI->new( $self->remote );
			$uri->path( $distro->pathname );
            my $rc = LWP::Simple::getstore($uri->as_string, $path->stringify);
            
            if ( LWP::Simple::is_error($rc) ) {
                warn "Error fetching " . $uri->as_string;
                next;
            }
        }

		push @distros, { filename => $path, authorid => $distro->cpanid };
	}

	return @distros;
}

__PACKAGE__->meta->make_immutable;

1;
