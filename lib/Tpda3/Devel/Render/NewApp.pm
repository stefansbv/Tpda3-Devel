package Tpda3::Devel::Render::NewApp;

use 5.008009;
use strict;
use warnings;
use utf8;

require Tpda3::Devel::Info::App;
require Tpda3::Devel::Render;

=head1 NAME

Tpda3::Devel::Render::NewApp - Create a screen module file.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Generate a screen module.

    use Tpda3::Devel::Render::NewApp;

    my $foo = Tpda3::Devel::Render::NewApp->new();

=head1 METHODS

=head2 new

Constructor.

=cut

sub new {
    my ( $class, $opt ) = @_;

    my $self = {};

    bless $self, $class;

    $self->{param} = $opt;

    return $self;
}

=head2 generate_screen

Generate screen module.

=cut

sub generate_newapp {
    my $self = shift;

    my $module = $self->{param}{appname};

    die "Need a module name!" unless $module;

    # TODO: Make user (developer) config with this data
    my %data = (
        name        => "Tpda3::Tk::App::$module",
        description => 'description',
        copy_author => 'Ștefan Suciu',
        copy_email  => "stefan 'la' s2i2 .ro",
        copy_year   => '2012',
    );

    my $app_info = Tpda3::Devel::Info::App->new();
    my $output_path = $app_info->get_app_module_rp($module);

    Tpda3::Devel::Render->render( 'newapp', "$module.pm", \%data, $output_path );

    return $output_path;
}

=head1 AUTHOR

Stefan Suciu, C<< <stefan@s2i2.ro> >>

=head1 BUGS

Please report any bugs or feature requests to the autor.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tpda3::Devel::Render::NewApp

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

1; # End of Tpda3::Devel::Render::NewApp
