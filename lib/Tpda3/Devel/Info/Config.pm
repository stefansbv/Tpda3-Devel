package Tpda3::Devel::Info::Config;

use 5.008009;
use strict;
use warnings;

use File::Basename;
use File::Spec::Functions;

require Tpda3::Config;
require Tpda3::Devel::Info::App;

=head1 NAME

Tpda3::Devel::Info::Config - Tpda3 application config related info.

=head1 VERSION

Version 0.10

=cut

our $VERSION = '0.10';

=head1 SYNOPSIS

    use Tpda3::Devel::Info::Config;

    my $ic = Tpda3::Devel::Info::Config->new();
    my $ic = $dci->config_info();

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

sub _init {
    my ($self, $opt) = @_;

    unless ( exists $opt->{cfname} and $opt->{cfname} ) {
        # Try to guess the config name
        my $app_info = Tpda3::Devel::Info::App->new();
        $opt->{cfname} = $app_info->get_cfg_name();
    }

    die "Abort, can not determine mnemonic"
        unless exists $opt->{cfname} and $opt->{cfname};

    Tpda3::Config->instance($opt);

    return;
}

=head2 config_info

Application configuration info.

=cut

sub config_info {
    my ($self) = @_;

    my $appcfg = Tpda3::Config->instance();

    my $name   = $appcfg->cfname;
    my $apps   = $appcfg->cfapps;
    my $module = $appcfg->application->{module};

    # Check configured toolkit type
    my $toolkit = $appcfg->application->{widgetset};
    die "Fatal!: $toolkit toolkit not supported!"
        unless $toolkit eq 'Tk';

    return {
        name     => $name,
        apps_dir => $apps,
        module   => $module,
    };
}

=head2 list_mnemonics

Call list_configs method from Tpda3::Config.

=cut

sub list_mnemonics {
    my ($self) = @_;

    Tpda3::Config->instance()->list_mnemonics;

    return;
}

=head2 list_scrcfg_files

List the available screen configuration files.

=cut

sub list_scrcfg_files {
    my $self = shift;

    Tpda3::Config->instance()->list_config_files;

    return;
}

=head1 AUTHOR

Stefan Suciu, C<< <stefan@s2i2.ro> >>

=head1 BUGS

Please report any bugs or feature requests to the autor.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tpda3::Devel::Info::Config

=head1 ACKNOWLEDGEMENTS

Options processing inspired from App::Ack (C) 2005-2011 Andy Lester.

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

1; # End of Tpda3::Devel::Info::Config
