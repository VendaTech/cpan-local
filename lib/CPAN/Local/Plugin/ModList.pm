package CPAN::Local::Plugin::ModList;

use CPAN::Index::API::File::ModList;
use Path::Class qw(file dir);
use namespace::autoclean;
use Moose;
extends 'CPAN::Local::Plugin';
with qw(CPAN::Local::Role::Initialise);

sub initialise
{
    my $self = shift;

    dir($self->root)->mkpath;
    
    my $modlist = CPAN::Index::API::File::ModList->new(
        repo_path => $self->root,
    );

    $modlist->write_to_tarball;
}

__PACKAGE__->meta->make_immutable;
