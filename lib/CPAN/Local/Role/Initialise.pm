package CPAN::Local::Role::Initialise;

# ABSTRACT: Initialize an empty repo

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'initialise';

1;

=pod

=head1 DESCRIPTION

Plugins implementing this role are executed whenever a new repository needs
to be initialised.

=head1 INTERFACE

Plugins implementing this role should provide an C<initialise> method with the
following interface:

=head2 Parameters

None.

=head2 Returns

Nothing.

=cut
