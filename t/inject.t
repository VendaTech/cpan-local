use strict;
use warnings;

use CPAN::Local::Action::Plugin::Inject;
use File::Temp qw(tempdir);
use Path::Class qw(file);
use CPAN::Local::Distribution;

use Test::Most;

my $repo_root = tempdir;
my $repo_uri  = 'http://www.example.com/';

my $plugin = CPAN::Local::Action::Plugin::Inject->new(
    uri  => $repo_uri,
    root => $repo_root,
);

isa_ok( $plugin, 'CPAN::Local::Action::Plugin::Inject' );

my %distros = (
    file_which => CPAN::Local::Distribution->new(
        authorid => 'ADAMK',
        filename => file('t/distributions/File-Which-1.09.tar.gz')->stringify,
    ),
    any_moose => CPAN::Local::Distribution->new(
        authorid => 'SARTAK',
        filename => file('t/distributions/Any-Moose-0.08.tar.gz')->stringify,
    ),
    bogus => CPAN::Local::Distribution->new(
        authorid => 'FOOBAR',
        filename => file( tempdir, 'foobar' )->stringify,
    ),
);

my @injected = $plugin->inject( $distros{bogus} );

is ( scalar @injected, 0, 'inject failed' );

@injected = $plugin->inject( @distros{qw(file_which any_moose)} );

is ( scalar @injected, 2, 'inject succeded' );

is_deeply (
    [ sort map file($_->filename)->basename, @injected ],
    [ 'Any-Moose-0.08.tar.gz', 'File-Which-1.09.tar.gz' ],
    'injected package names',
);

my $existing = grep { -e } map { file( $repo_root, $_->path ) } @injected; 

is ( $existing, 2, 'injected tarballs exist' );

done_testing;
