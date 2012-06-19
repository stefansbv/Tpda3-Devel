package Tpda3::Devel::Render::Screen;

use 5.008009;
use strict;
use warnings;

use Config::General qw{ParseConfig};
use File::Spec::Functions;

require Tpda3::Devel::Render;
require Tpda3::Devel::Info::Config;

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
    my ($self, $config_path) = @_;

    my $screen = $self->{opt}{screen};

    my $dci = Tpda3::Devel::Info::Config->new($self->{opt});
    my $cfg = $dci->config_info();
    my $module = $cfg->{cfg_module};

    my $cwd = Cwd::cwd();
    my $scrd = "lib/Tpda3/Tk/App/${module}";
    my $scrd_path = catdir( $cwd, $scrd ); # screen module path
    if (!-d $scrd_path) {
        print "\n Can't write the new screen to\n '$scrd_path'\n";
        print " No such path!\n";
        die "\n\n  !!! Run '$0' from an Tpda3 application source dir !!!\n\n";
    }

    tie my %cfg, "Tie::IxHash";     # keep the sections order

    %cfg = ParseConfig(
        -ConfigFile => $config_path,
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

    my $screen_module = ucfirst $self->{opt}{screen} . '.pm';

    Tpda3::Devel::Render->render( 'screen', $screen_module, \%data );

    return;
}

=head2 screen_cfg_path

Screen configurations path.

=cut

sub screen_cfg_path {
    my $self = shift;

    return Tpda3::Devel::Info::App->get_scrcfg_path();
}

=head2 screen_cfg_file

Screen configuration file name.

=cut

sub screen_cfg_file {
    my $self = shift;

    my $scr_cfg_file = lc $self->{opt}{config} . '.conf';

    return catfile( $self->screen_cfg_path, $scr_cfg_file );
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
