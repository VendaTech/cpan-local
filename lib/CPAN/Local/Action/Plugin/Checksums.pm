package CPAN::Local::Action::Plugin::Checksums;

use strict;
use warnings;

use CPAN::Checksums qw(updatedir);
use List::MoreUtils qw(uniq);
use Path::Class     qw(file dir);
use Moose;
extends 'CPAN::Local::Action::Plugin';
with 'CPAN::Local::Action::Role::Index';
use namespace::clean -except => 'meta';

sub index
{
	my ($self, @distros) = @_;
    my @authordirs = uniq map { file($_->path)->dir->stringify } @distros;
    updatedir( dir($self->root, $_) ) for @authordirs;
}

__PACKAGE__->meta->make_immutable;
