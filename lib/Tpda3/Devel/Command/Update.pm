package Tpda3::Devel::Command::Update;

# ABSTRACT: Update a screen configuration file

use strict;
use warnings;

use base qw( CLI::Framework::Command );

use Tpda3::Devel::Utils;
require Tpda3::Devel::Edit::Config;

sub usage_text {
    q{
tpda3d update -c <name> | -s <name>

    OPTIONS
        -c,--conf   <name>    the name of the screen configuration file
        -s,--screen <name>    the name of the screen module
    }
}

sub option_spec {
    [ "conf|c=s"   => 'the name of the screen configuration file' ],
    [ "screen|s=s" => 'the name of the screen module' ],
}

sub validate {
    my ($self, $cmd_opts, @args) = @_;

    die "Wrong context!\n",
        "The update command must be run from a Tpda3 application directory.\n"
        unless $self->cache->get('context') eq 'upd';
    die "Only one of the options conf or screen, is alowed.  Usage:"
        . $self->usage_text  . "\n"
        . $self->app_context . "\n"
        if exists $cmd_opts->{conf} and exists $cmd_opts->{screen};
    die "No options given.  Usage:"
        . $self->usage_text  . "\n"
        . $self->app_context . "\n"
        unless scalar %{$cmd_opts};
}

sub run {
    my ($self, $opts, @args) = @_;

    my $option = $opts->conf || $opts->screen;
    ( my $name = $option ) =~ s{\.\w+$}{}g; # remove the ext

    my $scrcfg    = lc $name;
    my $scrcfg_fn = "$scrcfg.conf";

    my $app_info = Tpda3::Devel::Info::App->new;

    my $scrcfg_ap   = $app_info->get_config_ap_for('scr');
    my $scrcfg_apfn = $app_info->get_config_apfn_for( 'scr', $scrcfg_fn );

    die "Configuration file '$scrcfg' not found!\n" unless -f $scrcfg_apfn;

    my $args = {
        scrcfg_fn   => $scrcfg_fn,
        scrcfg_ap   => $scrcfg_ap,
        scrcfg_apfn => $scrcfg_apfn,
    };

    my $tdec = Tpda3::Devel::Edit::Config->new;
    $tdec->config_update($args);

    return;
}

1;
