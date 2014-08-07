package Tpda3::Devel::Info::Table;

# ABSTRACT: Database table related info

use 5.010001;
use strict;
use warnings;

=head1 SYNOPSIS

Return database table related info.

    use Tpda3::Devel::Info::Table;

    my $dti  = Tpda3::Devel::Info::Table->new();
    my $info = $dti->table_info();
    my $list = $dti->table_list();

=head2 new

Constructor.

=cut

sub new {
    my ( $class ) = @_;

    my $self = {};
    bless $self, $class;
    $self->{dbi} = Tpda3::Db->instance;

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
        die "Table '$table' doesn't exists!\n";
    }

    my $table_info = $self->dbc->table_info_short($table);

    # PK and FK
    my $pk_keys = $self->dbc->table_keys($table);
    my $fk_keys = $self->dbc->table_keys($table, 'foreign');

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

=head2 table_list

List database table.

=cut

sub table_list {
    my $self = shift;
    return $self->dbc->table_list();
}

1;
