package CPAN::Local::Action::Role::Clean;

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'clean';

1;

