package CPAN::Local::Role::Remove;

# ABSTRACT: Remove distributions from the repo

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'remove';

1;
