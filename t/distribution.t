use strict;
use warnings;

use CPAN::Local::Distribution;
use Path::Class qw(file);
use Test::Most;

my %distro;

$distro{authorid_and_filename} = CPAN::Local::Distribution->new(
    authorid => 'ADAMK',
    filename => 'File-Which-1.09.tar.gz',
);

isa_ok ( $distro{authorid_and_filename}, 'CPAN::Local::Distribution' );
is ( $distro{authorid_and_filename}->path, 
     'authors/id/A/AD/ADAMK/File-Which-1.09.tar.gz', 
     'calculate distro path' );

$distro{filename} = CPAN::Local::Distribution->new(
    filename => '/foo/bar/authors/id/A/AD/ADAMK/File-Which-1.09.tar.gz',
);

is ( $distro{filename}->authorid, 'ADAMK', 'calculate authorid' );

done_testing;
