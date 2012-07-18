package CPAN::Local::Distribution::Role::NameInfo;

use strict;
use warnings;
use CPAN::DistnameInfo;
use Moose::Role;

has nameinfo => ( is => 'ro', isa => 'CPAN::DistnameInfo', lazy_build => 1 );

sub _build_nameinfo
{
    my $self = shift;
    return CPAN::DistnameInfo->new($self->path);
}

1;
