package Tpda3::Devel::Render::Config;

# ABSTRACT: Create a screen configuration file

use 5.010001;
use strict;
use warnings;
use utf8;

use Config::General;
use Tie::IxHash::Easy;
use List::Compare;
use Path::Tiny;

require Tpda3::Devel::Info::Config;
require Tpda3::Devel::Info::Table;
require Tpda3::Devel::Render;


sub new {
    my $class = shift;

    my $self = {};

    bless $self, $class;

    $self->_init;

    return $self;
}


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


sub generate_config {
    my ($self, $opts) = @_;

    my $screen = $opts->{screen};

    my $ic = Tpda3::Devel::Info::Config->new;
    my $it = Tpda3::Devel::Info::Table->new;

    my @tables = split /,/, $opts->{tables}, 2;
    my $table_main = $tables[0];

    die "Need a table name!" unless $table_main;

    my $table_info = $it->table_info( $table_main );
    my $maintable_data = $self->prepare_config_data_main($table_info);

    my $dep_table_data;
    my $deptable_name = $tables[1];
    $dep_table_data = $self->prepare_config_data_dep($deptable_name)
        if $deptable_name;

    my $key_fields = $table_info->{pk_keys};
    my $fields     = $table_info->{fields};

    my $columns = $self->remove_dupes($key_fields, $fields);

    my $data = {
        maintable   => $maintable_data,
        deptable    => $dep_table_data,
        modulename  => $screen,
        moduledescr => $screen,
        key_fields  => $key_fields,
        columns     => $columns,
    };

    # Assemble using a template
    $self->render_config($opts, $data);

    return;
}


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

    # Keys
    die qq{ No key(s) for the '$table' table? }
        unless $table_info->{pk_keys};

    my @keys  = @{ $table_info->{pk_keys} };
    my $pkcol = $keys[0];
    if (scalar @keys == 1) {
        $keys[0] = '[ ' . $keys[0] . ' ]';
    }
    elsif (scalar @keys < 1) {
        die "Error about the table keys!\n";
    }
    push @{ $rec->{maintable}{keys}{name} }, @keys;

    # print " Processing fields ...\n";
    foreach my $field ( @{ $table_info->{fields} } ) {
        my $info  = $table_info->{info}{$field};
        my $type  = $info->{type};
        my $state = $pkcol eq $field ? 'disabled' : 'normal';

        # print "  field: $info->{pos} -> $field ($type)\n";
        $rec->{maintable}{columns}{$field}{label} = $self->label($field);
        $rec->{maintable}{columns}{$field}{state} = $state;
        $rec->{maintable}{columns}{$field}{ctrltype}
            = $self->ctrltype($info);
        $rec->{maintable}{columns}{$field}{displ_width}
            = $self->len($info);
        $rec->{maintable}{columns}{$field}{valid_width}
            = $self->len($info);
        $rec->{maintable}{columns}{$field}{numscale}
            = $self->numscale( $info->{scale} );
        $rec->{maintable}{columns}{$field}{readwrite} = 'rw';
        $rec->{maintable}{columns}{$field}{findtype}  = 'full';
        $rec->{maintable}{columns}{$field}{bgcolor}   = 'white';
        $rec->{maintable}{columns}{$field}{datatype}
            = $self->datatype($type);
    }
    # print " done\n";

    return $conf->save_string($rec);
}


sub is_key {
    my ($self, $field) = @_;
    return 0;
}


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
    else {
        print "Processing table: $table\n";
    }

    my $info = $dbc->table_info_short($table);
    my $keys = $dbc->table_keys($table, 'foreign');

    my $conf = Config::General->new(
        -AllowMultiOptions => 1,
        -SplitPolicy       => 'equalsign',
        -Tie               => "Tie::IxHash",
    );

    my $rec = {};
    tie %{$rec}, "Tie::IxHash";

    tie %{ $rec->{deptable}{tm1} }, "Tie::IxHash";
    tie %{ $rec->{deptable}{tm1}{name} }, "Tie::IxHash";
    tie %{ $rec->{deptable}{tm1}{view} }, "Tie::IxHash";

    $rec->{deptable}{tm1}{name} = $table;
    $rec->{deptable}{tm1}{view} = "v_$table";

    $rec->{deptable}{tm1}{updatestyle} = 'delete+add';
    $rec->{deptable}{tm1}{selectorcol} = '';
    $rec->{deptable}{tm1}{colstretch}  = '1';
    $rec->{deptable}{tm1}{orderby}     = 'id_something';

    tie %{ $rec->{deptable}{tm1}{keys} }, 'Tie::IxHash';
    my @keys = @{$keys};
    if (scalar @keys == 1) {
        $keys[0] = '[ ' . $keys[0] . ' ]';
    }
    elsif (scalar @keys < 1) {
        die "Error about the dependent table keys!\n";
    }
    push @{ $rec->{deptable}{tm1}{keys}{name} }, @keys;

    # print " Processing ...\n";
    tie %{ $rec->{deptable}{tm1}{columns} }, "Tie::IxHash";
    foreach my $k ( sort { $a <=> $b } keys %{$info} ) {
        # print "  field: $k -> ";
        my $v = $info->{$k};

        my $name = $v->{name};
        my $type = $v->{type};
        # print "$name ($type)\n";

        $rec->{deptable}{tm1}{columns}{$name} = {
            id        => $k,
            label     => $name,
            width     => $self->len($v),
            readwrite => 'rw',
            tag       => 'ro_center',
            numscale  => $self->numscale( $v->{scale} ),
            datatype  => $self->datatype($type),
        };
    }
    # print " done\n";

    return $conf->save_string($rec);
}


sub render_config {
    my ($self, $opts, $data) = @_;

    my $app_info = Tpda3::Devel::Info::App->new;

    my $scrcfg    = lc $opts->{screen};
    my $scrcfg_fn = "$scrcfg.conf";
    my $scrcfg_ap = $app_info->get_config_ap_for('scr');

    if ( -f path($scrcfg_ap, $scrcfg_fn) ) {
        print "Creating screen config .... skipped\n";
        return;
    }

    my $args = {
        type        => 'config',
        output_file => $scrcfg_fn,
        data        => { r => $data },
        output_path => $scrcfg_ap,
        templ_path  => undef,
    };

    Tpda3::Devel::Render->render($args);

    print "Creating screen config ....... done\n";

    return;
}



sub ctrltype {
    my ($self, $info) = @_;

    my $type = lc $info->{type};
    my $len  = $info->{length} // 10;

    #                when column type is ...            ctrl type is ...
    return  $type eq q{}                              ? 'x'
         :  $type eq 'blob'                           ? 't'
         :  $type eq 'date'                           ? 'd'
         :  $type eq 'character'                      ? 'm'
         :  $type eq 'text'                           ? 't'
         : ($type eq 'varchar' and $len > 200 )       ? 't'
         :                                              'e'
         ;
}


sub numscale {
    my ($self, $scale) = @_;
    return defined $scale ? $scale : 0;
}


sub len {
    my ($self, $info) = @_;

    my $type = lc $info->{type};
    my $len  = $info->{length} // $type eq 'text' ? 30 : 10;

    my $max_len = 30;           # max length, hardwired config
    my $min_len = 5;            # min length, hardwired config

    return
       $len >= $max_len  ? $max_len
     : $len <= $min_len  ? $min_len
     :                     $len
     ;
}


sub datatype {
    my ( $self, $type ) = @_;
    $type = lc $type;
    return
        exists $self->{types}{$type} ? $self->{types}{$type} : 'alphanumplus';
}


sub remove_dupes {
    my ($self, $pkfields, $fields) = @_;

    my $lc = List::Compare->new( $pkfields, $fields );
    my @columns = $lc->get_complement;

    return \@columns;
}


sub label {
    my ($self, $label) = @_;

    $label = ucfirst $label;
    $label =~ s{_}{ }g;

    return $label;
}

1;

__END__

=pod

=head2 new

Constructor.

=head2 _init

Initializations.

=head2 generate_config

Prepare data for the screen configuration file and create the new
file.

=head2 prepare_config_data_main

Generate the L<maintable> section of the config file.

=head2 is_key

Fake, not implemented!

=head2 prepare_config_data_dep

Generate the L<deptable> section of the config file.

=head2 render_config

Generate a module configuration file.

Parameters:

The screen configuration file name and the configuration data.

=head1 DEFAULTS

Subs to handle defaults

=head2 ctrltype

Control type.  The numeric and integer types => Tk::Entry.  The char
type is good candidate for Tk::JComboBox entries (m).  And of course
the date type for Tk::DateEntry.

If the length of the column is greater than B<200> make it a text
entry.

=head2 numscale

Numeric scale.

=head2 len

Length of the field in chars.

=head2 datatype

Column type.

=head2 remove_dupes

Remove key fields.

=head2 label

Remove underscores form label and make the first character upper case.

=cut
