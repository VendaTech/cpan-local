package CPAN::Local::Action::Role::Inject;

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'inject';

1;
