package Tpda3::Devel::Info::App;

use 5.008009;
use strict;
use warnings;
use Data::Printer;

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

=head2 new

Constructor.

=cut

sub new {
    my ( $class, $opt ) = @_;

    my $self = {};

    bless $self, $class;

    $self->{module} = $opt;

    return $self;
}

=head2 check_app_path

Check and return the application path.

=cut

sub check_app_path {
    my $self = shift;

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

Return the application config path. If initialized without module
name, return the share/apps.

=cut

sub check_cfg_path {
    my $self = shift;

    my $module = $self->{module};
    if ($module) {
        my $rp = catdir( $self->get_app_rp($module), 'share/apps' );
        if ( -d $rp ) {
            return $rp;
        }
        else {
            die "Wrong path: $rp";
        }
    }
    else {
        my $app_cfg_path = catdir( Cwd::cwd(), 'share/apps' );
        if ( -d $app_cfg_path ) {
            return $app_cfg_path;
        }
        else {
            die "Can't determine share/apps config path.";
        }
    }

    return;
}

sub get_tests_path {
    my $self = shift;

    my $module = $self->{module};
    if ($module) {
        my $rp = catdir( $self->get_app_rp($module), 't' );
        if ( -d $rp ) {
            return $rp;
        }
        else {
            die "Wrong path: $rp";
        }
    }
    else {
        die "Failed to get tests path!";
    }

    return;
}

=head2 get_app_name

Return the current application name.

First check if a subdirectory exists in C<$app_path>, then check if a
module with the same name exists, if true, return the name.

=cut

sub get_app_name {
    my $self = shift;

    my $app_path = $self->check_app_path();
    return unless ($app_path);

    my $dirlist = Tpda3::Config::Utils->find_subdirs($app_path);

    my $no = scalar @{$dirlist};
    if ( $no == 0 ) {
        print "No application path found!\n";
        print " in '$app_path':\n";
        return;
    }

    my $candidate = $dirlist->[0];    # should be only one

    return unless $candidate;         # no app name!

    my $app_module = catfile( $app_path, "$candidate.pm" );

    return $candidate if -f $app_module;

    return;                           # no app name!
}

=head2 get_app_module_rp

Tpda3 application module relative path.  This is not supposed to be
called from an application dir.

=cut

sub get_app_module_rp {
    my $self = shift;

    my $module = $self->{module} or die "No module name!";

    my $rp = catdir( $self->get_app_rp($module), 'lib/Tpda3/Tk/App' );
    if ( -d $rp ) {
        return $rp;
    }
    else {
        die "Unknown path: $rp";
    }
}

=head2 get_app_rp

Tpda3 application module relative path.  This is not supposed to be
called from an application dir.

=cut

sub get_app_rp {
    my $self = shift;

    my $module = $self->{module} || die "No module name!";

    my $rp = catdir("Tpda3-$module");
    if ( -d $rp ) {
        return $rp;
    }
    else {
        die "Unknown path: $rp";
    }
}

=head2 get_cfg_name

Return the current application config name.

=cut

sub get_cfg_name {
    my $self = shift;

    my $app_cfg_path = $self->check_cfg_path();
    return unless ($app_cfg_path);

    my $dirlist = Tpda3::Config::Utils->find_subdirs($app_cfg_path);

    my $no = scalar @{$dirlist};
    if ( $no == 0 ) {
        warn "No configurations found in '$app_cfg_path'";
        return;
    }
    else {
        return $dirlist->[0];    # should be only one
    }
}

=head2 get_screen_module_ap

Return the application screen modules absolute path.

=cut

sub get_screen_module_ap {
    my $self = shift;

    my $app_path = $self->check_app_path();
    my $app_name = $self->get_app_name();

    my $ap = catdir( $app_path, $app_name );
    if ( -d $ap ) {
        return $ap;
    }
    else {
        die "Unknown path: $ap";
    }
}

=head2 get_screen_module_apfn

Get the application screen module absolute path and file name.

=cut

sub get_screen_module_apfn {
    my ( $self, $file ) = @_;

    my $apfn = return catfile( $self->get_screen_module_ap, $file );
    if ( -f $apfn ) {
        return $apfn;
    }
    else {
        die "Unknown file: $apfn";
    }
}

=head2 get_config_ap_for

Get an application configuration absolute path.  The parameter is a
subdir name, one of the following is valid (but no validation occurs):

=over

=item etc

=item scr

=back

=cut

sub get_config_ap_for {
    my ( $self, $dir ) = @_;

    my $cfg_path = $self->check_cfg_path();
    my $cfg_name = $self->get_cfg_name();

    p $cfg_path;
    p $cfg_name;
    my $ap = catdir( $cfg_path, $cfg_name, $dir );
    if ( -d $ap ) {
        return $ap;
    }
    else {
        die "Unknown path: $ap";
    }
}

=head2 get_config_apfn_for

Get the application screen config absolute path and file name.

=cut

sub get_config_apfn_for {
    my ( $self, $type, $file ) = @_;

    return catfile( $self->get_config_ap_for($type), $file );
}

=head1 AUTHOR

Stefan Suciu, C<< <stefan la s2i2.ro> >>

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

1;    # End of Tpda3::Devel::Info::App
