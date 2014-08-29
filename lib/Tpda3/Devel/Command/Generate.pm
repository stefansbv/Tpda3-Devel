package Tpda3::Devel::Command::Generate;

# ABSTRACT: Generate and install a screen module and a configuration file

use 5.010001;
use strict;
use warnings;

use File::Copy;
use Path::Tiny;
use Tpda3::Devel::Utils;

require Tpda3::Devel::Render::Config;
require Tpda3::Devel::Render::Screen;
require Tpda3::Devel::Edit::Config;
require Tpda3::Devel::Edit::Menu;

use base qw( CLI::Framework::Command );

sub usage_text {
    q{
tpda3d gen -s <name> -t <name[,name]>

    OPTIONS
        -s,--screen <name>         the name of the screen module
        -t,--tables <name[,name]>  the name(s) of the tables
    }
}

sub option_spec {
    [ 'screen|s=s', 'the name of the screen module' ],
    [ 'tables|t=s', 'name[,name] the name(s) of the tables' ],
}

sub validate {
    my ($self, $cmd_opts, @args) = @_;

    die "Wrong context!\n",
        "The generate command must be run from a Tpda3 application directory.\n"
        unless $self->cache->get('context') eq 'upd';
    die "Both options are mandatory.  Usage:\n"
        . $self->usage_text  . "\n"
        . $self->app_context . "\n"
        unless exists $cmd_opts->{screen} and exists $cmd_opts->{tables};
    die "No options given.  Usage:\n"
        . $self->usage_text  . "\n"
        . $self->app_context . "\n"
        unless scalar %{$cmd_opts};
}

sub run {
    my ($self, $opts, @args) = @_;

    my $screen = $opts->screen;
    my $tables = $opts->tables;

    my $args = {
        screen => $screen,
        tables => $tables,
    };

    # Generate
    $self->make_screen_config($args);
    $self->make_screen_module($args);

    # Add the screen to the menu
    my $app_info = Tpda3::Devel::Info::App->new;

    my $label     = $screen;
    my $menu_fn   = "menu.yml";
    my $menu_file = $app_info->get_config_apfn_for( 'etc', $menu_fn );

    my $tdem = Tpda3::Devel::Edit::Menu->new();
    $tdem->menu_update($label, $menu_file);

    #-- Install the new screen config in user's home
    $self->install_screen_config($args);
    $self->install_menu_config($args);

    return;
}

sub make_screen_config {
    my ($self, $opts) = @_;

    my $tdrc = Tpda3::Devel::Render::Config->new;
    $tdrc->generate_config($opts);

    return;
}

sub make_screen_module {
    my ($self, $opts) = @_;

    my $screen = $opts->{screen};
    my $module = $opts->{module};

    die "A screen name is required!" unless $screen;

    my $app_info = Tpda3::Devel::Info::App->new;

    my $scrcfg      = lc $screen;
    my $scrcfg_fn   = "$scrcfg.conf";
    my $scrcfg_ap   = $app_info->get_config_ap_for('scr');
    my $scrcfg_apfn = $app_info->get_config_apfn_for( 'scr', $scrcfg_fn );

    my $args = {
        screen      => $screen,
        scrcfg_apfn => $scrcfg_apfn,
    };

    my $tdrs = Tpda3::Devel::Render::Screen->new;
    $tdrs->generate_screen($args);

    return;
}

=head2 install_configs

Install the screen config and the updated menu config file in the
user's home path.

=cut

sub install_screen_config {
    my ($self, $opts) = @_;

    print "Installing screen config ...\r";

    my $app_info = Tpda3::Devel::Info::App->new;

    my $scrcfg      = lc $opts->{screen};
    my $scrcfg_fn   = "$scrcfg.conf";
    my $scrcfg_apfn = $app_info->get_config_apfn_for( 'scr', $scrcfg_fn );
    my $scrcfg_ap   = $app_info->get_user_path_for( 'scr' );

    if ( -f path($scrcfg_ap, $scrcfg_fn) ) {
        print "Installing screen config .. skipped\n";
    }
    else {
        copy($scrcfg_apfn, $scrcfg_ap) or die "Install failed: $!";
        print "Installing screen config ..... done\n";
    }

    return;
}

=head2 install_menu_config

Install the updated menu config file in the user's home path.

=cut

sub install_menu_config {
    my ($self, $opts) = @_;

    print "Installing application menu ..\r";

    my $app_info  = Tpda3::Devel::Info::App->new;
    my $menu_fn   = 'menu.yml';
    my $menu_apfn = $app_info->get_config_apfn_for( 'etc', $menu_fn );
    my $menu_ap   = $app_info->get_user_path_for( 'etc' );

    copy($menu_apfn, $menu_ap) or die "Install failed: $!";

    print "Installing application menu .. done\n";

    return;
}

1;
