package Tpda3::Devel::Render;

use 5.008009;
use strict;
use warnings;

use Template;
use File::ShareDir qw(dist_dir);
use File::Spec::Functions;

require Tpda3::Devel::Info::App;

=head1 NAME

Tpda3::Devel::Render::Config - Create a screen configuration file.

=head1 VERSION

Version 0.12

=cut

our $VERSION = '0.12';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Tpda3::Devel::Config;

    my $foo = Tpda3::Devel::Config->new();

=head1 METHODS

=head2 render

Generate a file from templates.

If the output file parameter is just the file extension, then use type
as file name.

=cut

sub render {
    my ($self, $type, $output_file, $data, $output_path) = @_;

    my $template = $self->get_template_for($type);

    $output_file = "${type}$output_file" if $output_file =~ m{^\.};

    # Where are module-level shared data files kept
    my $templ_path = catdir( dist_dir('Tpda3-Devel'), 'templates');

    # print "Rendering '$template'...\n";
    # print " Output goes to\n '$output_path'\n";
    # print " File is '$output_file'\n";

    my $tt = Template->new(
        INCLUDE_PATH => $templ_path,
        OUTPUT_PATH  => $output_path,
    );

    $tt->process( $template, $data, $output_file, binmode => ':utf8' )
        or die $tt->error(), "\n";

    return $output_file;
}

=head2 get_template_for

Return the template name for one of the two known types: I<config> or
I<screen>.

=cut

sub get_template_for {
    my ($self, $type) = @_;

    die "The type argument is required" unless defined $type;

    my $template =
         $type eq q{}               ? die("Empty type argument")
       : $type eq 'config'          ? 'config.tt'
       : $type eq 'config-update'   ? 'config-refactor.tt'
       : $type eq 'screen'          ? 'screen.tt'
       : $type eq 'module'          ? 'module.tt'
       : $type eq 'makefile'        ? 'makefile.tt'
       : $type eq 'readme'          ? 'readme.tt'
       : $type eq 'cfg-application' ? 'config/application.tt'
       : $type eq 'cfg-menu'        ? 'config/menu.tt'
       : $type eq 'cfg-connection'  ? 'config/connection.tt'
       : $type eq 'test-load'       ? 'test/load.tt'
       : $type eq 'test-config'     ? 'test/config.tt'
       : $type eq 'test-connection' ? 'test/connection.tt'
       :                              die("Unknown type $type")
       ;

    return $template;
}

=head1 AUTHOR

Stefan Suciu, C<< <stefan la s2i2.ro> >>

=head1 BUGS

Please report any bugs or feature requests to the autor.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tpda3::Devel::Config

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

1; # End of Tpda3::Devel::Render;
