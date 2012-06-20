package CPAN::Local::Action::Plugin::AddFromURI;

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

has lines =>
(
	is         => 'ro',
	isa        => 'ArrayRef',
	lazy_build => 1,
	traits     => ['Array'],
	handles    => { line_list => 'elements' },
);

has prefix => 
(
	is      => 'ro',
	isa     => 'Str',
	default => '',
);

has cache => 
(
	is         => 'ro',
	isa        => 'Str',
	lazy_build => 1,
);

has cpanid =>
(
	is        => 'ro',
	isa       => 'Str',
	predicate => 'has_cpanid',
);

sub _build_lines
{
	my $self = shift;

	my @lines;

	if ( $self->has_config )
	{
		foreach my $line ( file( $self->config )->slurp )
		{
			chomp $line;
			push @lines, $line;
		}
	}

	return \@lines;
}

sub _build_cache 
{
    return File::Temp::tempdir( CLEANUP => 0 );
}

sub gather
{
	my ($self, @distros) = @_;

	foreach my $line ( $self->line_list )
	{
		my $distname = $self->has_cpanid 
			? sprintf '%s/%s', $self->cpanid, file($line)->basename
			: $line;

		my $distro =  CPAN::DistnameInfo->new($distname);
        my $path = file($self->cache, $distro->filename);
        
        unless ( -e $path ) {	
			my $uri = URI->new($self->prefix . $line);
            my $rc = LWP::Simple::getstore($uri->as_string, $path->stringify);
            
            if ( LWP::Simple::is_error($rc) ) {
                $self->log("Error fetching " . $uri->as_string);
                next;
            }
        }

		push @distros, CPAN::Local::Distribution->new(
            filename => $path, 
            authorid => $distro->cpanid
        );
	}

	return @distros;
}

__PACKAGE__->meta->make_immutable;

1;
