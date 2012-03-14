package Tpda3::Devel::Config;

use 5.008009;
use strict;
use warnings;

use Cwd;
use File::Spec::Functions;
use Config::General;
use Tie::IxHash::Easy;
use List::Compare;
use Template;
#require Tpda3::Config;

=head1 NAME

Tpda3::Devel::Config - The great new Tpda3::Devel::Config!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Tpda3::Devel::Config;

    my $foo = Tpda3::Devel::Config->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

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

Prepare data for the screen configuration file.

=cut

sub generate_config {
    my ($self) = @_;

    my $table  = $self->{opt}{table};
    my $module = $self->{opt}{module};

    require Tpda3::Devel::Table::Info;
    my $dti = Tpda3::Devel::Table::Info->new();

    my $table_info = $dti->table_info($table);
    my $maintable  = $self->generate_config_main($table_info);
    #my $deptable   = $self->generate_conf_dep();

    my $pkfields = $table_info->{pk_keys};
    my $fields   = $table_info->{fields};

    my $columns = $self->remove_dupes($pkfields, $fields);

    my %data = (
        maintable   => $maintable,
        modulename  => $module,
        moduledescr => ucfirst $module,
        pkfields    => $table_info->{pk_keys},
        fkfields    => $table_info->{fk_keys},
        columns     => $columns,
    );

    # Assemble using a template
    return $self->apply_template(\%data);
}

=head2 generate_config_main

Generate the L<maintable> section of the config file.

=cut

sub generate_config_main {
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
    $rec->{maintable}{pkcol}{name} = join ',', @{ $table_info->{pk_keys} };
    $rec->{maintable}{fkcol}{name} = join ',', @{ $table_info->{fk_keys} };

    print " Processing fields ...\n";
    foreach my $field ( @{ $table_info->{fields} } ) {
        my $info = $table_info->{info}{$field};
        my $type = $info->{type};
        print "  field: $info->{pos} -> $field ($type)\n";
        $rec->{maintable}{columns}{$field}{label}    = lcfirst $field;
        $rec->{maintable}{columns}{$field}{state}    = 'normal';
        $rec->{maintable}{columns}{$field}{ctrltype} = $self->ctrltype($type);
        $rec->{maintable}{columns}{$field}{width}
            = $self->len( $info->{length} );
        $rec->{maintable}{columns}{$field}{numscale}
            = $self->numscale( $info->{scale} );
        $rec->{maintable}{columns}{$field}{readwrite} = 'rw';
        $rec->{maintable}{columns}{$field}{findtype}  = 'full';
        $rec->{maintable}{columns}{$field}{bgcolor}   = 'white';
        $rec->{maintable}{columns}{$field}{datatype}   = $self->datatype($type);
    }
    print " done\n";

    return $conf->save_string($rec);
}

=head2 generate_config_dep

Generate the L<deptable> section of the config file.

=cut

sub generate_config_dep {
    my ($self, $table) = @_;

    # Tpda3::Config->instance($args);

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
            datatype   => $self->datatype($type),
        };
    }
    print " done\n";

    return $conf->save_string($rec);
}

=head2 apply_template

Generate a module configuration file.

=cut

sub apply_template {
    my ($self, $data) = @_;

    my $scr_cfg_name = lc $self->{opt}{module} . '.conf';
    my $scr_cfg_path = $self->screen_cfg_path();

    # Check if output file exists
    my $scr_cfg_file = $self->screen_cfg_file($scr_cfg_path);
    if (-f $scr_cfg_file) {
        print "\n Won't owerwrite existing file:\n '$scr_cfg_file'\n";
        print " unless --force is in efect,\n";
        print "\tbut that's not an option yet ;)\n\n";
        return $scr_cfg_file;
    }

    print "\n Output goes to\n '$scr_cfg_path\n";
    print " File is '$scr_cfg_file'\n";

    my $tt = Template->new(
        INCLUDE_PATH => $self->{opt}{templ_path},
        OUTPUT_PATH  => $scr_cfg_path,
    );

    $tt->process( 'config.tt', $data, $scr_cfg_name, binmode => ':utf8' )
        or die $tt->error(), "\n";

    return $scr_cfg_file;
}

=head2 screen_cfg_path

Screen configurations path.

=cut

sub screen_cfg_path {
    my $self = shift;

    my $dci     = Tpda3::Devel::Config::Info->new( $self->{opt} );
    my $cfgname = $dci->config_info()->{cfg_name};

    my $scr_cfg_path = catdir( Cwd::cwd(), "share/apps/${cfgname}/scr" );
    if ( !-d $scr_cfg_path ) {
        print "\n Can't write the new config to\n '$scr_cfg_path'\n";
        print " No such path!\n";
        die "\n\n  !!! Run '$0' from a Tpda3 application source dir !!!\n\n";
    }

    return $scr_cfg_path;
}

=head2 screen_cfg_file

Screen configuration file name.

=cut

sub screen_cfg_file {
    my ($self, $scr_cfg_path) = @_;

    my $scr_cfg_file = lc $self->{opt}{config} . '.conf';

    return catfile($scr_cfg_path, $scr_cfg_file);
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
    my $max_len = $self->{opt}{max_len};

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

    perldoc Tpda3::Devel::Config

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

1; # End of Tpda3::Devel::Config
