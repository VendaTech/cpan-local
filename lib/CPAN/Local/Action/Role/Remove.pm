package CPAN::Local::Action::Role::Remove;

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'remove';

1;
