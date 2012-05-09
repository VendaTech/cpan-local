package CPAN::Local::Action::Role::Gather;

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'gather';

1;
