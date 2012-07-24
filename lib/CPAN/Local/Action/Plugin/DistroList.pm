package CPAN::Local::Action::Plugin::DistroList;

use strict;
use warnings;

use File::Path qw(make_path);
use Path::Class qw(file dir);
use File::Temp;
use URI;
use Try::Tiny;
use LWP::Simple;
use CPAN::DistnameInfo;

use Moose;
extends 'CPAN::Local::Action::Plugin';
with 'CPAN::Local::Action::Role::Gather';
use namespace::clean -except => 'meta';

has list => 
(
	is        => 'ro',
	isa       => 'Str',
	predicate => 'has_list',
);

has prefix => 
(
	is      => 'ro',
	isa     => 'Str',
	default => '',
);

has uris =>
(
	is         => 'ro',
	isa        => 'ArrayRef',
	lazy_build => 1,
	traits     => ['Array'],
	handles    => { uri_list => 'elements' },
);

has cache => 
(
	is         => 'ro',
	isa        => 'Str',
	lazy_build => 1,
);

has authorid =>
(
	is        => 'ro',
	isa       => 'Str',
	predicate => 'has_authorid',
);

has local => 
(
	is         => 'ro',
	isa        => 'Bool',
);

sub _build_uris
{
	my $self = shift;

    my $prefix = $self->prefix;
	
    my @uris;

	if ( $self->has_list )
	{
		foreach my $line ( file( $self->list )->slurp )
		{
			chomp $line;
			push @uris, $prefix . $line;
		}
	}

	return \@uris;
}

sub _build_cache 
{
    return File::Temp::tempdir( CLEANUP => 1 );
}

sub gather
{
	my $self = shift;

    my @distros;

	foreach my $uri ( $self->uri_list )
	{
        my %args = $self->local
            ? ( filename => $uri )
            : ( uri => $uri, cache => $self->cache );

        $args{authorid} = $self->authorid if $self->has_authorid;
        my $distro = 
            try   { $self->create_distribution(%args) }
            catch { $self->log($_) };
        
        push @distros, $distro if $distro;
    }

	return @distros;
}

__PACKAGE__->meta->make_immutable;
