package CPAN::Local::Plugin::Indices;

use strict;
use warnings;

use CPAN::Index::API;
use CPAN::Index::API::Object::Package;
use CPAN::Index::API::File::PackagesDetails;
use File::Path;
use CPAN::DistnameInfo;
use Path::Class qw(file dir);
use Moose;
extends 'CPAN::Local::Plugin';
with 'CPAN::Local::Role::Initialise'; 
with 'CPAN::Local::Role::Index';
use namespace::clean -except => 'meta';

has 'uri' => 
( 
	is       => 'ro', 
	isa      => 'Str', 
	required => 1 
);

has 'root' =>
(
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'auto_provides' => 
(
    is  => 'ro',
    isa => 'Bool',
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

	my $packages_details = 
        CPAN::Index::API::File::PackagesDetails->read_from_repo_path($self->root);

	foreach my $distro ( @distros ) 
	{
		my %provides = %{ $distro->metadata->provides };
        
        if ( ! %provides and $self->auto_provides )
        {
            my $distnameinfo = CPAN::DistnameInfo->new(
                file($distro->filename)->basename
            );
            
            ( my $fake_package = $distnameinfo->dist ) =~ s/-/::/g;
            
            $provides{$fake_package} = { version => $distnameinfo->version };
        }

		while( my ($package, $specs) = each %provides )
		{
            my $version = $specs->{version};

			if ( my $existing_package = $packages_details->package($package) )
			{
                $existing_package->version($version) 
                	if $version > $existing_package->version;
			}
			else
			{
				my $new_package = CPAN::Index::API::Object::Package->new(
					name         => $package,
					version      => $version,
					distribution => $distro->path,
				);
				$packages_details->add_package($new_package);
			}
		}
	}

	$packages_details->write_to_tarball;
}

__PACKAGE__->meta->make_immutable;
