package CPAN::Local::Distribution;

use strict;
use warnings;

use Path::Class qw(file dir);
use Dist::Metadata;
use Moose;
use namespace::clean -except => 'meta';

has filename => ( is => 'ro', isa => 'Str', required => 1 );
has authorid => ( is => 'ro', isa => 'Str', predicate => 'has_authorid' );
has path     => ( is => 'ro', isa => 'Str', lazy_build => 1 );
has metadata => ( is => 'ro', isa => 'CPAN::Meta', lazy_build => 1 );

sub _build_path
{
    my $self = shift;

    my $filename = file($self->filename)->basename;

    if ( $self->has_authorid )
    {
        my @chars = split //, $self->authorid;
        my $path = dir( 
            'authors', 
            'id', 
            $chars[0], 
            $chars[0] . $chars[1], 
            $self->authorid,
            $filename,
        );

        return $path->as_foreign('Unix')->stringify;
    }
    else
    {
        my @path_parts = $filename->dir->dir_list(-5);

        return file(
            @path_parts, 
            $filename,
        )->as_foreign('Unix')->stringify
    }
}

sub _build_metadata
{
    my $self = shift;
    return Dist::Metadata->new( file => $self->filename )->meta;
}

1;
