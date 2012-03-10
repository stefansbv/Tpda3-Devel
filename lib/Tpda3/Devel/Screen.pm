package Tpda3::Devel::Screen;

use 5.008009;
use strict;
use warnings;

use Data::Dumper;

use Cwd;
use Template;
use Config::General qw{ParseConfig};
use File::Spec::Functions;

require Tpda3::Devel::Config::Info;

=head1 NAME

Tpda3::Devel::Screen - The great new Tpda3::Devel::Screen!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Tpda3::Devel::Screen;

    my $foo = Tpda3::Devel::Screen->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 METHODS

=head2 new

Constructor.

=cut

sub new {
    my ( $class, $opt ) = @_;

    my $self = {};

    bless $self, $class;

    $self->{opt} = $opt;

    return $self;
}

=head2 generate_screen

Generate screen module.

=cut

sub generate_screen {
    my ($self, $config_path) = @_;

    my $screen = $self->{opt}{screen};

    my $dci = Tpda3::Devel::Config::Info->new($self->{opt});
    my $cfg = $dci->config_info();
    my $module = $cfg->{cfg_module};

    my $cwd = Cwd::cwd();
    my $scrd = "lib/Tpda3/Tk/App/${module}";
    my $scrd_path = catdir( $cwd, $scrd ); # screen module path
    if (!-d $scrd_path) {
        print "Can't put the new screen in\n '$scrd_path'\n";
        die "!!! This tool is supposed to be run from an app source dir !!!\n";
    }

    tie my %cfg, "Tie::IxHash";     # keep the order

    %cfg = ParseConfig(
        -ConfigFile => $config_path,
        -Tie        => 'Tie::IxHash',
    );

    # TODO: Make user (developer) config with this data
    my %data = (
        copy_author => 'Ștefan Suciu',
        copy_email  => 'stefan@s2i2.ro',
        copy_year   => '2012',
        module      => $cfg->{cfg_module},
        screen      => ucfirst $screen,
        columns     => $cfg{maintable}{columns},
    );

    my $screen_module = ucfirst $self->{opt}{screen} . '.pm';

    # Check if output file exists
    my $screen_path = catfile($scrd_path, $screen_module);
    if (-f $screen_path) {
        print "\n Won't owerwrite existing file:\n '$screen_path'\n";
        print " unless --force is in efect,\n";
        print "\tbut that's not an option yet ;)\n\n";
        return;
    }

    my $tt = Template->new(
        INCLUDE_PATH => $self->{opt}{templ_path},
        OUTPUT_PATH  => $scrd_path,
    );

    print "\n Output goes to\n '$scrd_path\n";
    print " File is '$screen_module'\n";

    $tt->process( 'screen.tt', \%data, $screen_module, binmode => ':utf8' )
        or die $tt->error(), "\n";

    return;
}

=head1 AUTHOR

Stefan Suciu, C<< <stefan\@s2i2.ro> >>

=head1 BUGS

Please report any bugs or feature requests to the autor.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tpda3::Devel::Screen

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

1; # End of Tpda3::Devel::Screen
