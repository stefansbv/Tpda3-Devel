package Tpda3::Devel::Config;

use 5.008009;
use strict;
use warnings;

use Data::Dumper;
use Tpda3::Devel::Table::Info;

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

=cut

sub new {
    my ( $class, $opt ) = @_;

    my $self = {};

    bless $self, $class;

    $self->{opt} = $opt;

    return $self;
}

sub make_config {
    my ($self) = @_;

    my $table  = $self->{opt}{screen};
    my $screen = $self->{opt}{screen};
    print "Screen name: $screen\n";
    print "Table name : $table\n";

    # Gather info from table(s)
    my $dti = Tpda3::Devel::Table::Info->new();
    my $table_info = $dti->get_table_info($table);
    # print Dumper( $table_info);

    my $maintable = $self->make_config_main($table_info);
    # make_conf_dep();

    my $pkfields = $table_info->{pk_keys};
    my $fields   = $table_info->{fields};

    my $columns = $self->remove_dupes($pkfields, $fields);

    my %data = (
        maintable   => $maintable,
        screenname  => lc $screen,
        screendescr => $screen,
        pkfields    => $table_info->{pk_keys},
        fkfields    => $table_info->{fk_keys},
        columns     => $columns,
    );

    # Assemble using a template
    return $self->apply_template(\%data);
}

=head2 make_conf_main

=cut

sub make_config_main {
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
    $rec->{maintable}{view} = "v_$table";

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
        $rec->{maintable}{columns}{$field}{coltype}   = $self->coltype($type);
    }
    print " done\n";

    return $conf->save_string($rec);
}

sub make_config_dep {
    my $self = shift;
    my $table = shift;

    my $args = config_instance_args();

    Tpda3::Config->instance($args);

    # Connect to database

    my $db = Tpda3::Db->instance;

    my $dbc = $db->dbc;
    my $dbh = $db->dbh;

    unless ( $dbc->table_exists($table) ) {
        print "Table '$table' doesn't exists!\n";
        return;
    }

    # my $cons = $dbc->constraints_list('fact_tr_det');
    # print Dumper( $cons);

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
            coltype   => $self->coltype($type),
        };
    }
    print " done\n";

    return $conf->save_string($rec);
}

sub apply_template {
    my ($self, $data) = @_;

    my $tt = Template->new(
        INCLUDE_PATH => $self->{opt}{templ_path},
        OUTPUT_PATH  => './',
    );

    my $screen  = lc $self->{opt}{screen};
    my $outfile = "$screen.conf";     # output screen module file name

    $tt->process( 'config.tt', $data, $outfile, binmode => ':utf8' )
        or die $tt->error(), "\n";

    if ( -f $outfile ) {
        print "$outfile created.\n";
    }
    else {
        print "$outfile creation failed!\n";
    }

    return $screen;
}

#-- Subs to handle defaults

sub ctrltype {
    my ($self, $type) = @_;

    $type = lc $type;

    # char type is good candidate for Tk::JComboBox entries (m)

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

=head2 coltype

Column type.

=cut

sub coltype {
    my ($self, $type) = @_;

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

=head1 AUTHOR

Stefan Suciu, C<< <stefansbv at users.sourceforge.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-tpda3-devel-config at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Tpda3-Devel-Config>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tpda3::Devel::Config


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

1; # End of Tpda3::Devel::Config
