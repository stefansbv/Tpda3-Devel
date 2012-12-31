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

Version 0.10

=cut

our $VERSION = '0.10';

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

Generate a screen module from templates.

=cut

sub generate_screen {
    my $self = shift;

    print "Creating screen module ........\r";

    my $screen = $self->{opt}{screen};

    die "A screen name is required!" unless $screen;

    my $app_info = Tpda3::Devel::Info::App->new();
    my $cfg_info = Tpda3::Devel::Info::Config->new($self->{opt});

    my $config_file = $self->{opt}{config_apfn};

    die unless defined $config_file;

    unless (-f $config_file) {
        die "Can't locate config file:\n$config_file";
    }

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
        module      => $app_info->get_app_name(),
        screen      => $screen,
        columns     => $cfg{maintable}{columns},
        pkcol       => $cfg{maintable}{pkcol}{name},
    );

    my $screen_fn   = $self->{opt}{screen_fn};
    my $output_path = $self->{opt}{screen_ap};

    if ( -f catfile($output_path, $screen_fn) ) {
        print "Creating screen module .... skipped\n";
        return;
    }

    Tpda3::Devel::Render->render( 'screen', $screen_fn, \%data, $output_path );

    print "Creating screen module ....... done\n";

    return;
}

=head1 AUTHOR

Ştefan Suciu, C<< <stefan@s2i2.ro> >>

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
