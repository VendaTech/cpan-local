package CPAN::Local::Action::Role::Finalise;

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'finalise';

1;
