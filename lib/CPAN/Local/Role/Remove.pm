package CPAN::Local::Role::Remove;

# ABSTRACT: Remove distributions from the repo

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'remove';

1;

=pod

=head1 DESCRIPTION

Plugins implementing this role are executed whenever a whole repository needs
to be completely removed.

=head1 INTERFACE

Plugins implementing this role should provide a C<remove> method with the
following interface:

=head2 Parameters

None.

=head2 Returns

Nothing.

=cut
