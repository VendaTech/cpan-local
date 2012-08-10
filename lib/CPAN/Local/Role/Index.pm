package CPAN::Local::Role::Index;

# ABSTRACT: Index a repo

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'index';

1;
