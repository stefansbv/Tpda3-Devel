package Tpda3::Devel::Info::Config;

use 5.008009;
use strict;
use warnings;

use File::Basename;
use File::Spec::Functions;

require Tpda3::Config;

=head1 NAME

Tpda3::Devel::Info::Config - Tpda3 application config related info.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

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

    Tpda3::Config->instance($opt);

    return $self;
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

=head2 list_configs

Call list_configs method from Tpda3::Config.

=cut

sub list_configs {
    my ($self) = @_;

    Tpda3::Config->instance()->list_configs;

    return;
}

sub list_config_files {
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
