use strict;
use warnings;

use CPAN::Local::Distribution;
use Path::Class qw(file);
use File::Temp  qw(tempdir);
use Test::Most;

my %distro;

$distro{authorid_and_filename} = CPAN::Local::Distribution->new(
    authorid => 'ADAMK',
    filename => 'File-Which-1.09.tar.gz',
);

isa_ok ( $distro{authorid_and_filename}, 'CPAN::Local::Distribution' );
isa_ok ( $distro{authorid_and_filename}->nameinfo, 'CPAN::DistnameInfo' );

is ( $distro{authorid_and_filename}->path, 
     'authors/id/A/AD/ADAMK/File-Which-1.09.tar.gz', 
     'calculate distro path' );

$distro{filename} = CPAN::Local::Distribution->new(
    filename => '/foo/bar/authors/id/A/AD/ADAMK/File-Which-1.09.tar.gz',
);

is ( $distro{filename}->authorid, 'ADAMK', 'calculate authorid' );

dies_ok ( 
    sub { $distro{filename_no_author} = CPAN::Local::Distribution->new(
        filename => '/foo/bar/File-Which-1.09.tar.gz',
    ) },
    'fail to calculate authorid',
);

$distro{existing_filename} = CPAN::Local::Distribution->new(
    authorid => 'ADAMK',
    filename => file('t', 'distributions', 'File-Which-1.09.tar.gz')->stringify,
);

isa_ok ( $distro{existing_filename}->metadata, 'CPAN::Meta' );

$distro{uri} = CPAN::Local::Distribution->new(
    uri => 'http://backpan.perl.org/authors/id/A/AD/ADAMK/File-Which-1.09.tar.gz'
);

isa_ok ( $distro{uri}, 'CPAN::Local::Distribution' );

is ( $distro{uri}->authorid, 'ADAMK', 'calculate authorid from uri' );

is ( $distro{uri}->path, 
     'authors/id/A/AD/ADAMK/File-Which-1.09.tar.gz', 
     'calculate distro path from uri' );

my $tempdir = tempdir( CLEANUP => 1 );

$distro{uri_and_cache} = CPAN::Local::Distribution->new(
    uri   => 'http://backpan.perl.org/authors/id/A/AD/ADAMK/File-Which-1.09.tar.gz',
    cache => $tempdir,
);

ok( -e file( $tempdir, 'authors/id/A/AD/ADAMK/File-Which-1.09.tar.gz' ), 'fetch from uri into cache' );

$distro{uri_and_author} = CPAN::Local::Distribution->new(
    uri      => 'http://backpan.perl.org/authors/id/A/AD/ADAMK/File-Which-1.09.tar.gz',
    cache    => $tempdir,
    authorid => 'FOOBAR',
);

is ( $distro{uri_and_author}->authorid, 'FOOBAR', 'honor custom author' );
ok( -e file( $tempdir, 'authors/id/F/FO/FOOBAR/File-Which-1.09.tar.gz' ), 'fetch from uri with custom author' );

done_testing;
