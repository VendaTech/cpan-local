package CPAN::Local::Distribution::Role::MD5;

# ABSTRACT: Calculate checksums for a distribution

use strict;
use warnings;
use Digest::MD5;
use Moose::Role;

has md5 => ( is => 'ro', isa => 'Str', lazy_build => 1 );

sub _build_md5
{
    my $self = shift;
    my $fh = file($self->filename)->open or die $!;
    binmode $fh;
    return Digest::MD5->new->addfile($fh)->hexdigest;
}

1;

=pod

=head1 ATTRIBUTES

=head2 md5

Checksum for the distribution archive cacluclated using L<Digest::MD5>.

=cut
