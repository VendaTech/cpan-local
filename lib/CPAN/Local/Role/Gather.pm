package CPAN::Local::Role::Gather;

# ABSTRACT: Select distributions to add

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'gather';

1;
