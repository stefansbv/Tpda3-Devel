package Tpda3::Devel::Command::Update;

use strict;
use warnings;

use base qw( CLI::Framework::Command );

require Tpda3::Devel::Edit::Config;

sub usage_text {
    q{
    update [-c <name>]

    update [-s <name>]

    OPTIONS
       --conf=<name>:            the name of the screen .conf file
       --screen=<name>.pm:       or the name of the screen module
    }
}

sub option_spec {
    [  name     => hidden => {
          required => 1,
          one_of   => [
             [ "conf|c=s"   => 'the name of the screen .conf file' ],
             [ "screen|s=s" => 'or the name of the screen module' ],
          ]
       }
    ]
}

sub validate_options {
    my ($self, $opts) = @_;
    # ...nothing to check for this application
}

sub run {
    my ($self, $opts, @args) = @_;

    my $option = $opts->name;
    ( my $name = $opts->$option ) =~ s{\.\w+$}{}g; # remove the ext

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
