package Tpda3::Devel::Render::Screen;

use 5.008009;
use strict;
use warnings;
use utf8;

use Config::General qw{ParseConfig};
use File::Spec::Functions;
use Tie::IxHash;

require Tpda3::Devel::Info::App;
require Tpda3::Devel::Info::Config;
require Tpda3::Devel::Render;

=head1 NAME

Tpda3::Devel::Render::Screen - Create a screen module file.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Generate a screen module.

    use Tpda3::Devel::Render::Screen;

    my $foo = Tpda3::Devel::Render::Screen->new();

=head1 METHODS

=head2 new

Constructor.

=cut

sub new {
    my ( $class, $opt ) = @_;

    my $self = {};

    bless $self, $class;

    $self->{opt} = $opt;

    return $self;
}

=head2 generate_screen

Generate screen module.

=cut

sub generate_screen {
    my ($self, $file) = @_;

    my $screen = $self->{opt}{module};

    my $dci = Tpda3::Devel::Info::Config->new($self->{opt});
    my $cfg = $dci->config_info();
    my $module = $cfg->{cfg_module};

    my $config_file = Tpda3::Devel::Info::App->get_scrcfg_file($file);

    tie my %cfg, "Tie::IxHash";     # keep the sections order

    %cfg = ParseConfig(
        -ConfigFile => $config_file,
        -Tie        => 'Tie::IxHash',
    );

    # TODO: Make user (developer) config with this data
    my %data = (
        copy_author => 'Ștefan Suciu',
        copy_email  => 'stefan@s2i2.ro',
        copy_year   => '2012',
        module      => $cfg->{cfg_module},
        screen      => ucfirst $screen,
        columns     => $cfg{maintable}{columns},
    );

    my $module      = ucfirst $self->{opt}{module} . '.pm';
    my $output_path = Tpda3::Devel::Info::App->get_screen_module_path();

    Tpda3::Devel::Render->render( 'screen', $module, \%data, $output_path );

    return;
}

=head1 AUTHOR

Stefan Suciu, C<< <stefan@s2i2.ro> >>

=head1 BUGS

Please report any bugs or feature requests to the autor.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tpda3::Devel::Render::Screen

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

1; # End of Tpda3::Devel::Render::Screen
