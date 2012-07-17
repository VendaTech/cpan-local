use strict;
use warnings;
use CPAN::Local::Action::Plugin::Checksums;
use Module::Faker::Dist;
use Path::Class qw(dir file);
use File::Temp  qw(tempdir);
use CPAN::Local::Distribution;
use Test::Most;
use Moose::Meta::Class;

### SETUP ###

my @fake_distro_specs = (
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
);

my $root = tempdir;
my $distro_root = dir($root, 'authors', 'id');
$distro_root->mkpath;
my @injected_distros;

foreach my $spec ( @fake_distro_specs ) {
    my $distro = Module::Faker::Dist->new($spec);
    push @injected_distros, CPAN::Local::Distribution->new(
        filename => $distro->make_archive({
            dir           => $distro_root->stringify,
            author_prefix => 1 
        }),
        authorid => $spec->{cpan_author},
    );
}

my $metaclass = Moose::Meta::Class->create_anon_class(
    superclasses => ['CPAN::Local::Distribution'],
    cache        => 1,
);

### TEST ###

my $plugin = CPAN::Local::Action::Plugin::Checksums->new(
    root => $root,
    distribution_class => $metaclass->name,
);

isa_ok( $plugin, 'CPAN::Local::Action::Plugin::Checksums' );

ok ( ! -e file($root, 'authors/id/S/SA/SARTAK/CHECKSUMS'), "Checksums file does not yet exist" );

$plugin->index(@injected_distros);

ok ( -e file($root, 'authors/id/S/SA/SARTAK/CHECKSUMS'), "Checksums file created" );

done_testing;
