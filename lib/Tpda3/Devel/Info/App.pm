package Tpda3::Devel::Info::App;

use 5.008009;
use strict;
use warnings;

use File::Basename;
use File::Spec::Functions;

require Tpda3::Config::Utils;

=head1 NAME

Tpda3::Devel::Info::App - Tpda3 application info.

Determine if CWD is a Tpda3 application source dir.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use Tpda3::Devel::Info::App;

    my $ic = Tpda3::Devel::Info::App->new();
    my $ic = $dci->config_info();

=head1 METHODS

=head2 check_app_path

Check and return the application path.

=cut

sub check_app_path {

    my $app_path = catdir( Cwd::cwd(), 'lib/Tpda3/Tk/App' );
    if ( -d $app_path ) {
        return $app_path;
    }
    else {
        warn " No app path!: '$app_path'";
        return;
    }
}

=head2 check_cfg_paths

Check and return the application config path.

=cut

sub check_cfg_path {

    my $app_cfg_path = catdir( Cwd::cwd(), "share/apps" );

    if ( -d $app_cfg_path ) {
        return $app_cfg_path;
    }
    else {
        warn " No cfg path!: '$app_cfg_path'";
        return;
    }

    return;
}

=head2 get_app_name

Return the current application name

=cut

sub get_app_name {

    my $app_path = check_app_path();
    return unless ($app_path);

    print " $app_path\n";
    my $dirlist = Tpda3::Config::Utils->find_subdirs($app_path);

    my $no = scalar @{$dirlist};
    if ( $no == 0 ) {
        print "No application found!\n";
        print " in '$app_path':\n";
        return;
    }
    else {
        return $dirlist->[0];                # should be only one
    }
}

=head2 get_cfg_name

Return the current application config name.

=cut

sub get_cfg_name {

    my $app_cfg_path = check_cfg_path();
    return unless ($app_cfg_path);

    my $dirlist = Tpda3::Config::Utils->find_subdirs($app_cfg_path);

    my $no = scalar @{$dirlist};
    if ( $no == 0 ) {
        warn "No configurations found in '$app_cfg_path'";
        return;
    }
    else {
        return $dirlist->[0];                # should be only one
    }
}

=head2 get_screen_path

Return the application screen modules path.

=cut

sub get_screen_path {

    my $app_path = check_app_path();
    my $app_name = get_app_name();

    return catdir($app_path, $app_name);
}

=head2 get_scrcfg_path

Get the application screen config path.

=cut

sub get_scrcfg_path {

    my $cfg_path = check_cfg_path();
    my $cfg_name = get_cfg_name();

    return catdir($cfg_path, $cfg_name);
}

=head1 AUTHOR

Stefan Suciu, C<< <stefan@s2i2.ro> >>

=head1 BUGS

Please report any bugs or feature requests to the autor.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tpda3::Devel::Info::App

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

1; # End of Tpda3::Devel::Info::App
