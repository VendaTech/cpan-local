package CPAN::Local::Role::Index;

# ABSTRACT: Index a repo

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'index';

1;

=pod

=head1 DESCRIPTION

Plugins implementing this role are executed as part of the update process,
after the distributions have been physically injected into the repository.

=head1 INTERFACE

Plugins implementing this role should provide a C<index> method with the
following interface:

=head2 Parameters

None.

=head2 Returns

List of <CPAN::Local::Distribution> objects representing distributions that
need to be indexed.

=cut
