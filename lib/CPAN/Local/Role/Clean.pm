package CPAN::Local::Role::Clean;

# ABSTRACT: Remove orphan files

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'clean';

1;

