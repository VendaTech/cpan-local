package CPAN::Local::Plugin::PackagesDetails;

# ABSTRACT: Update 02packages.details.txt

use strict;
use warnings;

use CPAN::Index::API::File::PackagesDetails;
use CPAN::DistnameInfo;
use Path::Class qw(file dir);
use URI::file;
use Perl::Version;
use namespace::autoclean;
use Moose;
extends 'CPAN::Local::Plugin';
with qw(CPAN::Local::Role::Initialise CPAN::Local::Role::Index);

has 'repo_uri' =>
(
    is  => 'ro',
    isa => 'Str',
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

has 'no_update' =>
(
    is  => 'ro',
    isa => 'Bool',
);

sub initialise
{
    my $self = shift;

    dir($self->root)->mkpath;

    my $packages_details = CPAN::Index::API::File::PackagesDetails->new(
        repo_path => $self->root,
        $self->repo_uri ? ( repo_uri => $self->repo_uri ) : (),
    );

    $packages_details->write_to_tarball;
}

sub index
{
    my ($self, @distros) = @_;

    return if $self->no_update;

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
                $existing_package->{version} = $version
                    if Perl::Version->new($version) >
                       Perl::Version->new($existing_package->{version});
            }
            else
            {
                my $path = file($distro->path);

                # drop 'authors/id' from the distro path
                my $distribution = file(
                    $path->dir->dir_list(2),
                    $path->basename,
                )->as_foreign('Unix')->stringify;

                $packages_details->add_package({
                    name         => $package,
                    version      => $version,
                    distribution => $distribution,
                });
            }
        }
    }

    $packages_details->rebuild_content;
    $packages_details->write_to_tarball;
}

sub requires_distribution_roles { qw(Metadata) }

__PACKAGE__->meta->make_immutable;


=pod

=head1 IMPLEMENTS

=over

=item L<CPAN::Local::Role::Initialise>

=item L<CPAN::Local::Role::Index>

=back

=head1 METHODS

=head2 initialise

Initializes an empty C<modules/02packages.details.txt.gz>.

=head2 index

Updates C<02packages.details.txt.gz> with information for the
newly added distributions.

=cut
