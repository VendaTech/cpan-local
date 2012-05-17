package CPAN::Local;

use strict;
use warnings;

use Path::Class qw(file dir);
use File::Path  qw(make_path);
use File::Copy;
use CPAN::Local::MVP::Assembler;
use Config::MVP::Reader::Finder;
use Log::Dispatchouli;

use Moose;
use namespace::clean -except => 'meta';

has 'config' => (
    is         => 'ro',
    required   => 1,
    lazy_build => 1,
);

has 'root' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => '.',
);

has 'root_namespace' =>
(
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => 'CPAN::Local::Action',
);

has 'plugins' => (
    is         => 'ro',
    isa        => 'HashRef',
    required   => 1,
    lazy_build => 1,
);

has 'config_filename' => 
(
    is       => 'ro',
    isa      => 'Str',
    required => 1,
    default  => 'cpanlocal'
);

has 'logger' =>
(
	is         => 'ro',
	isa        => 'Log::Dispatchouli',
	lazy_build => 1,
);

sub plugins_with 
{
    my ($self, $role) = @_;

    my $role_class = $self->root_namespace . '::Role::';
    $role =~ s/^-/$role_class/;
    
    my @plugins = grep { $_->does($role) } values %{ $self->plugins };
    return @plugins;
}

sub _build_logger
{
    return Log::Dispatchouli->new({
        ident     => 'CPAN::Local',
        to_stdout => 1,
        log_pid   => 0,
        quiet_fatal => 'stdout',
    });
  }
}

sub _build_config 
{
    my $self = shift;
    
    my $location = file( $self->root, $self->config_filename )->stringify;
    
    my $assembler = CPAN::Local::MVP::Assembler->new(
        root_namespace => $self->root_namespace,
    );
    
    return Config::MVP::Reader::Finder->read_config(
        $location, { assembler => $assembler }
    );
}

sub _build_plugins
{
    my $self = shift;

    my %plugins;

    for my $section ($self->config->sections) 
    {
        my $plugin = $section->package->new(
            %{ $section->payload },
			root   => $self->root,
			logger => $self->logger->proxy({ 
				proxy_prefix => "[" . $section->name . "] "
			),
        );
        $plugins{$section->name} = $plugin;
    }

    return \%plugins;
}

__PACKAGE__->meta->make_immutable;
