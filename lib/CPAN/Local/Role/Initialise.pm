package CPAN::Local::Role::Initialise;

# ABSTRACT: Initialize an empty repo

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'initialise';

1;
