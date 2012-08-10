package CPAN::Local::Role::Inject;

# ABSTRACT: Add selected distributions to a repo

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'inject';

1;

=pod

=head1 DESCRIPTION

Plugins implementing this role are executed at the point where the list of
distributions that need to be added has been determined, and the actual
addition needs to be performed.

=head1 INTERFACE

Plugins implementing this role should provide an C<inject> method with the
following interface:

=head2 Parameters

List of L<CPAN::Local::Distribution> objects to inject.

=head2 Returns

List of L<CPAN::Local::Distribution> objects successflly injected.

=cut
