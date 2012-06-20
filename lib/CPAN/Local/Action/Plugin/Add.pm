package CPAN::Local::Action::Plugin::Add;

use strict;
use warnings;

use CPAN::Index::API;
use File::Path qw(make_path);
use Path::Class qw(file dir);
use File::Temp;
use URI;
use LWP::Simple;
use CPAN::DistnameInfo;
use CPAN::Local::Distribution;

use Moose;
extends 'CPAN::Local::Action::Plugin';
with 'CPAN::Local::Action::Role::Gather';
use namespace::clean -except => 'meta';

has config => 
(
	is        => 'ro',
	isa       => 'Str',
	predicate => 'has_config',
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

	if ( $self->has_config )
	{
		foreach my $line ( file( $self->config )->slurp )
		{
			chomp $line;
			push @uris, $prefix . $line;
		}
	}

	return \@uris;
}

sub _build_cache 
{
    return File::Temp::tempdir( CLEANUP => 0 );
}

sub gather
{
	my $self = shift;

    my @distros;

	foreach my $uri_string ( $self->uri_list )
	{
        my $distro = $self->local
            ? $self->add_local($uri_string)
            : $self->add_remote($uri_string);
        
        push @distros, $distro if $distro;
    }

	return @distros;
}

sub add_local
{
    my ( $self, $uri_string ) = @_;

    my $authorid = $self->has_authorid
        ? $self->authorid
        : _get_authorid_from_path_parts( file($uri_string)->dir->dir_list )

    if ( not -e $uri_string )
    {
        $self->log("File $uri_string does not exist");
        return;
    }
    elsif ( not $authorid )
    {
        $self->log("Cannot determine authorid for path $uri_string");
        return;
    }
    else
    {
        return CPAN::Local::Distribution->new(
            filename => $uri_string, 
            authorid => $auhtorid,
        );
    }
}

sub add_remote
{
    my ( $self, $uri_string ) = @_;

    my $uri = URI->new($uri_string);
    my @path_parts = $uri->path_segments;
    
    my $authorid = $self->has_authorid
        ? $self->authorid,
        : _get_authorid_from_path_parts(@path_parts)

    if ( $authorid )
    {
        my $distnameinfo = CPAN::DistnameInfo->new(
            '%s/%s', $authorid, $path_parts[-1]
        );

        my $filename = file($self->cache, $distnameinfo->filename)->strinfigy;
        
        unless ( -e $path ) {	
            my $rc = LWP::Simple::getstore($uri->as_string, $filename);
            
            if ( LWP::Simple::is_error($rc) ) {
                $self->log("Error fetching " . $uri->as_string);
                return;
            }
            else
            {
                return CPAN::Local::Distribution->new(
                    filename => $filename,
                    authorid => $authorid,
                );
            }
        }
    }
    else
    {
        $self->log("Cannot determine authorid for uri $uri_string");
        return;
    }
}

sub  _get_authorid_from_path_parts
{
    my ($self, @path_parts) = @_;
    
    my $distname = file( splice( @path_parts, -5 ) )->as_foreign('Unix')->stringify;

    return CPAN::DistnameInfo->new($distname)->authorid;
}

__PACKAGE__->meta->make_immutable;
