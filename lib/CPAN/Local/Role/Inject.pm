package CPAN::Local::Role::Inject;

# ABSTRACT: Add selected distributions to a repo

use strict;
use warnings;

use Moose::Role;
use namespace::clean -except => 'meta';

requires 'inject';

1;
