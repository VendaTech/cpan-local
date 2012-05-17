package CPAN::Local::Distribution;

use strict;
use warnings;

use Moose;
use namespace::clean -except => 'meta';

has filename =>
(
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has authorid =>
(
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has path =>
(
    is         => 'ro',
    isa        => 'Str',
    lazy_build => 1,
);

has provides =>
(
    is     => 'ro',
    isa    => 'HashRef',
    traits => ['Hash'],
);

sub _build_path
{
    my $self = shift;

    my $filename = file($self->filename)->basename;

    if ( my $authorid = $self->authorid )
    {
        my @chars = split //, $authorid;
        my $path = dir( 
            'authors', 
            'id', 
            $chars[0], 
            $chars[0] . $chars[1], 
            $authorid,
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

__PACKAGE__->meta->make_immutable;
