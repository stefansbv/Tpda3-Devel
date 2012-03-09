package Tpda3::Devel::Config::Info;

use 5.008009;
use strict;
use warnings;

use Data::Dumper;

use File::Basename;
use File::Spec::Functions;

use Tpda3::Config;

=head1 NAME

Tpda3::Devel::Config::Info - The great new Tpda3::Devel::Config::Info!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Tpda3::Devel::Config::Info;

    my $foo = Tpda3::Devel::Config::Info->new();
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

=head2 function1

=cut

sub get_config_info {
    my ($self) = @_;

    my $appcfg = Tpda3::Config->instance();

    my $cfg_name   = $appcfg->cfname;
    my $cfg_apps   = $appcfg->cfapps;
    my $cfg_module = $appcfg->application->{module};

    # Check configured widget type
    my $cfg_widget = $appcfg->application->{widgetset};
    die "Fatal!: $cfg_widget toolkit not supported!"
        unless $cfg_widget eq 'Tk';

    print Dumper( $self->{opt});
    my $config_file = $self->locate_config_file(
        $self->{opt}{config_file},
        catdir( $cfg_apps, $cfg_name, 'scr'), # from Tpda3::Config ???
        );

    return {
        config_file  => $config_file,
        cfg_name     => $cfg_name,
        cfg_apps     => $cfg_apps,
        cfg_module   => $cfg_module,
    };
}

sub locate_config_file {
    my ($self, $file, $cfg_scr_path) = @_;

    # # Check if has extension and add it if not
    # my (undef, undef, $type) = fileparse($file, '\.conf' );
    # unless ($type eq '.conf') {
    #     $file .= '.conf';
    # }

    # First, check in the CWD
    if (-f $file) {
        print "Using config file located in the CWD\n";
        return $file;
    }

    # Check in the screen config path of the application
    $file = $self->scrcfg_file_path($file, $cfg_scr_path);
    if (-f $file) {
        print "Using config file from the app config path\n";
        return $file;
    }

    die "Failed to locate the config file!";
}

sub scrcfg_file_path {
    my ($self, $file, $cfg_scr_path) = @_;

    return catfile( $cfg_scr_path, $file );
}

=head1 AUTHOR

Stefan Suciu, C<< <stefansbv at users.sourceforge.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-tpda3-devel-config-info at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Tpda3-Devel-Config-Info>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tpda3::Devel::Config::Info


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Tpda3-Devel-Config-Info>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Tpda3-Devel-Config-Info>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Tpda3-Devel-Config-Info>

=item * Search CPAN

L<http://search.cpan.org/dist/Tpda3-Devel-Config-Info/>

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

1; # End of Tpda3::Devel::Config::Info
