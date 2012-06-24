package Tpda3::Devel;

use 5.008009;
use strict;
use warnings;

use Data::Dumper;
use Ouch;
use utf8;

use Getopt::Long;
use Pod::Usage;
use Term::ReadKey;
use File::Spec::Functions;
use File::ShareDir qw(dist_dir);
use File::Copy::Recursive;

require Tpda3::Devel::Info::App;
require Tpda3::Devel::Info::Config;
require Tpda3::Config::Utils;
require Tpda3::Devel::Info::Table;
require Tpda3::Devel::Render::NewApp;
require Tpda3::Devel::Render::Config;
require Tpda3::Devel::Render::Screen;
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

    $self->{app_info} = Tpda3::Devel::Info::App->new();

    $self->{param} = $opt;

    # $self->make_param_defaults();

    return;
}

=head2 get_options

Parse and return the command line options.

Parameters:
 <app-name> | <app-conf>
 -c config                : screen config file name without
                            the suffix (.conf)
 -t table-main, table-dep : the database main table name and
                            optional dependent table
 -S screen                : screen module name without the suffix (.pm)
 -U                       : update screen config file
 -u, --user               : user name
 -p, --password           : password

=cut

sub get_options {

    my %opt          = ();
    my $getopt_specs = {
        'S|screen:s'   => \$opt{screen},
        'U|update'     => \$opt{update},
        'c|config=s'   => \$opt{config},
        't|tables=s'   => \$opt{table},
        'u|user=s'     => \$opt{user},
        'p|password=s' => \$opt{pass},
        'l|list:s'     => \$opt{list},
        'help|?'       => sub { usage(1) },
        'm|man'        => sub { usage(2) },
    };

    my $parser = Getopt::Long::Parser->new();
    $parser->configure( 'bundling', 'no_ignore_case', );
    $parser->getoptions( %{$getopt_specs} ) or
        die( 'See tpda3d --help, tpda3d --man for usage.' );

    $opt{param0} = $ARGV[0];   # the first parameter interpreted as
                               # cfname or application name

    return \%opt;
}

=head2 make_param_config

Screen config parameter.

=cut

sub make_param_config {
    my $self = shift;

    my $scrcfg_name = $self->{param}{config};

    unless ($scrcfg_name) {

        # Fallback to lc (screen-name)
        my $screen_name = $self->{param}{screen};
        if ($screen_name) {
            $scrcfg_name = lc $screen_name;
        }
        else {
            die "Can not determine config name!";
        }
    }

    my $scrcfg_fn   = "$scrcfg_name.conf";
    my $scrcfg_ap   = $self->{app_info}->get_screen_config_ap();
    my $scrcfg_apfn = $self->{app_info}->get_screen_config_apfn($scrcfg_fn);

    $self->{param}{config_fn}   = $scrcfg_fn;
    $self->{param}{config_ap}   = $scrcfg_ap;
    $self->{param}{config_apfn} = $scrcfg_apfn;

    return;
}

=head2 make_param_screen

Screen name parameter.

=cut

sub make_param_screen {
    my $self = shift;

    my $screen_name = $self->{param}{screen};

    return unless $screen_name;

    my $screen_fn   = "$screen_name.pm";
    my $screen_ap   = $self->{app_info}->get_screen_module_ap();
    my $screen_apfn = $self->{app_info}->get_screen_module_apfn($screen_fn);

    $self->{param}{screen_fn}   = $screen_fn;
    $self->{param}{screen_ap}   = $screen_ap;
    $self->{param}{screen_apfn} = $screen_apfn;

    return;
}

=head2 process_command

If the CWD is in a Tpda3 module dir, switch to I<update> mode, else to
I<create> mode and execute the appropriate method.

=cut

sub process_command {
    my $self = shift;

    my $mode;
    if (    $self->{app_info}->check_app_path()
        and $self->{app_info}->check_cfg_path() )
    {

        # CWD is a Tpda3 application dir.
        # Create new screen module and config file or
        #  update screen config files to the latest version.

        my $cfg_name = $self->{param}{param0};    # pam pam ;)
        $cfg_name    = $self->{app_info}->get_cfg_name() unless $cfg_name;
        $self->{param}{cfname} = $cfg_name;
        my $app_name = $self->{app_info}->get_app_name();
        print "Update application: $app_name ($cfg_name)\n";

        if ( $self->{param}{update} ) {

            # Update a screen configuration file
            $self->make_param_config();       # config
            die "Abort." unless $self->check_required_params('config');
            my $tdec = Tpda3::Devel::Edit::Config->new( $self->{param} );
            $tdec->config_update();
        }
        else {

            # Create a new screen module
            $self->make_param_screen();       # screen
            $self->make_param_config();       # config
            die "Abort."
                unless $self->check_required_params( 'screen', 'table' );
            $self->command_generate();
        }

        # $self->update_app();
        return;
    }
    else {

        # Create a new Tpda3 application tree

        print "Create new application\n";
        my $name = $self->{param}{param0};    # pam pam ;)
        die "New app - required parameter: <name> \n" unless $name;
        $self->{param}{cfname} = $name;
        $self->{param}{config}
            = $self->{param}{config}
            ? $self->{param}{config}
            : lc($name);    # app-cfg defaults to lc(app-name)

        $self->new_app_tree();

        return;
    }

    die "What to do?";

    return;
}

=head2 new_app_tree

Create new application tree and populate with files from templates.

=cut

sub new_app_tree {
    my $self = shift;

    my $module  = $self->{param}{appname};
    my $appconf = $self->{param}{appconf};

    my $moduledir = "Tpda3-$module";

    ouch 'Abort', "Application '$moduledir' already exists!"
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

    print " Make application module. '$module'\n";
    my $newapp = Tpda3::Devel::Render::NewApp->new( $self->{param} );
    my $libapp_path = $newapp->generate_newapp();

    my $scrmoduledir = catdir($libapp_path, $module);
    print " Create screens module dir '$scrmoduledir'.\n";
    Tpda3::Config::Utils->create_path($scrmoduledir);

    return;
}

=head2 update_app

Create new screen and the config file ...

=cut

sub update_app {
    my $self = shift;

    if ( defined $self->{param}{screen} ) {
        my $module = $self->{param}{screen};
        print " New screen:\n";
        die "Abort." unless $self->check_required_params( 'screen', 'table' );
        $self->command_generate();
    }

    if ( $self->{param}{update} ) {
        die "Abort." unless $self->check_required_params('config');
        my $tdec = Tpda3::Devel::Edit::Config->new( $self->{param} );
        $tdec->config_update();
    }

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
        if ( exists $self->{param}{$para} and $self->{param}{$para} ) {
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

=cut

sub help_config {
    my $self = shift;

    # Check config name
    my $config = $self->{param}{config};
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
    my $tables = $self->{param}{table};
    return if $tables;

    # Gather info from the database
    Tpda3::Devel::Info::Config->new( $self->{param} );
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
        my $conf = Tpda3::Devel::Render::Config->new( $self->{param} );
        $config_file = $conf->generate_config();
    }

    #-- Make screen module

    my $scr    = Tpda3::Devel::Render::Screen->new( $self->{param} );
    my $screen = $scr->generate_screen($config_file);

    return;
}

=head2 locate_config

Try to locate an existing config file and return the name if found.

=cut

sub locate_config {
    my $self = shift;

    my $scrcfg_fn = $self->{param}{config_fn};

    return $scrcfg_fn if -f $self->{param}{config_apfn};
}

=head2 version

Print application version.

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

=head1 AUTHOR

Ştefan Suciu, C<< <stefan@s2i2.ro> >>

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
