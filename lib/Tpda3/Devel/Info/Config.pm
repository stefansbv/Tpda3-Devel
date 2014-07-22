package Tpda3::Devel::Info::Config;

use 5.010001;
use strict;
use warnings;

use File::Basename;
use File::Spec::Functions;

require Tpda3::Config;
require Tpda3::Devel::Info::App;

=head1 NAME

Tpda3::Devel::Info::Config - Tpda3 application config related info.

=head1 VERSION

Version 0.15

=cut

our $VERSION = '0.15';

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

    my $args = {
        cfname => $opt->{mnemonic},
        user   => undef,
        pass   => undef,
    };

    $self->{_cfg} = Tpda3::Config->instance($args);

    return;
}

=head2 config_info

Application configuration info.

=cut

sub config_info {
    my ($self) = @_;

    my $appcfg = $self->{_cfg};

    my $cfname = $appcfg->cfname;
    my $apps   = $appcfg->cfapps;
    my $module = $appcfg->application->{module};

    # Check configured toolkit type
    my $toolkit = $appcfg->application->{widgetset};
    die "Fatal!: $toolkit toolkit not supported!"
        unless $toolkit eq 'Tk';

    return {
        cfname   => $cfname,
        apps_dir => $apps,
        module   => $module,
    };
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

Copyright 2012-2013 Stefan Suciu

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
