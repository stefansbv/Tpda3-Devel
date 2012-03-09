package Tpda3::Devel::Table::Info;

use 5.008009;
use strict;
use warnings;

use Tpda3::Db;

=head1 NAME

Tpda3::Devel::Table::Info - The great new Tpda3::Devel::Table::Info!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Tpda3::Devel::Table::Info;

    my $foo = Tpda3::Devel::Table::Info->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS


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

sub get_table_info {
    my ($self, $table) = @_;

    $self->{_db} = Tpda3::Db->instance;

    my $dbc = $self->{_db}->dbc;
    my $dbh = $self->{_db}->dbh;

    unless ( $dbc->table_exists($table) ) {
        print "Table '$table' doesn't exists!\n";
        return;
    }

    # my $cons = $dbc->constraints_list($table);
    # print Dumper( $cons);

    my $table_info = $dbc->table_info_short($table);

    # PK and FK
    my $pk_keys = $dbc->table_keys($table);
    my $fk_keys = $dbc->table_keys($table, 'foreign');

    my @fields;
    my %info;
    foreach my $k ( sort { $a <=> $b } keys %{$table_info} ) {
        my $name = $table_info->{$k}{name};
        my $info = $table_info->{$k};
        $info{$name} = $info;
        push @fields, $name;
    }

    return {
        table   => $table_info,
        pk_keys => $pk_keys,
        fk_keys => $fk_keys,
        fields  => \@fields,
        info    => \%info,
        name    => $table,
    };
}

sub list_tables {
    my $self = shift;

    my $args = config_instance_args();

    Tpda3::Config->instance($args);

    # Connect to database
    my $db = Tpda3::Db->instance;

    my $dbc = $db->dbc;
    my $dbh = $db->dbh;

    my $list = $dbc->table_list();

    print " > Tables:\n";
    foreach my $name ( @{$list} ) {
        print "   - $name\n";
    }

    return;
}

=head1 AUTHOR

Stefan Suciu, C<< <stefansbv at users.sourceforge.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-tpda3-devel-table-info at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Tpda3-Devel-Table-Info>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tpda3::Devel::Table::Info


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Tpda3-Devel-Table-Info>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Tpda3-Devel-Table-Info>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Tpda3-Devel-Table-Info>

=item * Search CPAN

L<http://search.cpan.org/dist/Tpda3-Devel-Table-Info/>

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

1; # End of Tpda3::Devel::Table::Info
