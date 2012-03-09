package Tpda3::Devel::Screen;

use 5.008009;
use strict;
use warnings;

use Data::Dumper;

use Template;
use Config::General qw{ParseConfig};

use Tpda3::Devel::Config::Info;

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

=cut

sub new {
    my ( $class, $opt ) = @_;

    my $self = {};

    bless $self, $class;

    $self->{opt} = $opt;

    return $self;
}

=head2 make_pm

=cut

sub make_screen {
    my $self = shift;

    my $screen = $self->{opt}{screen};

    my $dci = Tpda3::Devel::Config::Info->new($self->{opt});
    my $cfg = $dci->get_config_info($screen, $self->{opt}{config_file});

    tie my %cfg, "Tie::IxHash";     # keep the order

    %cfg = ParseConfig(
        -ConfigFile => $cfg->{config_file},
        -Tie        => 'Tie::IxHash',
    );

    # TODO: Make user (developer) config with this data
    my %data = (
        copy_author => 'Ștefan Suciu',
        copy_email  => 'stefan@s2i2.ro',
        copy_year   => '2012',
        module      => $cfg->{cfg_module},
        screen      => $screen,
        columns     => $cfg{maintable}{columns},
    );

    my $tt = Template->new(
        INCLUDE_PATH => $self->{opt}{templ_path},
        OUTPUT_PATH  => './',
    );

    my $screen_module = ucfirst $self->{opt}{screen} . '.pm';

    $tt->process( 'screen.tt', \%data, $screen_module, binmode => ':utf8' )
        or die $tt->error(), "\n";

    return $screen_module;
}

=head1 AUTHOR

Stefan Suciu, C<< <stefansbv at users.sourceforge.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-tpda3-devel-config at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Tpda3-Devel-Config>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tpda3::Devel::Screen


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Tpda3-Devel-Config>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Tpda3-Devel-Config>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Tpda3-Devel-Config>

=item * Search CPAN

L<http://search.cpan.org/dist/Tpda3-Devel-Config/>

=back


=head1 ACKNOWLEDGEMENTS


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
