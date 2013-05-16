package Tpda3::Devel::Render::Test;

use 5.008009;
use strict;
use warnings;
use utf8;

require Tpda3::Devel::Info::App;
require Tpda3::Devel::Render;

=head1 NAME

Tpda3::Devel::Render::Test - Create a test file.

=head1 VERSION

Version 0.13

=cut

our $VERSION = '0.13';

=head1 SYNOPSIS

Generate a test file.

    use Tpda3::Devel::Render::Test;

    my $foo = Tpda3::Devel::Render::Test->new();

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

=head2 generate_test

Generate test from template.

=cut

sub generate_test {
    my ($self, $test_tmpl, $test_name) = @_;

    my $module = $self->{opt}{module};

    die "Need a app name!" unless $module;
    die "Need a test template!" unless $test_tmpl;
    die "Need a test name!" unless $test_name;

    $self->{opt}{appname} = "Tpda3::Tk::App::$module";

    my %data = ( r => $self->{opt} );

    my $app_info = Tpda3::Devel::Info::App->new($module);
    my $output_path = $app_info->get_tests_path();

    Tpda3::Devel::Render->render( $test_tmpl, $test_name, \%data,
        $output_path );

    return;
}

=head1 AUTHOR

Stefan Suciu, C<< <stefan@s2i2.ro> >>

=head1 BUGS

Please report any bugs or feature requests to the autor.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tpda3::Devel::Render::Test

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

1; # End of Tpda3::Devel::Render::Test
