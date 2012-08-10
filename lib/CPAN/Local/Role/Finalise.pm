package CPAN::Local::Role::Finalise;

# ABSTRACT: Do something after updates complete

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'finalise';

1;

=pod

=head1 DESCRIPTION

Plugins implementing this role are executed after a successful update of a
repository, i.e. after injection and indexing.

=head1 INTERFACE

Plugins implementing this role should provide a C<finalise> method with the
following interface:

=head2 Parameters

List of <CPAN::Local::Distribution> objects representing distributions that
were successfully added to the repository.

=head2 Returns

Nothing.

=cut
