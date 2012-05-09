package CPAN::Local::Action::Role::Index;

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'index';

1;
