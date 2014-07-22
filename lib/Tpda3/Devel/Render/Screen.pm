package Tpda3::Devel::Render::Screen;

use 5.010001;
use strict;
use warnings;
use utf8;

use Config::General qw{ParseConfig};
use File::Spec::Functions;
use Tie::IxHash;

require Tpda3::Devel::Config;
require Tpda3::Devel::Info::App;
require Tpda3::Devel::Render;

=head1 NAME

Tpda3::Devel::Render::Screen - Create a screen module file.

=head1 VERSION

Version 0.50

=cut

our $VERSION = '0.50';

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
    my ($self, $opts) = @_;

    my $screen = $opts->{screen};

    print "Creating screen module ........\r";

    die "A screen name is required!" unless $screen;

    my $config_file = $opts->{scrcfg_apfn};

    die unless defined $config_file;

    unless (-f $config_file) {
        die "Can't locate config file:\n$config_file";
    }

    tie my %cfg, "Tie::IxHash";     # keep the sections order

    %cfg = ParseConfig(
        -ConfigFile => $config_file,
        -Tie        => 'Tie::IxHash',
    );

    my $app_info = Tpda3::Devel::Info::App->new;

    my $tdc = Tpda3::Devel::Config->new;
    my ($user_name, $user_email) = $tdc->get_gitconfig;

    my $data = {
        copy_author => $user_name,
        copy_email  => $user_email,
        copy_year   => (localtime)[5] + 1900,
        module      => $app_info->get_app_name,
        screen      => $screen,
        conf        => lc $screen . '.conf',
        columns     => $cfg{maintable}{columns},
        pkcol       => $cfg{maintable}{pkcol}{name},
    };

    my $screen_fn   = "$screen.pm";
    my $output_path = $app_info->get_screen_module_ap();

    if ( -f catfile($output_path, $screen_fn) ) {
        print "Creating screen module .... skipped\n";
        return;
    }

    my $args = {
        type        => 'screen',
        output_file => $screen_fn,
        data        => { r => $data },
        output_path => $output_path,
        templ_path  => undef,
    };

    Tpda3::Devel::Render->render($args);

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

1; # End of Tpda3::Devel::Render::Screen
