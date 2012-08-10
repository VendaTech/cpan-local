package CPAN::Local::Plugin::Duplicates;

# ABSTRACT: Remove duplicates

use strict;
use warnings;

use Moose;
extends 'CPAN::Local::Plugin';
with 'CPAN::Local::Role::Clean';
use namespace::clean -except => 'meta';

sub clean
{
    my ( $self, @distros ) = @_;

    my (%paths, @cleaned);

    foreach my $distro ( @distros )
    {
        next if $paths{$distro->path}++;
        push @cleaned, $distro;
    }

    return @cleaned;
}

__PACKAGE__->meta->make_immutable;

=pod

=head1 IMPLEMENTS

=over

=item L<CPAN::Local::Plugin::Clean>

=back

=head1 METHODS

=head2 clean

De-dups the distribution list. A distribution is considered a duplicate if
there is already another disribution that will write to the same path.

=cut
