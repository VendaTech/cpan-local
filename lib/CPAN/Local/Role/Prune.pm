package CPAN::Local::Role::Prune;

# ABSTRACT: Remove distributions from selection list

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'prune';

1;

=pod

=head1 DESCRIPTION

Plugins implementing this role are executed right after the initial list of
distributions that need to be added is determined, and their purpose is to
remove any unneeded distributions from that list.

=head1 INTERFACE

Plugins implementing this role should provide a C<prune> method with the
following interface:

=head2 Parameters

List of L<CPAN::Local::Distribution> objects that are planned for addition.

=head2 Returns

List of L<CPAN::Local::Distribution> objects for addition, with any unneeded
distributions removed.

=cut
