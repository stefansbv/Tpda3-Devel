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

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Tpda3::Devel::Config;

    my $foo = Tpda3::Devel::Config->new();

=head1 METHODS

=head2 render

Generate a file from templates.

=cut

sub render {
    my ($self, $type, $output_file, $data) = @_;

    my $template    = get_template_for($type);
    my $output_path = get_output_path_for($type);

    # Where are module-level shared data files kept
    my $templ_path = catdir( dist_dir('Tpda3-Devel'), 'templates');

    print "\n Output goes to\n '$output_path'\n";
    print " File is '$output_file'\n";

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
    my $type = shift;

    die "The type argument is required" unless defined $type;

    my $template =
         $type eq q{}       ? die("Empty type argument")
       : $type eq 'config'  ? 'config.tt'
       : $type eq 'screen'  ? 'screen.tt'
       :                      die("Unknown type $type")
       ;

    return $template;
}

=head2 get_output_path_for

Return the output path for one of the two known types: I<config> or
I<screen>.

=cut

sub get_output_path_for {
    my $type = shift;

    die "The type argument is required" unless defined $type;

    my $path =
         $type eq q{}       ? ''
       : $type eq 'config'  ? screen_cfg_path()
       : $type eq 'screen'  ? screen_module_path()
       :                      die("Unknown type $type");

    return $path;
}

=head2 screen_cfg_path

Screen configurations path.

=cut

sub screen_cfg_path {
    return Tpda3::Devel::Info::App->get_scrcfg_path()
}

=head2 screen_screen_path

Screen configurations path.

=cut

sub screen_module_path {
    return Tpda3::Devel::Info::App->get_screen_path()
}

=head1 AUTHOR

Stefan Suciu, C<< <stefan@s2i2.ro> >>

=head1 BUGS

Please report any bugs or feature requests to the autor.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tpda3::Devel::Config

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

1; # End of Tpda3::Devel::Render;
