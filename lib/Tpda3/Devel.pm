package Tpda3::Devel;

use 5.008009;
use strict;
use warnings;

use Data::Dumper;

use Getopt::Long;
use Pod::Usage;
use Term::ReadKey;
use File::ShareDir qw(dist_dir);
use File::Spec::Functions;

require Tpda3::Config;
require Tpda3::Devel::Config;
require Tpda3::Devel::Screen;
require Tpda3::Devel::Config::Update;

=head1 NAME

Tpda3::Devel - The great new Tpda3::Devel!

=head1 VERSION

Version 0.10

=cut

our $VERSION = '0.10';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Tpda3::Devel;

    my $foo = Tpda3::Devel->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

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
    # my $user = $opt->{user} ? $opt->{user} : $self->read_username();
    my $pass = $opt->{pass};
    # my $pass = $opt->{pass} ? $opt->{pass} : $self->read_password();

    my $args = {
        cfname => $opt->{cfname},
        user   => $user,
        pass   => $pass,
    };

    Tpda3::Config->instance($args);

    $self->{opt} = $opt;

    return;
}

=head2 get_options

Parse command line options.

=cut

sub get_options {

    my %opt = ();
    my $getopt_specs = {
        'G|generate'    => \$opt{generate},
        'U|update'      => \$opt{update},
        's|skip-config' => \$opt{skip_config},
        'c|config=s'    => \$opt{config},
        'M|module=s'    => \$opt{module},
        't|table:s'     => \$opt{table},
        'u|user=s'      => \$opt{user},
        'p|password=s'  => \$opt{pass},
        'l|list:s'      => \$opt{list},
        'help|?:s'      => sub { shift; help(@_); exit; },
        'm|man'         => sub {
            require Pod::Usage;
            Pod::Usage::pod2usage(
                {   -verbose => 2,
                    -exitval => 0,
                }
            );
        },
    };

    my $parser = Getopt::Long::Parser->new();
    $parser->configure( 'bundling', 'no_ignore_case', );
    $parser->getoptions( %{$getopt_specs} ) or
        die( 'See tpda3d --help, tpda3d --man for usage.' );

    # Where are module-level shared data files kept
    my $templ_path = catdir( dist_dir('Tpda3-Devel'), 'templates');

    my $cfname = $ARGV[0];                # runtime configuration name

    my %defaults = (
        cfname     => $cfname,
        max_len    => 30,
        templ_path => $templ_path,    # TT templates path
    );

    # Screen config file name - default is table name
    $opt{config} = $opt{table}
        if $opt{table} and !$opt{config};

    # Screen module file name - default is config name
    $opt{module} = ucfirst $opt{config}
        if $opt{config} and !$opt{module};

    while ( my ( $key, $value ) = each %defaults ) {
        unless ( defined $opt{$key} ) {
            $opt{$key} = $value;
        }
    }

    return \%opt;
}

=head2 process

Process.

=cut

sub process {
    my $self = shift;

    unless ( $self->{opt}{cfname} ) {
        help(' A configuration name is required! ');
        exit;
    }

    if ( $self->{opt}{generate} and $self->{opt}{update} ) {
        help( " -G or -U, not both! " );
        exit;
    }

    if ( $self->{opt}{generate} ) {
        $self->check_params_gen();
        $self->generate();
    }
    elsif ( $self->{opt}{update} ) {
        $self->check_params_upd();
        $self->update();
    }
    else {
        help( " -G or -U is required! " );
        exit;
    }

    return;
}

sub check_params_gen {
    my $self = shift;

    # Check for table name
    my $table = $self->{opt}{table};
    unless ($table) {
        $self->tables_list();
        help_generate();
        die "Table name is required!";
    }
    print "Table name : $table\n";

    # Check config name
    my $config = $self->{opt}{config};
    unless ($config) {
        die "Failed to set default config name!";
    }

    # Check screen name or set screen name = table name as default
    my $screen_module = $self->{opt}{module};
    unless ($screen_module) {
        die "No screen module name!";
    }
    unless ( lc $screen_module eq $config ) {
        die "Lowercased Screen name should match the config name!";
    }

    return;
}

=head2 check_params_upd



=cut

sub check_params_upd {
    my $self = shift;

    # Check config name
    my $config = $self->{opt}{config};
    unless ($config) {
        $self->config_list();
        die "The config name is required!";
    }

    return;
}

=head2 generate



=cut

sub generate {
    my ($self, ) = @_;

    # Make config file if not option '--no-config-gen'
    my $cfg = Tpda3::Devel::Config->new( $self->{opt} );

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

=head2 tables_list

List the available table names.

=cut

sub tables_list {
    my $self = shift;

    # Gather info from table(s)
    require Tpda3::Devel::Table::Info;
    my $dti = Tpda3::Devel::Table::Info->new();

    my $list = $dti->table_list();
    print " > Tables:\n";
    foreach my $name ( @{$list} ) {
        print "   - $name\n";
    }

    return;
}

sub config_list {
    my $self = shift;

    Tpda3::Config->instance()->list_config_files;

    return;
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

=head2 read_username

Read use name.

=cut

sub read_username {
    my $self = shift;

    print 'Enter your username: ';

    my $user = ReadLine(0);
    chomp $user;

    return $user;
}

=head2 read_password

Read password.

=cut

sub read_password {
    my $self = shift;

    print 'Enter your password: ';

    ReadMode('noecho');
    my $pass = ReadLine(0);
    print "\n";
    chomp $pass;
    ReadMode('normal');

    return $pass;
}

=head2 help

Print usage help.

=cut

sub help {
    my $msg = shift;

    version();
    print "$msg\n" if $msg;

    print( <<"HELP" );

Usage:

Generate a new screen config file and the coresponding module, or
update a screen config file.

    tpda3d <app-cfg> -G [generate-options]

    tpda3d <app-cfg> -U [update-options]

    <app-cfg>           Use -l | --list to see available configs.

Info:

  -l, --list                List available application configurations.
  -?  --help | -m, --man

HELP

    return;
}

=head2 help_generate



=cut

sub help_generate {

    version();
    print( <<"HELP" );

Usage:

Generate a new screen config file and the coresponding module.

    tpda3d <app-cfg> -G [options]

Options:

  -G, --generate        Generate config.
  -s, --skip-config     Skip config, use existing screen config file.
  -t, --table           Table name to process.
  -c, --config          Screen configuration name.
  -n, --name            Screen module name, optional, default is the
                        config name with the first letter uppercased.
  -u, --user            User
  -p, --pass            Pasword

HELP

    return;
}

=head2 help_update



=cut

sub help_update {

    version();
    print( <<"HELP" );

Usage:

Update a screen config file.

    tpda3d <app-cfg> -U [options]

Options:

  -U, --update          Update a configuration file.
  -c, --config          Screen configuration name.

HELP

    return;
}

=head2 version

Print version.

=cut

sub version {
    my $self = shift;

    my $ver = $VERSION;
    print "Tpda3 Development Tools v$ver\n";
    print "(C) 2010-2012 Stefan Suciu\n\n";

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
