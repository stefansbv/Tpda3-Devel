package Tpda3::Devel::Command::Create;

use 5.010001;
use strict;
use warnings;

use File::Spec::Functions;
use File::ShareDir qw(dist_dir);
use File::Copy;
use File::Copy::Recursive qw(dircopy);
use File::UserConfig;
use DBI 1.43;                        # minimum version for 'parse_dsn'

require Tpda3::Devel::Render::Module;
require Tpda3::Devel::Render::Config;
require Tpda3::Devel::Render::Makefile;
require Tpda3::Devel::Render::YAML;
require Tpda3::Devel::Render::Test;
require Tpda3::Devel::Render::Readme;

use base qw( CLI::Framework::Command );

sub usage_text {
    q{
    create [-n <name> -d <dsn>]

    OPTIONS
       --name|-n <name>:            the name of the application
       --dsn |-d <dsn>:              the DSN to connect to the DB
    }
}

sub option_spec {
    [ 'name|n=s', 'the name of the application',  { required => 1 } ],
    [ 'dsn|d=s' , 'the DSN to connect to the DB', { required => 1 } ],
}

sub validate_options {
    my ($self, $opts) = @_;
    # ...nothing to check for this application
}

sub run {
    my ($self, $opts, @args) = @_;

    my $dsn_href = $self->parse_dsn_full( $opts->dsn );
    $self->new_app($opts, $dsn_href);

    return;
}

sub new_app {
    my ($self, $args, $dsn_href) = @_;

    my $module   = $args->name;
    my $mnemonic = lc $module;

    die "New app - required parameter: <name> \n" unless $mnemonic;

    $args->{mnemonic} = $mnemonic;
    $args->{dsn}      = $dsn_href;

    $self->make_app_tree($args);

    return;
}

sub make_app_tree {
    my ( $self, $args ) = @_;

    my $module   = $args->{name};
    my $mnemonic = $args->{mnemonic};

    die "No module name provided?" unless $module;

    my $moduledir = qq{Tpda3-$module};

    die "Module '$moduledir' already exists!"
        if -d $moduledir;    # do not overwrite!

    print "Creating module >$moduledir< ...\r";

    Tpda3::Config::Utils->create_path($moduledir);

    # Populate module dir
    my $sharedir        = catdir( dist_dir('Tpda3-Devel'), 'dirtree' );
    my $sharedir_module = catdir( $sharedir,               'module' );
    my $sharedir_config = catdir( $sharedir,               'config' );
    my $moduledir_inc   = catdir( $moduledir,              'inc' );
    my $sharedir_inc    = catdir( $sharedir,               'inc' );

    $File::Copy::Recursive::KeepMode = 0;    # mode 644

    dircopy( $sharedir_module, $moduledir )
        or die "Failed to copy module tree to '$moduledir'";

    # Create config path '$mnemonic'
    my $configdir = catdir( $moduledir, 'share', 'apps', $mnemonic );
    Tpda3::Config::Utils->create_path($configdir);

    # Populate config dir
    dircopy( $sharedir_config, $configdir )
        or die "Failed to copy module tree to '$configdir'";

    # Populate inc dir
    dircopy( $sharedir_inc, $moduledir_inc )
        or die "Failed to copy inc tree to '$moduledir_inc'";

    my $opts = {
        module   => $module,
        dsn      => $args->{dsn},
        mnemonic => $mnemonic,
    };

    my $tdrm        = Tpda3::Devel::Render::Module->new;
    my $libapp_path = $tdrm->generate_module($opts);

    my $scrmoduledir = catdir( $libapp_path, $module );

    # Create screens module dir
    Tpda3::Config::Utils->create_path($scrmoduledir);

    # Make Makefile.PL script
    my $tdrmk = Tpda3::Devel::Render::Makefile->new;
    $tdrmk->generate_makefile($opts);

    # Make README file
    my $tdrrm = Tpda3::Devel::Render::Readme->new;
    $tdrrm->generate_readme($opts);

    # Make etc/*.yml configs
    my $tdry = Tpda3::Devel::Render::YAML->new;
    $tdry->generate_config( $opts, 'cfg-application', 'application.yml' );
    $tdry->generate_config( $opts, 'cfg-menu',        'menu.yml' );
    $tdry->generate_config( $opts, 'cfg-connection',  'connection.yml' );

    # Make t/*.t test scripts
    my $tdrt = Tpda3::Devel::Render::Test->new;
    $tdrt->generate_test( $opts, 'test-load',       '00-load.t' );
    $tdrt->generate_test( $opts, 'test-config',     '10-config.t' );
    $tdrt->generate_test( $opts, 'test-connection', '20-connection.t' );

    print "Creating module '$moduledir' ... done\n";

    return;
}

sub parse_dsn_full {
    my ($self, $dsn) = @_;

    my ( $scheme, $driver, undef, undef, $driver_dsn ) =
        DBI->parse_dsn($dsn)
            or die "Can't parse DBI DSN: '$dsn'\n";

    my $dsn_pieces = {};
    $dsn_pieces->{driver} = $driver;

    my @dsn = split /;/, $driver_dsn;
    if (scalar @dsn) {
        foreach my $rec (@dsn) {
            my ($key, $value) = split /=/, $rec, 2;
            $key eq 'database'
                ? ( $dsn_pieces->{dbname} = $value )
                : ( $dsn_pieces->{$key}   = $value );
        }
    }

    return $dsn_pieces;
}

1;
