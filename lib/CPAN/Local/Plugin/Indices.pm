package CPAN::Local::Plugin::Indices;

# ABSTRACT: [DEPRECATED] Update index files

use strict;
use warnings;

BEGIN {
    warn "CPAN::Local::Plugin::Indices is deprecated. "
       . "Please use PackagesDetails, ModList and MalRc plugins instead."
    unless $ENV{HARNESS_ACTIVE};
}

use CPAN::Index::API;
use CPAN::Index::API::File::PackagesDetails;
use File::Path;
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

sub initialise
{
    my $self = shift;

    File::Path::make_path( dir($self->root)->stringify );

    my %args = (
        repo_path => $self->root,
        files => [qw(PackagesDetails MailRc ModList)],
    );
    $args{repo_uri} = $self->repo_uri if $self->repo_uri;

    my $index = CPAN::Index::API->new(%args);

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
                $existing_package->{version} = $version
                    if Perl::Version->new($version) >
                       Perl::Version->new($existing_package->{version});
            }
            else
            {
                $packages_details->add_package({
                    name         => $package,
                    version      => $version,
                    distribution => $distro->path,
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

Initializes the following index files:

=over

=item C<authors/01mailrc.txt.>

=item C<modules/02packages.details.txt.gz>

=item C<modules/03modlist.data.gz>

=back

=head2 index

Updates C<02packages.details.txt.gz> with information for the
newly added distributions.

=cut
