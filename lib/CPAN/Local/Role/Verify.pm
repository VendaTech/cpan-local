package CPAN::Local::Role::Verify;

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'verify';

1;