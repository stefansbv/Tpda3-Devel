package Tpda3::Devel::Edit::Menu;

use 5.008009;
use strict;
use warnings;
use utf8;

use YAML::Tiny;
use List::Util qw{max};

=head1 NAME

Tpda3::Devel::Edit::Menu - Tpda3 application config update.

=head1 VERSION

Version 0.11

=cut

our $VERSION = '0.11';

=head1 SYNOPSIS

    use Tpda3::Devel::Edit::Menu;

    my $dci = Tpda3::Devel::Edit::Menu->new();
    my info = $dci->config_info();
    ...

=head1 METHODS

=head2 new

=cut

sub new {
    my ( $class, $opt ) = @_;

    my $self = {};

    bless $self, $class;

    $self->{opt} = $opt;

    return $self;
}

=head2 menu_update

share/apps/raton/etc/menu.yml

=cut

sub menu_update {
    my $self = shift;

    my $label     = $self->{opt}{screen};
    my $menu_file = $self->{opt}{menu_apfn};

    die "A menu file is required!" unless $menu_file;
    die "A label is required!" unless $label;

    my $yaml = YAML::Tiny->read($menu_file);

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

=head1 AUTHOR

Stefan Suciu, C<< <stefan la s2i2.ro> >>

=head1 BUGS

Please report any bugs or feature requests to the autor.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tpda3::Devel::Edit::Menu

=head1 ACKNOWLEDGEMENTS

Options processing inspired from App::Ack (C) 2005-2011 Andy Lester.

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Ștefan Suciu.

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

1;    # End of Tpda3::Devel::Edit::Menu
