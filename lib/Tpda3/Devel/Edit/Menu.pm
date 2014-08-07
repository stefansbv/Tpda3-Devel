package Tpda3::Devel::Edit::Menu;

# ABSTRACT: Tpda3 application config update

use 5.010001;
use strict;
use warnings;
use utf8;

use Try::Tiny;
use YAML::Tiny;

use List::Util qw{max};

require Tpda3::Devel::Info::App;

=head2 new

Constructor.

=cut

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

=head2 menu_update

share/apps/name/etc/menu.yml

=cut

sub menu_update {
    my ($self, $label, $menu_file) = @_;

    die "A label is required!"     unless $label;
    die "A menu file is required!" unless $menu_file;

    my $yaml;
    try {
        $yaml = YAML::Tiny->read($menu_file) or die YAML::Tiny->errstr;
    }
    catch {
        die "YAML Error: $_\n";
    };

    my $popup = $yaml->[0]{appmenubar}{menu_user}{popup};

    $popup = defined $popup ? $popup : {}; # init as href

    # Check for $label
    my $knum = 0;
    foreach my $idx ( keys %{$popup} ) {
        return if $popup->{$idx}{label} eq $label; # exists?, aborting
        $knum++;
    }

    my $new_idx = $knum + 1;
    $yaml->[0]{appmenubar}{menu_user}{popup}{$new_idx}{name}      = $label;
    $yaml->[0]{appmenubar}{menu_user}{popup}{$new_idx}{label}     = $label;
    $yaml->[0]{appmenubar}{menu_user}{popup}{$new_idx}{underline} = 0;
    $yaml->[0]{appmenubar}{menu_user}{popup}{$new_idx}{key}       = undef;
    $yaml->[0]{appmenubar}{menu_user}{popup}{$new_idx}{sep}       = 'none';

    my $old = $menu_file;
    my $new = "$menu_file.tmp.$$";
    my $bak = "$menu_file.orig";

    $yaml->write($new);

    rename($old, $bak) or die "Can't rename $old to $bak: $!";
    rename($new, $old) or die "Can't rename $new to $old: $!";

    return;
}

1;
