package Tpda3::Devel;

use 5.010001;
use strict;
use warnings;

require Tpda3::Config;
require Tpda3::Db;
require Tpda3::Devel::Info::App;

use base qw( CLI::Framework );         # doc: CLI::Framework::Tutorial

=head1 NAME

Tpda3::Devel - The great new Tpda3::Devel!

=head1 VERSION

Version 0.50

=cut

our $VERSION = '0.50';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Tpda3::Devel;

    my $foo = Tpda3::Devel->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=cut

sub usage_text {
    my $self = shift;

    # The usage_text() hook in the Application Class is meant to return a
    # usage string describing the whole application.
    if ( $self->cache->get('mode') == 2 ) {
        return q{
tpda3d [--verbose|-v] [--user|-u <username>] [--pass|-p <password>]:

OPTIONS:
    --verbose|-v:   be verbose
    --user|-u:      user name
    --pass|-p:      password

COMMANDS:
    commands:       list available commands
    create:         create a new Tpda3 application distribution
};                                           # do not indent!
    }
    else {
        return q{
tpda3d [--verbose|-v] [--user|-u <username>] [--pass|-p <password>]:

OPTIONS:
    --verbose|-v:   be verbose
    --user|-u:      user name
    --pass|-p:      password

COMMANDS:
    commands:       list available commands
    generate:       generate a screen module and a screen configuration
    update:         update screen configuration
    info:           list info about...
};                                           # do not indent!
    }
}

sub option_spec {

    # The option_spec() hook in the Application class provides the option
    # specification for the whole application.
    return (
        [ 'verbose|v' => 'be verbose' ],
        [ 'user|u=s'  => 'database user name' ],
        [ 'pass|p=s'  => 'database password' ],
    );
}

sub validate_options {
    # The validate_options() hook can be used to ensure that the application
    # options are valid.
    my ($self, $opts) = @_;

    # ...nothing to check for this application
}

sub command_map {

    # In this *list*, the command names given as keys will be bound to the
    # command classes given as values.  This will be used by CLIF as a hash
    # initializer and the command_map_hashref() method will be provided to
    # return a hash created from this list for convenience.
    {   alias    => 'CLI::Framework::Command::Alias',
        commands => 'CLI::Framework::Command::List',
        info     => 'Tpda3::Devel::Command::Print',
        create   => 'Tpda3::Devel::Command::Create',
        update   => 'Tpda3::Devel::Command::Update',
        generate => 'Tpda3::Devel::Command::Generate',
    };
}

sub command_alias {
    # In this list, the keys are aliases to the command names given as values
    # (the values should be found as "keys" in command_map()).
    i   => 'info',
    upd => 'update',
    new => 'create',
    gen => 'generate',
}

=head2 init

This initialization is performed once for the application (default
behavior).

=cut

sub init {
    my ($app, $opts) = @_;

    # Where are we?
    my $info = Tpda3::Devel::Info::App->new();
    if ( $info->is_app_dir ) {

        # CWD is a Tpda3 module dir.
        my $mnemonic = $info->get_cfg_name();
        unless ($mnemonic) {
            die "Can't determine mnemonic name.";
        }
        my $user = $opts->user;
        my $pass = $opts->pass;
        my $args = {
            cfname => $mnemonic,
            user   => $user,
            pass   => $pass,
        };
        my $config = Tpda3::Config->instance($args);
        $app->cache->set( 'config' => $config );
        my $db;
        if ($user and $pass) {
            my $db = Tpda3::Db->instance;
            $app->cache->set( 'db' => $db );
        }
        $app->cache->set( 'mode' => 1 );

        my $name = $info->get_app_name;
        print "\nCurrent project: $name - scope: update the application.\n";
    }
    else {
        $app->cache->set( 'mode'   => 2 );
        print "\nCurrent project: none - scope: create new application.\n";
    }

    return 1;
}

# Use templates. How? Seems not to be used for all the output.
# sub render {
#     my ($app, $output) = @_;
#     print "***\n";
#     print "* $output";
#     print "***\n";
# }

=head1 AUTHOR

Stefan Suciu, C<< <stefan at s2i2.ro> >>

=head1 BUGS

Please report any bugs or feature requests to ...

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

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Stefan Suciu.

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
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

=cut

1; # End of Tpda3::Devel
