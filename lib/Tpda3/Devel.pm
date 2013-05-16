package Tpda3::Devel;

use 5.008009;
use strict;
use warnings;
use utf8;

use Getopt::Long;
use Pod::Usage;
use File::Spec::Functions;
use File::ShareDir qw(dist_dir);
use File::Copy;
use File::Copy::Recursive;
use File::UserConfig;
use DBI 1.43;                        # minimum version for 'parse_dsn'

require Tpda3::Config::Utils;

require Tpda3::Devel::Info::App;
require Tpda3::Devel::Info::Config;
require Tpda3::Devel::Info::Table;
require Tpda3::Devel::Render::Module;
require Tpda3::Devel::Render::Config;
require Tpda3::Devel::Render::Screen;
require Tpda3::Devel::Render::Makefile;
require Tpda3::Devel::Render::YAML;
require Tpda3::Devel::Render::Test;
require Tpda3::Devel::Edit::Config;
require Tpda3::Devel::Edit::Menu;

=head1 NAME

Tpda3::Devel -  Tpda3 Development Tools.

=head1 VERSION

Version 0.13

=cut

our $VERSION = '0.13';

=head1 DESCRIPTION

Helper tool for application development.

Features:

Create new application project.

Create new screen module and the coresponding configuration file.  If
the screen config exists use it.

Update the screen configuration file (to the current version).

=head1 SYNOPSIS

    use Tpda3::Devel;

    my $foo = Tpda3::Devel->new();

=head1 METHODS

=head2 new

=cut

sub new {
    my ( $class, $opt ) = @_;

    my $self = {};

    bless $self, $class;

    $self->_init($opt);

    return $self;
}

=head2 _init

Initializations.

=cut

sub _init {
    my ( $self, $opt ) = @_;

    my $user = $opt->{user};
    my $pass = $opt->{pass};

    my $args = {
        user   => $user,
        pass   => $pass,
    };

    $self->{opt} = $opt;

    return;
}

=head2 get_options

Parse and return the command line options.

Parameters:
 -A, --module             : create new application module
 -c, --config             : screen config file name without
                            the suffix (.conf)
 -t table-main, table-dep : the database main table name and
                            optional dependent table
 -S, --screen             : screen module name without the suffix (.pm)
 -U, --update             : update screen config file
 -u, --user               : user name
 -p, --password           : password

=cut

sub get_options {

    my %opt          = ();
    my $getopt_specs = {
        'A|module=s' => \$opt{module},
        'd|dsn=s'         => \$opt{dsn},
        'S|screen=s'      => \$opt{screen},
        'U|update'        => \$opt{update},
        't|tables:s'      => \$opt{table},
        'u|user=s'        => \$opt{user},
        'p|password=s'    => \$opt{pass},
        'l|list:s'        => \$opt{list},
        'help|?'          => sub { usage(1) },
        'm|man'           => sub { usage(2) },
    };

    my $parser = Getopt::Long::Parser->new();
    $parser->configure( 'bundling', 'no_ignore_case', );
    $parser->getoptions( %{$getopt_specs} ) or
        die( 'See tpda3d --help, tpda3d --man for usage.' );

    return \%opt;
}

=head2 init_params_config

Screen config parameter.

=cut

sub init_params_config {
    my $self = shift;

    # Fallback to lc (screen-name)
    my $scrcfg_name;
    my $screen_name = $self->{opt}{screen};
    if ($screen_name) {
        $scrcfg_name = lc $screen_name;
    }
    else {
        die "No screen config name!\n";
    }

    my $scrcfg_fn = qq{$scrcfg_name.conf};
    my $scrcfg_ap = $self->{info}->get_config_ap_for('scr');
    my $scrcfg_apfn
        = $self->{info}->get_config_apfn_for( 'scr', $scrcfg_fn );

    $self->{opt}{config_fn}   = $scrcfg_fn;
    $self->{opt}{config_ap}   = $scrcfg_ap;
    $self->{opt}{config_apfn} = $scrcfg_apfn;

    my $menu_fn = qq{menu.yml};
    my $menu_ap = $self->{info}->get_config_ap_for('etc');
    my $menu_apfn
        = $self->{info}->get_config_apfn_for( 'etc', $menu_fn );

    $self->{opt}{menu_fn}   = $menu_fn;
    $self->{opt}{menu_ap}   = $menu_ap;
    $self->{opt}{menu_apfn} = $menu_apfn;

    return;
}

=head2 init_params_screen

Screen name parameter.

=cut

sub init_params_screen {
    my $self = shift;

    my $screen_name = $self->{opt}{screen};

    return unless $screen_name;

    my $screen_fn   = "$screen_name.pm";
    my $screen_ap   = $self->{info}->get_screen_module_ap();
    my $screen_apfn = $self->{info}->get_screen_module_apfn($screen_fn);

    $self->{opt}{screen_fn}   = $screen_fn;
    $self->{opt}{screen_ap}   = $screen_ap;
    $self->{opt}{screen_apfn} = $screen_apfn;

    return;
}

=head2 process_command


=cut

sub process_command {
    my $self = shift;

    # Create a new Tpda3 module tree
    if ( $self->{opt}{module} ) {
        my $module   = $self->{opt}{module};
        my $mnemonic = lc $module;

        die "New app - required parameter: <name> \n" unless $mnemonic;

        $self->{opt}{mnemonic} = $mnemonic;

        # Other params
        die "Abort." unless $self->check_required_params('dsn');

        # Add DSN to options
        $self->parse_dsn_full( $self->{opt}{dsn} );

        $self->make_app_tree();
    }
    else {

        # Update module
        $self->{info} = Tpda3::Devel::Info::App->new();

        if (    $self->{info}->check_app_path()
            and $self->{info}->check_cfg_path() )
        {

            # CWD is a Tpda3 module dir.
            # Create new screen module and config file or
            #  update screen config files to the latest version.

            my $cfg_name = $self->{info}->get_cfg_name();
            unless ($cfg_name) {
                die "Can't determine mnemonic name.";
            }
            $self->{opt}{mnemonic} = $cfg_name;
            my $app_name = $self->{info}->get_app_name();
            print "Updating $app_name module ($cfg_name)\n";

            if ( $self->{opt}{update} ) {

                # Update a screen configuration file
                $self->init_params_config();    # config
                die "Abort." unless $self->check_required_params('config');
                my $tdec = Tpda3::Devel::Edit::Config->new( $self->{opt} );
                $tdec->config_update();
            }
            elsif ( $self->{opt}{screen} ) {

                # Create a new screen module
                $self->init_params_config();    # config
                $self->init_params_screen();    # screen
                die "Abort."
                    unless $self->check_required_params( 'screen', 'table' );
                $self->generate_screen();
            }
            elsif ( defined $self->{opt}{table} ) {
                $self->list_tables();
            }
            else {
                die q{Unknown option.};
            }
        }
    }

    print "\n";

    return;
}

=head2 make_app_tree

Create new module tree and populate with files from templates.

=cut

sub make_app_tree {
    my $self = shift;

    my $module  = $self->{opt}{module};
    my $appconf = $self->{opt}{mnemonic};

    die "No module name provided?" unless $module;

    my $moduledir = qq{Tpda3-$module};

    die "Module '$moduledir' already exists!"
        if -d $moduledir;    # do not overwrite!

    print "Creating module '$moduledir' ...\r";

    Tpda3::Config::Utils->create_path($moduledir);

    # Populate module dir
    my $sharedir = catdir( dist_dir('Tpda3-Devel'), 'dirtree' );
    my $sharedir_module = catdir( $sharedir, 'module' );
    my $sharedir_config = catdir( $sharedir, 'config' );

    $File::Copy::Recursive::KeepMode = 0; # mode 644

    File::Copy::Recursive::dircopy( $sharedir_module, $moduledir )
        or die "Failed to copy module tree to '$moduledir'";

    # Create config path '$appconf'
    my $configdir = catdir( $moduledir, 'share', 'apps', $appconf );
    Tpda3::Config::Utils->create_path($configdir);

    # Populate config dir
    File::Copy::Recursive::dircopy( $sharedir_config, $configdir )
        or die "Failed to copy module tree to '$configdir'";

    my $tdrm = Tpda3::Devel::Render::Module->new( $self->{opt} );
    my $libapp_path = $tdrm->generate_module();

    my $scrmoduledir = catdir($libapp_path, $module);
    # Create screens module dir
    Tpda3::Config::Utils->create_path($scrmoduledir);

    # Make Makefile.PL script
    my $tdrmk = Tpda3::Devel::Render::Makefile->new( $self->{opt} );
    $tdrmk->generate_makefile();

    # Make README file
    my $tdrrm = Tpda3::Devel::Render::Readme->new( $self->{opt} );
    $tdrrm->generate_readme();

    # Make etc/*.yml configs
    my $tdry = Tpda3::Devel::Render::YAML->new( $self->{opt} );
    $tdry->generate_config( 'cfg-application', 'application.yml' );
    $tdry->generate_config( 'cfg-menu',        'menu.yml' );
    $tdry->generate_config( 'cfg-connection',  'connection.yml' );

    # Make t/*.t test scripts
    my $tdrt = Tpda3::Devel::Render::Test->new( $self->{opt} );
    $tdrt->generate_test('test-load', '00-load.t');
    $tdrt->generate_test('test-config', '10-config.t');
    $tdrt->generate_test('test-connection', '20-connection.t');

    print "Creating module '$moduledir' ... done\n";

    return;
}

=head2 check_required_params

Check a list of parameters.

=cut

sub check_required_params {
    my ($self, @req) = @_;

    my $check = 0;
    my $count = 0;
    foreach my $para (@req) {
        if ( exists $self->{opt}{$para} and $self->{opt}{$para} ) {
            $check++;
        }
        else {
            print "  Required parameter: -$para\n";
            my $method = "help_$para";
            $self->$method if $self->can($method); # show some help
            $check--;
        }
        $count++;
    }

    return ($check == $count);
}

=head2 help_config

Show list of the available app configs.
TODO: list config files from project dir.

=cut

sub help_config {
    my $self = shift;

    unless ( $self->{opt}{mnemonic} ) {
        Tpda3::Devel::Info::Config->new->list_scrcfg_files();
    }

    return;
}

=head2 help_table

Show list of the available tables (and views?) in the database.

=cut

sub help_table {
    my $self = shift;

    # Check table name (again)
    my $tables = $self->{opt}{table};
    return if $tables;

    $self->list_tables();

    return;
}

=head2 help_table

List the table names from the database.

=cut

sub list_tables {
    my $self = shift;

    Tpda3::Devel::Info::Config->new( $self->{opt} );
    my $dti = Tpda3::Devel::Info::Table->new();
    my $list = $dti->table_list();
    my $table_no = scalar @{$list};
    print " > Tables [$table_no]:\n";
    foreach my $name ( sort @{$list} ) {
        print "   - $name\n";
    }

    return;
}

=head2 generate_screen

Generate screen config and module.

=cut

sub generate_screen {
    my $self = shift;

    #-- Make screen config and module

    Tpda3::Devel::Render::Config->new( $self->{opt} )->generate_config();
    Tpda3::Devel::Render::Screen->new( $self->{opt} )->generate_screen();

    # Add to screen menu
    Tpda3::Devel::Edit::Menu->new( $self->{opt} )->menu_update();

    #-- Install screen config in user's home
    $self->install_configs();

    return;
}

=head2 install_configs

Install the screen config and the updated menu config file in the
user's home path.

=cut

sub install_configs {
    my $self = shift;

    print "Installing screen config ...\r";

    my $config_fn   = $self->{opt}{config_fn};
    my $config_apfn = $self->{opt}{config_apfn};
    my $config_ap   = $self->get_user_path_for('scr');

    if ( -f catfile($config_ap, $config_fn) ) {
        print "Installing screen config .. skipped\n";
    }
    else {
        copy($config_apfn, $config_ap) or die "Install failed: $!";
        print "Installing screen config ..... done\n";
    }

    print "Installing application menu ..\r";

    my $menu_fn   = $self->{opt}{menu_fn};
    my $menu_apfn = $self->{opt}{menu_apfn};
    my $menu_ap   = $self->get_user_path_for('etc');

    copy($menu_apfn, $menu_ap) or die "Install failed: $!";

    print "Installing application menu .. done\n";

    return;
}

=head2 get_user_path_for

Return the user configurations path.

=cut

sub get_user_path_for {
    my ($self, $path) = @_;

    my $configpath = File::UserConfig->new(
        dist     => 'Tpda3',
        sharedir => 'share',
    )->configdir;

    my $ap = catdir( $configpath, 'apps', $self->{opt}{mnemonic}, $path );
    die "Nonexistent user path $ap\n" unless -d $ap;

    return $ap;
}

=head2 version

Print module version.

=cut

sub version {
    my $self = shift;

    print "Tpda3 Development Tools v$VERSION\n";
    print "(C) 2010-2012 Stefan Suciu\n\n";

    return;
}

=head2 usage

Usage.

=cut

sub usage {
    my $verbose = shift;

    version();

    require Pod::Usage;
    Pod::Usage::pod2usage(
        {   -verbose => $verbose,
            -exitval => 0,
        }
    );

    return;
}

=head2 usage_info

Print a specific usage message.

=cut

sub usage_info {
    my $message = shift;

    print "\n$message\n\n";
    usage(1);

    exit;
}

=head2 parse_dsn_full

Add DSN to opts.

=cut

sub parse_dsn_full {
    my ($self, $dsn) = @_;

    my ( $scheme, $driver, undef, undef, $driver_dsn ) =
        DBI->parse_dsn($dsn)
            or die "Can't parse DBI DSN '$dsn'";

    $self->{opt}{driver} = $driver;

    my @dsn = split /;/, $driver_dsn;
    if (scalar @dsn) {
        foreach my $rec (@dsn) {
            my ($key, $value) = split /=/, $rec, 2;
            $key eq 'database'
                ? ( $self->{opt}{dbname} = $value )
                : ( $self->{opt}{$key} = $value   );
        }
    }

    return;
}

=head1 AUTHOR

Ştefan Suciu, C<< <stefan la s2i2.ro> >>

=head1 BUGS

Please report any bugs or feature requests to the autor.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tpda3::Devel

=head1 ACKNOWLEDGEMENTS

Options processing and Help sub inspired from:
App::Ack (C) 2005-2011 Andy Lester.

=head1 LICENSE AND COPYRIGHT

Copyright 2012-2013 Ștefan Suciu

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; version 2 dated June, 1991 or at your option
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

A copy of the GNU General Public License is available in the source tree;
if not, write to the Free Software Foundation, Inc.,
59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

=cut

1; # End of Tpda3::Devel
