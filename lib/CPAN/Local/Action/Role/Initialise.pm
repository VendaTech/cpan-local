package CPAN::Local::Action::Role::Initialise;

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'initialise';

1;
