package CPAN::Local::Action::Plugin::Indices;

use strict;
use warnings;

use CPAN::Index::API;
use CPAN::Index::API::Object::Package;
use File::Path;
use CPAN::Local::Util;
use CPAN::DistnameInfo;
use Path::Class qw(file dir);

use Moose;
extends 'Cpan::Local::Action::Plugin';
with 'CPAN::Local::Action::Role::Initialise'; 
with 'CPAN::Local::Action::Role::Index';
use namespace::clean -except => 'meta';

has 'uri' => 
( 
	is       => 'ro', 
	isa      => 'Str', 
	required => 1 
);

sub initialise
{
    my $self = shift;
    
    File::Path::make_path( dir($self->root)->stringify );

    my $index = CPAN::Index::API->new(
        repo_path => $self->root,
        repo_uri  => $self->uri,
    );
    
    $index->write_all_files;
}

sub index
{
	my ($self, @distros) = @_;

	my $index = CPAN::Index::API->new_from_path(
		repo_path => $self->root,
		repo_uri  => $self->uri,
	);

	foreach my $distro ( @distros ) 
	{
		my %provides = $distro->provides->elements;
        
		while( my ($package, $version) = each %provides )
		{
			if ( my $existing_package = $index->find_package_by_name($package) )
			{
                $existing_package->version($version) 
                	if $version > $existing_package->version;
			}
			else
			{
				my $new_package = CPAN::Index::API::Object::Package->new(
					name         => $package,
					version      => $version,
					distribution => $distro->{path},
				);
				$index->add_package($new_package);
			}
		}
	}

	$index->write_all_files;
}

__PACKAGE__->meta->make_immutable;
