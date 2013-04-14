package Tpda3::Devel::Render::YAML;

use 5.008009;
use strict;
use warnings;
use utf8;

require Tpda3::Devel::Info::App;
require Tpda3::Devel::Render;

=head1 NAME

Tpda3::Devel::Render::YAML - Create a YAML configuration file.

=head1 VERSION

Version 0.10

=cut

our $VERSION = '0.10';

=head1 SYNOPSIS

Generate a screen module.

    use Tpda3::Devel::Render::YAML;

    my $foo = Tpda3::Devel::Render::YAML->new();

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

=head2 generate_config

Generate a YAML config from a template.

=cut

sub generate_config {
    my ($self, $yml_tmpl, $yml_name) = @_;

    my $module = $self->{opt}{module};
    my $dbname = $self->{opt}{dbname};

    die "Need a module name!" unless $module;

    my %data = ( r => $self->{opt} );

    my $app_info = Tpda3::Devel::Info::App->new($module);
    my $out_path = $app_info->get_config_ap_for('etc');

    Tpda3::Devel::Render->render( $yml_tmpl, $yml_name, \%data, $out_path );

    return $out_path;
}

=head1 DESCRIPTION

Using a template to generate YAML configration files.

=head1 AUTHOR

Stefan Suciu, C<< <stefan@s2i2.ro> >>

=head1 BUGS

Please report any bugs or feature requests to the autor.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tpda3::Devel::Render::YAML

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

1; # End of Tpda3::Devel::Render::YAML
