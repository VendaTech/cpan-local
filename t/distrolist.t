use strict;
use warnings;

use Test::Most;
use CPAN::Local::Action::Plugin::DistroList;
use File::Temp qw(tempdir tempfile);
use Path::Class qw(file dir);

### add distros from mirror

_test_distrolist( 
    'from mirror',
    CPAN::Local::Action::Plugin::DistroList->new(
        uris => [
            'http://backpan.perl.org/authors/id/A/AD/ADAMK/File-Which-1.08.tar.gz',
            'http://backpan.perl.org/authors/id/A/AD/ADAMK/File-Which-1.09.tar.gz',
        ],
        cache => tempdir(),
        root  => '.',
    ),
    'File-Which', 'File-Which',
);

### add local distros

_test_distrolist(
    'from path',
    CPAN::Local::Action::Plugin::DistroList->new(
        uris => [
            file( 't', 'distributions', 'File-Which-1.09.tar.gz' )->stringify,
        ],
        local    => 1,
        root     => '.',
        authorid => 'ADAMK',
    ),
    'File-Which',
);

### use configuration file

my ( $fh, $filename ) = tempfile;
print $fh "File-Which-1.09.tar.gz" or die $!;
close $fh or die $!;

_test_distrolist(
    'using configuration file',
    CPAN::Local::Action::Plugin::DistroList->new(
        list     => $filename,
        local    => 1,
        root     => '.',
        authorid => 'ADAMK',
        prefix   => 't/distributions/',
    ),
    'File-Which',
);

sub _test_distrolist {
    my ( $test, $distrolist, @names ) = @_;
    isa_ok $distrolist, 'CPAN::Local::Action::Plugin::DistroList';

    my @distros = $distrolist->gather;
    is $#distros, $#names, "distros gathered $test";
    is $distros[$_]->metadata->name, $names[$_], "file fetched $test" 
        for 0 .. $#distros;
}

done_testing;
