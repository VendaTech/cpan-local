package CPAN::Local::Role::Cleanup;

# ABSTRACT: Remove orphan files

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'cleanup';

1;

=pod

=head1 DESCRIPTION

Plugins implementing this role are executed whenever there is a request to
clean up unused files in the repository. 

=head1 INTERFACE

Plugins implementing this role should provide a C<cleanup> method with the
following interface:

=head2 Parameters

None

=head2 Returns

List of paths to files under the repository root that this module knows about.

=cut
