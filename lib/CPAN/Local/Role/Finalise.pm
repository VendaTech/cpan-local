package CPAN::Local::Role::Finalise;

# ABSTRACT: Do something after updates complete

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'finalise';

1;
