package CPAN::Local::Distribution;

use strict;
use warnings;

use Path::Class qw(file dir);
use Carp        qw(croak);
use LWP::Simple qw(is_error getstore);
use File::Temp  qw(tempdir);
use Dist::Metadata;
use CPAN::DistnameInfo;
use Digest::MD5;
use URI;
use Moose;
use namespace::clean -except => 'meta';

has filename => ( is => 'ro', isa => 'Str', required => 1 );
has authorid => ( is => 'ro', isa => 'Str', required => 1 );
has uri      => ( is => 'ro', isa => 'Str' );
has cache    => ( is => 'ro', isa => 'Str' );
has path     => ( is => 'ro', isa => 'Str', lazy_build => 1 );
has metadata => ( is => 'ro', isa => 'CPAN::Meta', lazy_build => 1 );
has nameinfo => ( is => 'ro', isa => 'CPAN::DistnameInfo', lazy_build => 1 );
has md5      => ( is => 'ro', isa => 'Str', lazy_build => 1 );

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    
    my %args = @_;

    croak "Please specify either 'filename' or 'uri', not both"
        if exists $args{uri} and exists $args{filename};

    croak "Attribute 'cache' not permitted unless 'uri' is also specified"
        if exists $args{cache} and not exists $args{uri};

    # force default Moose error for required 'filename'
    return $class->$orig(%args)
        unless exists $args{filename} or exists $args{uri};

    my ( $uri, @uri_segments );

    if ( $args{uri} )
    {
        $uri = URI->new($args{uri});
        @uri_segments = $uri->path_segments;
    }

    if ( not exists $args{authorid} ) 
    {
        my $path = file( $args{filename} ? $args{filename} : @uri_segments );
        
        # calculate the path, e.g. 'authors/id/A/AD/ADAMK/File-Which-1.09.tar.gz'
        my @path_parts = ( $path->dir->dir_list, $path->basename );
        
        # get the last 6 parts of the path
        @path_parts = splice( @path_parts, -6 ) if @path_parts >= 6;

        # make sure we use only forward slashes
        my $distname = file(@path_parts)->as_foreign('Unix')->stringify;
        
        # get the authorid
        my $distnameinfo = CPAN::DistnameInfo->new($distname);
        $args{authorid} = $distnameinfo->cpanid
            or croak "'authorid' not set and could not be deduced from $path";

        # also supply path and nameinfo, since we have already calculated it
        $args{path} = $distname unless $args{path};
        $args{nameinfo} = $distnameinfo unless $args{nameinfo};
    }

    if ( $args{uri} )
    {
        $args{path} = __PACKAGE__->new(
            filename => $uri_segments[-1],
            authorid => $args{authorid},
        )->path unless $args{path};

        $args{cache} = tempdir( CLEANUP => 1 ) unless $args{cache};

        my $filename = file($args{cache}, $args{path});
        $filename->dir->mkpath;

        if ( not -e $filename )
        {
            is_error( getstore( $uri->as_string, $filename->stringify ) )
                ? croak "Error fetching " . $uri->as_string
                : ( $args{filename} = $filename->stringify );
        }
    }

    return $class->$orig(%args);
};

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
