package Tpda3::Devel;

# ABSTRACT: Development helper tool for Tpda3

use 5.010001;
use strict;
use warnings;

use Tpda3::Devel::Utils;
require Tpda3::Config;
require Tpda3::Devel::Info::App;

use base qw( CLI::Framework );         # pod: CLI::Framework::Tutorial

sub usage_text {
    my $self = shift;
    q{
tpda3d [-u <username>] [-p <password>] <command>

    OPTIONS:
        -u,--user          user name
        -p,--pass          password

    COMMANDS:
        commands           list available commands
        i,info             list info about...

        new,create         create a new Tpda3 application distribution

        gen,generate       generate a screen module and a screen configuration
        upd,update         update screen configuration
} . "\n" . $self->app_context . "\n";
}

sub option_spec {
    [ 'user|u=s'  => 'database user name' ],
    [ 'pass|p=s'  => 'database password' ],
}

sub validate_options {
    my ($self, $opts) = @_;
    # ...nothing to check for this application
}

sub command_map {
    # Commands
    alias    => 'CLI::Framework::Command::Alias',
    commands => 'CLI::Framework::Command::List',
    info     => 'Tpda3::Devel::Command::Print',
    create   => 'Tpda3::Devel::Command::Create',
    update   => 'Tpda3::Devel::Command::Update',
    generate => 'Tpda3::Devel::Command::Generate',
}

sub command_alias {
    # Command aliases
    i   => 'info',
    upd => 'update',
    new => 'create',
    gen => 'generate',
}

=head2 init

This initialization is performed once for the application (default
behavior).

=cut

sub init {
    my ($app, $opts) = @_;

    # Where are we?
    my $info = Tpda3::Devel::Info::App->new();
    if ( $info->is_app_dir ) {

        # CWD is a Tpda3 module dir.
        my $mnemonic = $info->get_cfg_name();
        die "Can't determine mnemonic name." unless $mnemonic;
        my $user = $opts->user;
        my $pass = $opts->pass;
        my $args = {
            cfname => $mnemonic,
            user   => $user,
            pass   => $pass,
        };
        my $config = Tpda3::Config->instance($args);
        $app->cache->set( 'config' => $config );
        my $name = $info->get_app_name;
        $app->cache->set( 'context' => 'upd' );
        $app->cache->set( 'appname' => $name );
    }
    else {
        my $config = Tpda3::Config->instance;
        $app->cache->set( 'config' => $config );
        $app->cache->set( 'context' => 'new' );
        $app->cache->set( 'appname' => 'none' );
    }

    return 1;
}

1;
