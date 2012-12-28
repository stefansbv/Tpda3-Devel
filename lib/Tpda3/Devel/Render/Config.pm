package Tpda3::Devel::Render::Config;

use 5.008009;
use strict;
use warnings;
use utf8;
use Ouch;

use Data::Dumper;

use Config::General;
use Tie::IxHash::Easy;
use List::Compare;

require Tpda3::Devel::Info::Table;
require Tpda3::Devel::Render;

=head1 NAME

Tpda3::Devel::Render::Config - Create a screen configuration file.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    require Tpda3::Devel::Render::Config;

    my $foo = Tpda3::Devel::Render::Config->new();

=head1 METHODS

=head2 new

Constructor.

=cut

sub new {
    my ( $class, $opt ) = @_;

    my $self = {};

    bless $self, $class;

    $self->{opt} = $opt;

    $self->_init;

    return $self;
}

=head2 _init

Initializations.

=cut

sub _init {
    my $self = shift;

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

    return;
}

=head2 generate_config

Prepare data for the screen configuration file and create new file.

=cut

sub generate_config {
    my $self = shift;

    my $screen = $self->{opt}{screen};

    die "Need a screen name!" unless $screen;

    my $ic = Tpda3::Devel::Info::Config->new($self->{opt});
    my $it = Tpda3::Devel::Info::Table->new();

    my @tables = split /,/, $self->{opt}{table}, 2;
    my $table_main = $tables[0];

    die "Need a table name!" unless $table_main;

    print " Main table is '$table_main'\n";

    my $table_info = $it->table_info( $table_main );
    my $maintable_data  = $self->prepare_config_data_main($table_info);
    print Dumper( $maintable_data );
    my $dep_table_data;
    my $deptable_name = $tables[1];
    $dep_table_data = $self->prepare_config_data_dep($deptable_name)
        if $deptable_name;

    my $pkfields = $table_info->{pk_keys};
    my $fields   = $table_info->{fields};

    my $columns = $self->remove_dupes($pkfields, $fields);

    my %data = (
        maintable   => $maintable_data,
        deptable    => $dep_table_data,
        modulename  => $screen,
        moduledescr => $screen,
        pkfields    => $table_info->{pk_keys},
        fkfields    => $table_info->{fk_keys},
        columns     => $columns,
    );

    # Assemble using a template
    return $self->render_config(\%data);
}

=head2 prepare_config_data_main

Generate the L<maintable> section of the config file.

=cut

sub prepare_config_data_main {
    my ($self, $table_info) = @_;

    my $table = $table_info->{name};

    my $conf = Config::General->new(
        -AllowMultiOptions => 1,
        -SplitPolicy       => 'equalsign',
        -Tie               => "Tie::IxHash",
    );

    my $rec = {};
    tie %{$rec}, 'Tie::IxHash::Easy';

    $rec->{maintable}{name} = $table;
    $rec->{maintable}{view} = $table; # "v_$table" -> VIEW name

    # PK and FK
    ouch 404, qq{ No PK key(s) for the '$table' table?}
        unless $table_info->{pk_keys};

    $rec->{maintable}{pkcol}{name} = join ',', @{ $table_info->{pk_keys} };
    $rec->{maintable}{fkcol}{name} = join ',', @{ $table_info->{fk_keys} }
        if $table_info->{fk_keys};           # optional?

    print " Processing fields ...\n";
    foreach my $field ( @{ $table_info->{fields} } ) {
        my $info = $table_info->{info}{$field};
        my $type = $info->{type};
        print "  field: $info->{pos} -> $field ($type)\n";
        $rec->{maintable}{columns}{$field}{label} = lcfirst $field;
        $rec->{maintable}{columns}{$field}{state} = 'normal';
        $rec->{maintable}{columns}{$field}{ctrltype}
            = $self->ctrltype($type);
        $rec->{maintable}{columns}{$field}{displ_width}
            = $self->len( $info->{length} );
        $rec->{maintable}{columns}{$field}{valid_width}
            = $self->len( $info->{length} );
        $rec->{maintable}{columns}{$field}{numscale}
            = $self->numscale( $info->{scale} );
        $rec->{maintable}{columns}{$field}{readwrite} = 'rw';
        $rec->{maintable}{columns}{$field}{findtype}  = 'full';
        $rec->{maintable}{columns}{$field}{bgcolor}   = 'white';
        $rec->{maintable}{columns}{$field}{datatype}
            = $self->datatype($type);
    }
    print " done\n";

    return $conf->save_string($rec);
}

=head2 prepare_config_data_dep

Generate the L<deptable> section of the config file.

=cut

sub prepare_config_data_dep {
    my ($self, $table) = @_;

    # Connect to database

    my $db  = Tpda3::Db->instance;
    my $dbc = $db->dbc;
    my $dbh = $db->dbh;

    unless ( $dbc->table_exists($table) ) {
        print "Table '$table' doesn't exists!\n";
        return;
    }

    # my $cons = $dbc->constraints_list('fact_tr_det');

    my $info = $dbc->table_info_short($table);
    my $keys = $dbc->table_keys($table);

    my $conf = Config::General->new(
        -AllowMultiOptions => 1,
        -SplitPolicy       => 'equalsign',
        -Tie               => "Tie::IxHash",
    );

    my $rec = {};
    tie %{$rec}, "Tie::IxHash";

    tie %{ $rec->{deptable} }, "Tie::IxHash";
    tie %{ $rec->{deptable}{name} }, "Tie::IxHash";
    tie %{ $rec->{deptable}{view} }, "Tie::IxHash";

    $rec->{deptable}{name} = $table;
    $rec->{deptable}{view} = "v_$table";

    $rec->{deptable}{updatestyle} = 'delete+add';
    $rec->{deptable}{selectorcol} = '';
    $rec->{deptable}{colstretch}  = '1';
    $rec->{deptable}{orderby}     = 'id_something';

    my $key_names = [qw{pkcol fkcol}];    # first is pk second is fk
    foreach my $key ( @{$keys} ) {
        my $key_name = shift @{$key_names};
        tie %{ $rec->{deptable}{$key_name} }, 'Tie::IxHash';
        $rec->{deptable}{$key_name}{name}  = $key;
        $rec->{deptable}{$key_name}{width} = '';
        $rec->{deptable}{$key_name}{label} = '';
    }

    print " Processing ...\n";
    tie %{ $rec->{deptable}{columns} }, "Tie::IxHash";
    foreach my $k ( sort { $a <=> $b } keys %{$info} ) {
        print "  field: $k -> ";
        my $v = $info->{$k};

        my $name = $v->{name};
        my $type = $v->{type};
        print "$name ($type)\n";

        $rec->{deptable}{columns}{$name} = {
            id        => $k,
            label     => $name,
            width     => $self->len( $v->{length} ),
            readwrite => 'rw',
            tag       => 'ro_center',
            numscale  => $self->numscale( $v->{scale} ),
            datatype  => $self->datatype($type),
        };
    }
    print " done\n";

    return $conf->save_string($rec);
}

=head2 render_config

Generate a module configuration file.

Parameters:

The screen configuration file name and the configuration data.

=cut

sub render_config {
    my ($self, $data) = @_;

    my $scrcfg_fn   = $self->{opt}{config_fn};
    my $output_path = $self->{opt}{config_ap};

    use Data::Printer;
    p $data;

    Tpda3::Devel::Render->render( 'config', $scrcfg_fn, $data, $output_path );

    return;
}

=head1 DEFAULTS

Subs to handle defaults

=cut

=head2 ctrltype

Control type.  The numeric and integer types => Tk::Entry.  The char
type is good candidate for Tk::JComboBox entries (m).  And of course
the date type for Tk::DateEntry.

=cut

sub ctrltype {
    my ($self, $type) = @_;

    $type = lc $type;

    #      when column type is ...    ctrl type is ...
    return $type eq q{}               ? 'x'
         : $type eq 'date'            ? 'd'
         : $type eq 'character'       ? 'm'
         : $type eq 'text'            ? 't'
         :                              'e';
}

=head2 numscale

Numeric scale.

=cut

sub numscale {
    my ($self, $scale) = @_;

    return defined $scale ? $scale : 0;
}

=head2 len

Length.

=cut

sub len {
    my ($self, $len) = @_;

    $len ||= 10;
    my $max_len = 30;                   # max length, hardwired config

    return ($len > $max_len) ? $max_len : $len;
}

=head2 datatype

Column type.

=cut

sub datatype {
    my ($self, $type) = @_;

    $type = lc $type;

    return
        exists $self->{types}{$type} ? $self->{types}{$type} : 'alphanumplus';
}

=head2 remove_dupes

Remove key fields.

=cut

sub remove_dupes {
    my ($self, $pkfields, $fields) = @_;

    my $lc = List::Compare->new( $pkfields, $fields );
    my @columns = $lc->get_complement;

    return \@columns;
}

=head1 AUTHOR

Stefan Suciu, C<< <stefan@s2i2.ro> >>

=head1 BUGS

Please report any bugs or feature requests to the autor.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tpda3::Devel::Render::Config

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

1; # End of Tpda3::Devel::Render::Config
