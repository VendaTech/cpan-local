package CPAN::Local::Util;

use strict;
use warnings;

use Path::Class qw(file dir);

sub calculate_dist_path
{
    my %opt = @_;

    return unless $opt{filename};
    
    my $filename = file($opt{filename})->basename;

    if ( my $authorid = $opt{authorid} )
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

sub dist_name_to_package
{
    my %opt = @_;

    return unless my $name = $opt{name};

    $name =~ s/-/::/;

    return $name;
}

1;
