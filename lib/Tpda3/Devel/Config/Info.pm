package Tpda3::Devel::Config::Info;

use 5.008009;
use strict;
use warnings;

use File::Basename;
use File::Spec::Functions;

require Tpda3::Config;

=head1 NAME

Tpda3::Devel::Config::Info - Tpda3 application config related info.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use Tpda3::Devel::Config::Info;

    my $dci = Tpda3::Devel::Config::Info->new();
    my info = $dci->config_info();

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

=head2 config_info

Application configuration info.

=cut

sub config_info {
    my ($self) = @_;

    my $appcfg = Tpda3::Config->instance();

    my $cfg_name   = $appcfg->cfname;
    my $cfg_apps   = $appcfg->cfapps;
    my $cfg_module = $appcfg->application->{module};

    # Check configured widget type
    my $cfg_widget = $appcfg->application->{widgetset};
    die "Fatal!: $cfg_widget toolkit not supported!"
        unless $cfg_widget eq 'Tk';

    return {
        cfg_name   => $cfg_name,
        cfg_apps   => $cfg_apps,
        cfg_module => $cfg_module,
    };
}

=head1 AUTHOR

Stefan Suciu, C<< <stefan\@s2i2.ro> >>

=head1 BUGS

Please report any bugs or feature requests to the autor.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tpda3::Devel::Config::Info

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

1; # End of Tpda3::Devel::Config::Info
