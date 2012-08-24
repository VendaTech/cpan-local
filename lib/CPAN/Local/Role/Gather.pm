package CPAN::Local::Role::Gather;

# ABSTRACT: Select distributions to add

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'gather';

1;

=pod

=head1 DESCRIPTION

Plugins implementing this role are executed at the start of a repository
update. They determine the list of distributions to add.

=head1 INTERFACE

Plugins implementing this role should provide a C<gather> method with the
following interface:

=head2 Parameters

None.

=head2 Returns

List of L<CPAN::Local::Distribution> objects representing distributions that
need to be added to the repository.

=cut
