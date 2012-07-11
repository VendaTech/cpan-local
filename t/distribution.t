use strict;
use warnings;

use CPAN::Local::Distribution;
use Module::Faker::Dist;
use CPAN::Faker::HTTPD;
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

my $fake_distro = Module::Faker::Dist->new( name => 'Foo-Bar' );

$distro{existing_filename} = CPAN::Local::Distribution->new(
    authorid => 'ADAMK',
    filename => $fake_distro->make_archive,
);

isa_ok ( $distro{existing_filename}->metadata, 'CPAN::Meta' );

my $fakepan = CPAN::Faker::HTTPD->new({ source => '.' });
$fakepan->add_dist($fake_distro);
 
$fakepan->$_ for qw(_update_author_checksums write_package_index 
                 write_author_index write_modlist_index write_perms_index);

my $distro_path = 'authors/id/L/LO/LOCAL/Foo-Bar-0.01.tar.gz';
my $distro_uri = $fakepan->endpoint;
$distro_uri->path($distro_path);
$distro_uri = $distro_uri->as_string;

$distro{uri} = CPAN::Local::Distribution->new( uri => $distro_uri );

isa_ok ( $distro{uri}, 'CPAN::Local::Distribution' );

is ( $distro{uri}->authorid, 'LOCAL', 'calculate authorid from uri' );

is ( $distro{uri}->path, $distro_path, 'calculate distro path from uri' );

my $tempdir = tempdir( CLEANUP => 1 );

$distro{uri_and_cache} = CPAN::Local::Distribution->new(
    uri   => $distro_uri,
    cache => $tempdir,
);

ok( -e file( $tempdir, $distro_path ), 'fetch from uri into cache' );

$distro{uri_and_author} = CPAN::Local::Distribution->new(
    uri      => $distro_uri,
    cache    => $tempdir,
    authorid => 'FOOBAR',
);

is ( $distro{uri_and_author}->authorid, 'FOOBAR', 'honor custom author' );
ok( -e file( $tempdir, 'authors/id/F/FO/FOOBAR/Foo-Bar-0.01.tar.gz' ), 'fetch from uri with custom author' );

done_testing;
