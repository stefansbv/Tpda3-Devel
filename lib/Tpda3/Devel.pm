package Tpda3::Devel;

use 5.008009;
use strict;
use warnings;
use Ouch;

use Data::Dumper;

use Getopt::Long;
use Pod::Usage;
use Term::ReadKey;
use File::Spec::Functions;
use File::ShareDir qw(dist_dir);

require Tpda3::Devel::Info::Config;
require Tpda3::Config::Utils;

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
        cfname => $opt->{cfname},
        user   => $user,
        pass   => $pass,
    };

    # Tpda3::Config->instance($args);
#    Tpda3::Devel::Info::Config->new($args);

    $self->{opt} = $opt;

    return;
}

=head2 get_options

Parse and return the command line options.

=cut

sub get_options {

    my %opt          = ();
    my $getopt_specs = {
        'G|module:s'   => \$opt{module},
        'c|config=s'   => \$opt{scrcfg},
        't|table=s'    => \$opt{table},
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

    $opt{cfname} = $ARGV[0];   # the first parameter interpreted as
                               # cfname or application name

    # Screen config file name - default is table name
    $opt{config} = $opt{table} if $opt{table} and !$opt{config};

    return \%opt;
}

=head2 process

Process.

=cut

sub process {
    my $self = shift;

    # Determine the working mode.

    my $mode;
    if (    Tpda3::Devel::Info::App::check_app_path()
        and Tpda3::Devel::Info::App::check_cfg_path() )
    {
        # Update mode
        $mode = 'update';
    }
    else {
        # Create mode
        $mode = 'create';
    }

    my $name = $self->{opt}{cfname};

    my $ret =
         $mode eq q{}       ? 'error'
       : $mode eq 'create'  ? $self->new_app($name)
       : $mode eq 'update'  ? $self->update_app($name)
       :                      die("Unknown mode: '$mode'");

    return;
}

=head2 new_app

Create new application tree and populate with files from template.

=cut

sub new_app {
    my ( $self, $module, $app_cfg ) = @_;

    my $moduledir = "Tpda3-$module";
    my $cfname    = defined($app_cfg) ? $app_cfg : lc($module);

    print " Create module dir.\n";
    Tpda3::Config::Utils->create_path($moduledir);

    print "Populate module dir.\n";
    my $sharedir = catdir( dist_dir('Tpda3-Devel'), 'dirtree' );
    my $sharedir_module = catdir( $sharedir, 'module' );
    my $sharedir_config = catdir( $sharedir, 'config' );

    File::Copy::Recursive::dircopy( $sharedir_module, $moduledir )
        or ouch 'CfgInsErr', "Failed to copy module tree to '$moduledir'";

    print " Create configuration path.\n";
    my $configdir = catdir( $moduledir, 'share', 'apps', $cfname );
    Tpda3::Config::Utils->create_path($configdir);

    print " Populate config dir.\n";
    File::Copy::Recursive::dircopy( $sharedir_config, $configdir )
        or ouch 'CfgInsErr', "Failed to copy module tree to '$configdir'";

    return;
}

=head2 update_app

Set a submode of the update mode.

=over

=item I<new-scr>     Create new screen and the coresponding config

If the I<-G> option - the screen module name, has a value.

=item I<new-cfg>     Create or update a screen config

If the I<-c> option has a value and the screen config file exists
update it else create new config.

=back

=cut

sub update_app {
    my $self = shift;

    my ( $submode, $module );
    if ( defined $self->{opt}{module} ) {

        # New screen
        $module ||= q{};    # default empty
        if ($module) {
            $submode = 'new-scr';
        }
        else {
            $submode = 'upd-scr';
        }

    }
    else {

        # New / Update config
        $submode = 'upd-scr';
    }

    print " sub mode $submode\n";

    # # Check for table name
    # my $table = $self->{opt}{table};
    # unless ($table) {
    #     print "A table name is required: -t <table>\n";
    #     $self->tables_list();
    #     exit;
    # }
    # print "Table name : $table\n";

    return;
}

=head2 check_params_gen

Check for required parameters.

=over

=item B<table> The table name

=item B<module> Screen module name

Check screen name or set screen name = table name as default

=item B<-init> <config-name>

=back

=cut

sub check_params_gen {

#    Is realy config name required?

    # # Check config name
    # my $config = $self->{opt}{config};
    # unless ($config) {
    #     die "Failed to set default config name!";
    # }

    # # Check screen name or set screen name = table name as default
    # my $screen_module = $self->{opt}{module};
    # unless ($screen_module) {
    #     die "No screen module name!";
    # }
    # unless ( lc $screen_module eq $config ) {
    #     die "Lowercased Screen name should match the config name!";
    # }

    return;
}

=head2 check_params_upd

=cut

sub check_params_upd {
    my $self = shift;

    # Check config name
    my $config = $self->{opt}{config};
    unless ($config) {
        require Tpda3::Devel::Info::Config;
        Tpda3::Devel::Info::Config->new->list_config_files;
    }

    return;
}

=head2 generate

=cut

sub generate {
    my ($self, ) = @_;

    # Make config file if not option '--no-config-gen'
    require Tpda3::Devel::Render::Config;
    my $cfg = Tpda3::Devel::Render::Config->new( $self->{opt} );

    my $config_file
        = $self->{opt}{ncg}
        ? $self->locate_config($cfg)
        : $cfg->generate_config()
        ;

    # Make screen module
    if ( $config_file and -f $config_file ) {
        print "\n Using config from\n $config_file\n";
        $self->{opt}{config_file} = $config_file;
        $self->generate_screen($config_file);
    }
    else {
        print " Failed to locate existing config file!\n";
        if ($self->{opt}{ncg}) {
            print "  Try without -g | --no-config-gen\n";
        }
    }

    return;
}

sub update {
    my $self = shift;

    my $cfg = Tpda3::Devel::Config::Update->new( $self->{opt} );

    $cfg->config_update();

    return;
}

=head2 locate_config

Locate an existing config file.

=cut

sub locate_config {
    my ($self, $cfg) = @_;

    my $scr_cfg_path = $cfg->screen_cfg_path();
    my $scr_cfg_file = $cfg->screen_cfg_file($scr_cfg_path);

    return $scr_cfg_file;
}

=head2 generate_screen

Generate screen module.

=cut

sub generate_screen {
    my ($self, $config_file) = @_;

    my $scr = Tpda3::Devel::Screen->new( $self->{opt} );
    my $screen = $scr->generate_screen($config_file);

    if ( $screen and -f $screen ) {
        print "Screen module file is '$screen'.\n";
    }
    print " done.\n";

    return;
}

=head2 version

Print application version.

=cut

sub version {
    my $self = shift;

    my $ver = $VERSION;
    print "Tpda3 Development Tools v$ver\n";
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

=head2 tables_list

List the available table names in alphabetic order.

=cut

sub tables_list {
    my $self = shift;

    # Gather info from table(s)
    require Tpda3::Devel::Info::Table;
    my $dti = Tpda3::Devel::Info::Table->new();

    my $list = $dti->table_list();
    print " > Tables:\n";
    foreach my $name ( sort @{$list} ) {
        print "   - $name\n";
    }

    return;
}

=head1 AUTHOR

Stefan Suciu, C<< <stefan@s2i2.ro> >>

=head1 BUGS

Please report any bugs or feature requests to the autor.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tpda3::Devel

=head1 ACKNOWLEDGEMENTS

Options processing and Help sub inspired from:
App::Ack (C) 2005-2011 Andy Lester.

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Stefan Suciu.

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
