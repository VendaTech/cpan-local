package CPAN::Local::Distribution::Role::FromURI;

use strict;
use warnings;
use Carp        qw(croak);
use Path::Class qw(file dir);
use File::Temp  qw(tempdir);
use LWP::Simple qw(is_error getstore);
use Moose::Role;
use namespace::clean -except => 'meta';

has uri   => ( is => 'ro', isa => 'Str' );
has cache => ( is => 'ro', isa => 'Str' );

around BUILDARGS => sub 
{
    my ( $orig, $class, %args ) = @_;

    return $class->$orig(%args) unless $args{uri};

    croak "Please specify either 'filename' or 'uri', not both"
        if $args{uri} and $args{filename};

    my $uri = URI->new($args{uri});
    my $fake_filename = file($uri->path_segments)->stringify;
    
    unless ( $args{path} and $args{authorid} )
    {
        my $fake_distro = CPAN::Local::Distribution->new(
            filename => $fake_filename,
            $args{authorid} ? ( authorid => $args{authorid} ) : (),
        );

        $args{authorid} = $fake_distro->authorid unless $args{authorid};
        $args{path} = $fake_distro->path unless $args{path};
    }

    $args{cache} = tempdir( CLEANUP => 1 ) unless $args{cache};

    my $filename = file($args{cache}, $args{path});
    $filename->dir->mkpath;

    if ( not -e $filename )
    {
        my $result = getstore( $uri->as_string, $filename->stringify );
        croak "Error fetching " . $uri->as_string if is_error $result;
    }

    $args{filename} = $filename->stringify;

    return $class->$orig(%args);
};

1;
