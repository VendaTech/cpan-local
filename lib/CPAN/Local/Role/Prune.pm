package CPAN::Local::Role::Prune;

# ABSTRACT: Remove distributions from selection list

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'prune';

1;
