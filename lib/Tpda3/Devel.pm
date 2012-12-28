package Tpda3::Devel;

use 5.008009;
use strict;
use warnings;
use Ouch;
use utf8;

use Getopt::Long;
use Pod::Usage;
use Term::ReadKey;
use File::Spec::Functions;
use File::ShareDir qw(dist_dir);
use File::Copy::Recursive;
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

=head1 NAME

Tpda3::Devel -  Tpda3 Development Tools.

=head1 VERSION

Version 0.10

=cut

our $VERSION = '0.10';

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
        param0 => $opt->{param0},
        user   => $user,
        pass   => $pass,
    };

    $self->{opt} = $opt;

    # $self->make_param_defaults();

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
        'S|screen:s'      => \$opt{screen},
        'U|update'        => \$opt{update},
        'c|config=s'      => \$opt{config},
        't|tables=s'      => \$opt{table},
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

    $opt{param0} = $ARGV[0];   # the first parameter interpreted as
                               # mnemonic or module name

    return \%opt;
}

=head2 make_param_config

Screen config parameter.

=cut

sub make_param_config {
    my $self = shift;

    my $scrcfg_name = $self->{opt}{config};

    unless ($scrcfg_name) {

        # Fallback to lc (screen-name)
        my $screen_name = $self->{opt}{screen};
        if ($screen_name) {
            $scrcfg_name = lc $screen_name;
        }
        else {
            return;
        }
    }

    my $scrcfg_fn = qq{$scrcfg_name.conf};
    my $scrcfg_ap = $self->{app_info}->get_config_ap_for('scr');
    my $scrcfg_apfn
        = $self->{app_info}->get_config_apfn_for( 'scr', $scrcfg_fn );

    $self->{opt}{config_fn}   = $scrcfg_fn;
    $self->{opt}{config_ap}   = $scrcfg_ap;
    $self->{opt}{config_apfn} = $scrcfg_apfn;

    return;
}

=head2 make_param_screen

Screen name parameter.

=cut

sub make_param_screen {
    my $self = shift;

    my $screen_name = $self->{opt}{screen};

    return unless $screen_name;

    my $screen_fn   = "$screen_name.pm";
    my $screen_ap   = $self->{app_info}->get_screen_module_ap();
    my $screen_apfn = $self->{app_info}->get_screen_module_apfn($screen_fn);

    $self->{opt}{screen_fn}   = $screen_fn;
    $self->{opt}{screen_ap}   = $screen_ap;
    $self->{opt}{screen_apfn} = $screen_apfn;

    return;
}

=head2 process_command

If the CWD is in a Tpda3 module dir, switch to I<update> mode, else to
I<create> mode and execute the appropriate method.

=cut

sub process_command {
    my $self = shift;

    if ( $self->{opt}{module} ) {

        # Create a new Tpda3 module tree

        print "Create new module\n";
        my $module   = $self->{opt}{module};
        my $mnemonic = lc $module;

        ouch 404, "New app - required parameter: <name> \n" unless $mnemonic;

        $self->{opt}{mnemonic} = $mnemonic;
        $self->{opt}{config}
            = $self->{opt}{config}
            ? $self->{opt}{config}
            : $mnemonic;

        # Other params
        die "Abort." unless $self->check_required_params('dsn');

        # Add DSN to options
        $self->parse_dsn_full( $self->{opt}{dsn} );

        $self->new_app_tree();

        return;
    }
    else {

        # Update module
        $self->{app_info} = Tpda3::Devel::Info::App->new();

        if (    $self->{app_info}->check_app_path()
            and $self->{app_info}->check_cfg_path() )
        {

            # CWD is a Tpda3 module dir.
            # Create new screen module and config file or
            #  update screen config files to the latest version.

            my $cfg_name = $self->{opt}{param0};
            $cfg_name = $self->{app_info}->get_cfg_name() unless $cfg_name;
            $self->{opt}{mnemonic} = $cfg_name;
            my $app_name = $self->{app_info}->get_app_name();
            print "Updating $app_name ($cfg_name) module\n";

            if ( $self->{opt}{update} ) {

                # Update a screen configuration file
                $self->make_param_config();    # config
                die "Abort." unless $self->check_required_params('config');
                my $tdec = Tpda3::Devel::Edit::Config->new( $self->{opt} );
                $tdec->config_update();
            }
            elsif ( $self->{opt}{screen} ) {

                # Create a new screen module
                $self->make_param_config();    # config
                $self->make_param_screen();    # screen
                die "Abort."
                    unless $self->check_required_params( 'screen', 'table' );
                $self->command_generate();
            }
            else {
                ouch 404, q{Unknown option.};
            }

            #$self->update_app();

            return;
        }
    }

    return;
}

=head2 new_app_tree

Create new module tree and populate with files from templates.

=cut

sub new_app_tree {
    my $self = shift;

    my $module  = $self->{opt}{module};
    my $appconf = $self->{opt}{mnemonic};

    ouch 404, "No module name provided?" unless $module;

    my $moduledir = qq{Tpda3-$module};

    ouch 'Abort', "Module '$moduledir' already exists!"
        if -d $moduledir;    # do not overwrite!

    print " Create module dir '$moduledir'.\n";
    Tpda3::Config::Utils->create_path($moduledir);

    print " Populate module dir.\n";
    my $sharedir = catdir( dist_dir('Tpda3-Devel'), 'dirtree' );
    my $sharedir_module = catdir( $sharedir, 'module' );
    my $sharedir_config = catdir( $sharedir, 'config' );

    $File::Copy::Recursive::KeepMode = 0; # mode 644

    File::Copy::Recursive::dircopy( $sharedir_module, $moduledir )
        or ouch 'CfgInsErr', "Failed to copy module tree to '$moduledir'";

    print " Create config path '$appconf'.\n";
    my $configdir = catdir( $moduledir, 'share', 'apps', $appconf );
    Tpda3::Config::Utils->create_path($configdir);

    print " Populate config dir.\n";
    File::Copy::Recursive::dircopy( $sharedir_config, $configdir )
        or ouch 'CfgInsErr', "Failed to copy module tree to '$configdir'";

    print " Make module module. '$module'\n";
    my $tdrm = Tpda3::Devel::Render::Module->new( $self->{opt} );
    my $libapp_path = $tdrm->generate_module();

    my $scrmoduledir = catdir($libapp_path, $module);
    print " Create screens module dir '$scrmoduledir'.\n";
    Tpda3::Config::Utils->create_path($scrmoduledir);

    print " Make Makefile.PL script.\n";
    my $tdrmk = Tpda3::Devel::Render::Makefile->new( $self->{opt} );
    $tdrmk->generate_makefile();

    print " Make etc/*.yml configs.\n";
    my $tdry = Tpda3::Devel::Render::YAML->new( $self->{opt} );
    $tdry->generate_config('cfg-application', 'application.yml');
    $tdry->generate_config('cfg-menu', 'menu.yml');
    $tdry->generate_config('cfg-connection', 'connection.yml');

    print " Make t/*.t test scripts.\n";
    my $tdrt = Tpda3::Devel::Render::Test->new( $self->{opt} );
    $tdrt->generate_test('test-load', '00-load.t');
    $tdrt->generate_test('test-config', '10-config.t');
    $tdrt->generate_test('test-connection', '20-connection.t');

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

    # Check config name
    my $config = $self->{opt}{config};
    unless ($config) {
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

    # Gather info from the database
    Tpda3::Devel::Info::Config->new( $self->{opt} );
    my $dti = Tpda3::Devel::Info::Table->new();
    my $list = $dti->table_list();
    print " > Tables:\n";
    foreach my $name ( sort @{$list} ) {
        print "   - $name\n";
    }

    return;
}

=head2 command_generate

Generate screen config and module.

=cut

sub command_generate {
    my $self = shift;

    #-- Check if config file exists and make new if not

    my $config_file = $self->locate_config();
    if ($config_file) {
        print "Use existing screen config file: $config_file\n";
    }
    else {
        my $conf = Tpda3::Devel::Render::Config->new( $self->{opt} );
        $config_file = $conf->generate_config();
    }

    #-- Make screen module

    my $scr    = Tpda3::Devel::Render::Screen->new( $self->{opt} );
    my $screen = $scr->generate_screen($config_file);

    return;
}

=head2 locate_config

Try to locate an existing config file and return the name if found.

=cut

sub locate_config {
    my $self = shift;

    my $scrcfg_fn = $self->{opt}{config_fn};

    return $scrcfg_fn if -f $self->{opt}{config_apfn};
}

=head2 version

Print module version.

=cut

sub version {
    my $self = shift;

    my $ver = $VERSION;
    print "Tpda3 Development Tools v$ver\n";
    print "(C) 2010-2012 Ştefan Suciu\n\n";

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

    my @dsn = split /;/, $driver_dsn;
    if (scalar @dsn) {
        foreach my $rec (@dsn) {
            my ($key, $value) = split /=/, $rec, 2;
            $self->{opt}{$key} = $value;
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

Copyright 2012 Ştefan Suciu.

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
