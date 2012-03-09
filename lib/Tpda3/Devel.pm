package Tpda3::Devel;

use 5.008009;
use strict;
use warnings;

use Data::Dumper;

use Getopt::Long;
use Pod::Usage;
use Term::ReadKey;
use File::ShareDir qw(dist_dir);
use File::Spec::Functions;

use Tpda3::Config;
use Tpda3::Devel::Config;
use Tpda3::Devel::Screen;

=head1 NAME

Tpda3::Devel - The great new Tpda3::Devel!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Tpda3::Devel;

    my $foo = Tpda3::Devel->new();
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

    $self->_init($opt);

    return $self;
}

=head2 _init

Initializations.

=cut

sub _init {
    my ( $self, $opt ) = @_;

    $self->{opt} = $opt;

    # Definitions
    $self->{types} = {
        'blob'              => 'alphanumplus',
        'char'              => 'alpha',
        'character varying' => 'alphanumplus',
        'd_float'           => 'numeric',
        'date'              => 'date',
        'decimal'           => 'numeric',
        'double'            => 'numeric',
        'float'             => 'numeric',
        'int64'             => 'integer',
        'integer'           => 'integer',
        'numeric'           => 'numeric',
        'smallint'          => 'integer',
        'text'              => 'alphanumplus',
        'time'              => 'time',
        'timestamp'         => 'timestamp',
        'varchar'           => 'alphanumplus',
    };

    my $user = $opt->{user} ? $opt->{user} : $self->read_username();
    my $pass = $opt->{pass} ? $opt->{pass} : $self->read_password();

    my $args = {
        cfname => $opt->{config},
        user   => $user,
        pass   => $pass,
    };

    Tpda3::Config->instance($args);

    return;
}

=head2 get_options

Parse command line options.

=cut

sub get_options {
    my $self = shift;

    my %opt = ();
    my $getopt_specs = {
        'c|config=s'      => \$opt{config},
        'l|list:s'        => \$opt{list},
        't|table:s'       => \$opt{table},
        'u|user=s'        => \$opt{user},
        'p|password=s'    => \$opt{pass},
        's|screen=s'      => \$opt{screen},
        'g|no-config-gen' => \$opt{ncg},
        'v|version'       => sub { version(); exit; },
        'help|?:s'        => sub { shift; help(@_); exit; },
        'm|man'           => sub {
            require Pod::Usage;
            Pod::Usage::pod2usage(
                {   -verbose => 2,
                    -exitval => 0,
                }
            );
        },
    };

    my $parser = Getopt::Long::Parser->new();
    $parser->configure( 'bundling', 'no_ignore_case', );
    $parser->getoptions( %{$getopt_specs} ) or
        die( 'See tpda3dev --help, tpda3dev --man for options.' );

    # Where are module-level shared data files kept
    my $templ_path = catdir( dist_dir('Tpda3-Devel'), 'templates');

    my %defaults = (
        max_len    => 30,
        templ_path => $templ_path,    # TT templates path
    );

    while ( my ( $key, $value ) = each %defaults ) {
        if ( not defined $opt{$key} ) {
            $opt{$key} = $value;
        }
    }

    return \%opt;
}

sub make_config {
    my $self = shift;

    my $cfg = Tpda3::Devel::Config->new( $self->{opt} );
    my $config_file;
    if ( $self->{opt}{ncg} ) {
        print "Don't generate config, use this one\n";
        $config_file = $self->{opt}{screen} . '.conf';
    }
    else {
        $config_file = $cfg->make_config();
    }

    if ( -f $config_file ) {
        print "Screen config file is '$config_file'.\n";
        $self->{opt}{config_file} = $config_file;
        $self->make_screen($config_file);
    }
    else {
        print "Failed to locate config file!\n";
    }

    return;
}

sub make_screen {
    my ($self) = @_;

    my $scr = Tpda3::Devel::Screen->new( $self->{opt} );
    my $screen = $scr->make_screen();

    if ( $screen and -f $screen ) {
        print "Screen module file is '$screen'.\n";
    }
    else {
        print "Failed to create screen module file!\n";
    }

    return;
}

=head2 read_username

Read use name.

=cut

sub read_username {
    my $self = shift;

    print 'Enter your username: ';

    my $user = ReadLine(0);
    chomp $user;

    return $user;
}

=head2 read_password

Read password.

=cut

sub read_password {
    my $self = shift;

    print 'Enter your password: ';

    ReadMode('noecho');
    my $pass = ReadLine(0);
    print "\n";
    chomp $pass;
    ReadMode('normal');

    return $pass;
}

sub help {
    print " help!\n";
}

sub version {
    print " version\n";
}

=head1 AUTHOR

Stefan Suciu, C<< <stefan\@s2i2.ro> >>

=head1 BUGS

Please report any bugs or feature requests to the autor.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tpda3::Devel

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Tpda3-Devel>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Tpda3-Devel>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Tpda3-Devel>

=item * Search CPAN

L<http://search.cpan.org/dist/Tpda3-Devel/>

=back

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

1; # End of Tpda3::Devel
