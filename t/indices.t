use strict;
use warnings;
use CPAN::Index::API;
use CPAN::Local::Action::Plugin::Indices;
use Module::Faker::Dist;
use File::Temp qw(tempdir);
use Path::Class qw(file);
use File::Copy;
use Dist::Metadata;
use CPAN::Local::Distribution;
use Test::Most;

### SETUP ###

my @distro_specs = (
    { 
        name        => 'File-Which', 
        version     => '1.09', 
        cpan_author => 'ADAMK',
    },
    { 
        name        => 'Any-Moose', 
        version     => '0.08', 
        cpan_author => 'SARTAK',
    },
    { 
        name        => 'Any-Moose', 
        version     => '0.09', 
        cpan_author => 'SARTAK',
    },
    { 
        name        => 'common-sense', 
        version     => '3.2', 
        cpan_author => 'MLEHMANN',
        provides    => [],
    },
);

my $distro_dir = tempdir;

foreach my $spec ( @distro_specs ) {
    my $distro = Module::Faker::Dist->new($spec);
    my $source = $distro->make_archive;
    my $target = file($distro_dir, file($source)->basename)->stringify;
    File::Copy::copy($source, $target) or die $!;
}

### LOAD ###

my $repo_root = tempdir;
my $repo_uri  = 'http://www.example.com/';

my $plugin = CPAN::Local::Action::Plugin::Indices->new(
    uri  => $repo_uri,
    root => $repo_root,
);

isa_ok( $plugin, 'CPAN::Local::Action::Plugin::Indices' );

### INITIALISE ###

$plugin->initialise;

my $index = CPAN::Index::API->new_from_path(
    repo_path => $repo_root,
    repo_uri  => $repo_uri,
);

isa_ok( $index, 'CPAN::Index::API' );

is ( $index->mail_rc->author_count, 0, '01mailrc.txt lines' );
is ( $index->packages_details->package_count, 0, '02packages.details.txt.gz lines' );
is ( $index->packages_details->uri, 
     'http://www.example.com/modules/02packages.details.txt', 
     '02packages.details.txt.gz url' );
is ( $index->mod_list->module_count, 0, '03modlist.data.gz lines' );

### INDEX ###

my %distros = (
    file_which => CPAN::Local::Distribution->new(
        authorid => 'ADAMK',
        filename => file($distro_dir, 'File-Which-1.09.tar.gz')->stringify,
    ),
    any_moose => CPAN::Local::Distribution->new(
        authorid => 'SARTAK',
        filename => file($distro_dir, 'Any-Moose-0.08.tar.gz')->stringify,
    ),
);

$plugin->index( values %distros );

$index = CPAN::Index::API->new_from_path(
    repo_path => $repo_root,
    repo_uri  => $repo_uri,
);

# updating authors does not work yet
# is ( $index->mail_rc->author_count, 2, 'update authors' );

is_deeply (
    [ map $_->name, $index->package_list ],
    [ 'Any::Moose', 'File::Which' ],
    'injected package names',
);

is ( 
    $index->find_package_by_name('Any::Moose')->version, '0.08', 
    'injected package version',
);

$plugin->index( CPAN::Local::Distribution->new(
    authorid => 'SARTAK',
    filename => file($distro_dir, 'Any-Moose-0.09.tar.gz')->stringify,
) );

$index = CPAN::Index::API->new_from_path(
    repo_path => $repo_root,
    repo_uri  => $repo_uri,
);

is ( 
    $index->find_package_by_name('Any::Moose')->version, '0.09', 
    'updated package version',
);

$plugin->index( CPAN::Local::Distribution->new(
    authorid => 'MLEHMANN',
    filename => file($distro_dir, 'common-sense-3.2.tar.gz')->stringify,
) );

$index = CPAN::Index::API->new_from_path(
    repo_path => $repo_root,
    repo_uri  => $repo_uri,
);

ok ( ! $index->find_package_by_name('common::sense'), 'without auto_provides' );

my $new_plugin = CPAN::Local::Action::Plugin::Indices->new(
    uri           => $repo_uri,
    root          => $repo_root,
    auto_provides => 1,
);

$new_plugin->index( CPAN::Local::Distribution->new(
    authorid => 'MLEHMANN',
    filename => file($distro_dir, 'common-sense-3.2.tar.gz')->stringify,
) );

$index = CPAN::Index::API->new_from_path(
    repo_path => $repo_root,
    repo_uri  => $repo_uri,
);

ok ( $index->find_package_by_name('common::sense'), 'with auto_provides' );

done_testing;
