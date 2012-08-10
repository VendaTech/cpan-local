package CPAN::Local::MVP::Assembler;

# ABSTRACT: MVP assembler for CPAN::Local

use strict;
use warnings;

use String::RewritePrefix;

use Moose;
extends 'Config::MVP::Assembler';
with 'Config::MVP::Assembler::WithBundles';
use namespace::clean -except => 'meta';

has 'root_namespace' =>
(
  is       => 'ro',
  isa      => 'Str',
  required => 1,
);

sub expand_package
{
    my ($self, $package) = @_;

    my $str = String::RewritePrefix->rewrite({
        '=' => '',
        '@' => $self->root_namespace . '::PluginBundle::',
        '%' => $self->root_namespace . '::Stash::',
        ''  => $self->root_namespace . '::Plugin::',
    }, $package );

    return $str;
}

__PACKAGE__->meta->make_immutable;
