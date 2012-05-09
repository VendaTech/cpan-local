package CPAN::Local::App;

use CPAN::Local;

use Moose;
extends 'MooseX::App::Cmd';

has cpan_local =>
(
	is         => 'ro',
	isa        => 'CPAN::Local',
	lazy_build => 1,
);

sub _build_cpan_local
{
	return CPAN::Local->new;
}

__PACKAGE__->meta->make_immutable;
