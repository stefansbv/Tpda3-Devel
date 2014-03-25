package Tpda3::Devel::Info::Table;

use 5.008009;
use strict;
use warnings;

require Tpda3::Db;

=head1 NAME

Tpda3::Devel::Info::Table - Database table related info.

=head1 VERSION

Version 0.20

=cut

our $VERSION = '0.20';

=head1 SYNOPSIS

Return database table related info.

    use Tpda3::Devel::Info::Table;

    my $dti  = Tpda3::Devel::Info::Table->new();
    my $info = $dti->table_info();
    my $list = $dti->table_list();

=head1 METHODS

=head2 new

=cut

sub new {
    my ( $class ) = @_;

    my $self = {
        dbi => Tpda3::Db->instance(),
    };

    bless $self, $class;

    return $self;
}

=head2 dbh

Database handle.

=cut

sub dbh {
    my $self = shift;
    return $self->{dbi}->dbh;
}

=head2 dbc

Module instance.

=cut

sub dbc {
    my $self = shift;
    return $self->{dbi}->dbc;
}

=head2 table_info

Return table informations.

=cut

sub table_info {
    my ($self, $table) = @_;

    unless ( $self->dbc->table_exists($table) ) {
        print "Table '$table' doesn't exists!\n";
        die;
    }

    my $table_info = $self->dbc->table_info_short($table);

    # PK and FK
    my $keys = $self->dbc->table_keys($table);

    my @fields;
    my %info;
    foreach my $k ( sort { $a <=> $b } keys %{$table_info} ) {
        my $name = $table_info->{$k}{name};
        my $info = $table_info->{$k};
        $info{$name} = $info;
        push @fields, $name;
    }

    return {
        table  => $table_info,
        keys   => $keys,
        fields => \@fields,
        info   => \%info,
        name   => $table,
    };
}

=head2 table_list

List database table.

=cut

sub table_list {
    my $self = shift;

    return $self->dbc->table_list();
}

=head1 AUTHOR

Stefan Suciu, C<< <stefan@s2i2.ro> >>

=head1 BUGS

Please report any bugs or feature requests to the autor.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tpda3::Devel

=head1 ACKNOWLEDGEMENTS

Options processing inspired from App::Ack (C) 2005-2011 Andy Lester.

=head1 LICENSE AND COPYRIGHT

Copyright 2012-2013 Stefan Suciu

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

1; # End of Tpda3::Devel::Info::Table
