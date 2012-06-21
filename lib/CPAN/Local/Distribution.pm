package CPAN::Local::Distribution;

use strict;
use warnings;

use Path::Class qw(file dir);
use Dist::Metadata;
use CPAN::DistnameInfo;
use Digest::MD5;
use URI;
use LWP::Simple;
use Moose;
use namespace::clean -except => 'meta';

has filename => ( is => 'ro', isa => 'Str', required => 1 );
has authorid => ( is => 'ro', isa => 'Str', required => 1 );
has path     => ( is => 'ro', isa => 'Str', lazy_build => 1 );
has metadata => ( is => 'ro', isa => 'CPAN::Meta', lazy_build => 1 );
has nameinfo => ( is => 'ro', isa => 'CPAN::DistnameInfo', lazy_build => 1 );
has md5      => ( is => 'ro', isa => 'Str', lazy_build => 1 );

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    
    my %args = @_;

    if ( exists $args{authorid} ) 
    {
        return $class->$orig(@_);
    }
    else
    {
        my $path = file($args{filename});
        
        # calculate the path, e.g. 'authors/id/A/AD/ADAMK/File-Which-1.09.tar.gz'
        my @path_parts = $path->dir->dir_list, $path->basename;
        @path_parts = splice( @path_parts, -5 );
        my $distname = file(@path_parts)->as_foreign('Unix')->stringify;

        # get the authorid
        $args{authorid} = CPAN::DistnameInfo->new($distname)->cpanid;
        # also supply path, since we have already calculated it
        $args{path} = $distname unless exists $args{path};

        return $class->$orig(%args);
    }
};

sub new_from_uri
{
    my ( $self, $uri_string ) = @_;

    # args: uri, authorid, cache

    my $uri = URI->new($uri_string);
    my @path_parts = $uri->path_segments;
    
    my $authorid = $self->has_authorid
        ? $self->authorid
        : _get_authorid_from_path_parts(@path_parts);

    if ( $authorid )
    {
        my $distnameinfo = CPAN::DistnameInfo->new(
            '%s/%s', $authorid, $path_parts[-1]
        );

        my $filename = file($self->cache, $distnameinfo->filename)->strinfigy;
        
        unless ( -e $filename ) {	
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

sub _build_path
{
    my $self = shift;

    my $filename = file($self->filename)->basename;

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

sub _build_metadata
{
    my $self = shift;
    return Dist::Metadata->new( file => $self->filename )->meta;
}

sub _build_nameinfo
{
    my $self = shift;
    return CPAN::DistnameInfo->new($self->path);
}

sub _build_md5
{
    my $self = shift;
    my $fh = file($self->filename)->open or die $!;
    binmode $fh;
    return Digest::MD5->new->addfile($fh)->hexdigest;
}

__PACKAGE__->meta->make_immutable;
