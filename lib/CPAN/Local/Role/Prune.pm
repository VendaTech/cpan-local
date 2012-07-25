package CPAN::Local::Role::Prune;

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'prune';

1;
