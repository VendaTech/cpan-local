package CPAN::Local::Role::Inject;

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'inject';

1;
