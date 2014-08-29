package Tpda3::Devel::Info::App;

# ABSTRACT: Tpda3 application info

use 5.010001;
use strict;
use warnings;

use File::Basename;
use File::UserConfig;
use Path::Tiny qw(cwd path);
require Tpda3::Config::Utils;

=head2 new

Constructor.

=cut

sub new {
    my ( $class, $opt ) = @_;

    my $self = bless {}, $class;
    $self->{module} = $opt;

    return $self;
}

=head2 get_app_path

Check and return the application path.

=cut

sub get_app_path {
    my $self = shift;
    my $app_path = path( cwd, (qw{lib Tpda3 Tk App}) );
    return $app_path if -d $app_path;
    return;
}

=head2 get_cfg_path

Return the application config path.  If initialized without module
name, return the share/apps.

=cut

sub get_cfg_path {
    my $self = shift;
    my $module = $self->{module};
    if ($module) {
        my $rp = path( $self->get_app_rp($module), 'share', 'apps' );
        return $rp if -d $rp;
    }
    else {
        my $app_cfg_path = path( cwd, 'share', 'apps' );
        return $app_cfg_path if -d $app_cfg_path;
    }
    return;
}

=head2 is_app_dir

Return true if CWD is a Tpda3 application distribution dir.

=cut

sub is_app_dir {
    my $self = shift;
    return $self->get_app_path and $self->get_cfg_path;
}

=head2 get_tests_path

Return the path to the tests dir of the distribution.

=cut

sub get_tests_path {
    my $self = shift;
    my $module = $self->{module};
    if ($module) {
        my $rp = path( $self->get_app_rp($module), 't' );
        return $rp if -d $rp;
    }
    return;
}

=head2 get_app_name

Return the current application name.

First check if a subdirectory exists in C<$app_path>, then check if a
module exists, if true, return the name.

=cut

sub get_app_name {
    my $self = shift;

    my $app_path = $self->get_app_path();
    return unless ($app_path);

    my $filelist = Tpda3::Config::Utils->find_files($app_path);

    my $no = scalar @{$filelist};
    if ( $no == 0 ) {
        die "No application module found in path: '$app_path'\n";
        return;
    }

    ( my $module = $filelist->[0] ) =~ s{\.pm$}{};    # should be only one

    return $module;
}

=head2 get_app_module_rp

Tpda3 application module relative path.  This is not supposed to be
called from an application dir.

=cut

sub get_app_module_rp {
    my $self = shift;

    my $module = $self->{module} or die "No module name!";

    my $rp = path( $self->get_app_rp($module), (qw{lib Tpda3 Tk App}) );
    if ( -d $rp ) {
        return $rp;
    }
    else {
        die "Unknown path: $rp";
    }
}

=head2 get_app_rp

A Tpda3 application distribution relative path.  Used for new
application distributions.  This is not supposed to be called from an
application dir.

=cut

sub get_app_rp {
    my ($self, $module) = @_;
    die "No module name in 'get_app_rp'!" unless $module;
    my $rp = path("Tpda3-$module");
    return $rp if -d $rp;
    return;
}

=head2 get_cfg_name

Return the current application config name.

=cut

sub get_cfg_name {
    my $self = shift;

    my $app_cfg_path = $self->get_cfg_path;
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
    my $app_path = $self->get_app_path;
    my $app_name = $self->get_app_name;
    my $ap = path( $app_path, $app_name );
    return $ap if -d $ap;
    return;
}

=head2 get_screen_module_apfn

Get the application screen module absolute path and file name.

=cut

sub get_screen_module_apfn {
    my ( $self, $file ) = @_;
    my $apfn = return path( $self->get_screen_module_ap, $file );
    return $apfn if -f $apfn;
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
    my $cfg_path = $self->get_cfg_path;
    my $cfg_name = $self->get_cfg_name;
    my $ap = path( $cfg_path, $cfg_name, $dir );
    return $ap if -d $ap;
    return;
}

=head2 get_config_apfn_for

Get the application configuration absolute path and file name.

=cut

sub get_config_apfn_for {
    my ( $self, $type, $file ) = @_;
    return path( $self->get_config_ap_for($type), $file );
}

=head2 get_user_path_for

Return the user configurations path.

=cut

sub get_user_path_for {
    my ($self, $path) = @_;

    my $configpath = File::UserConfig->new(
        dist     => 'Tpda3',
        sharedir => 'share',
    )->configdir;

    my $mnemonic = lc $self->get_app_name;
    my $ap = path( $configpath, 'apps', $mnemonic, $path );
    warn "Nonexistent user path $ap\n" unless -d $ap;

    return $ap;
}

1;
