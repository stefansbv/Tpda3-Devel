package Tpda3::Devel::Edit::Config;

use 5.008009;
use strict;
use warnings;
use utf8;

use Cwd;
use File::Basename;
use File::Spec::Functions;
use Config::General qw{ParseConfig};
use File::Copy;

require Tpda3::Devel::Info::App;
require Tpda3::Devel::Info::Config;
require Tpda3::Devel::Render;

=head1 NAME

Tpda3::Devel::Edit::Config - Tpda3 application config update.

=head1 VERSION

Version 0.14

=cut

our $VERSION = '0.14';

=head1 SYNOPSIS

    use Tpda3::Devel::Edit::Config;

    my $dci = Tpda3::Devel::Edit::Config->new();
    my info = $dci->config_info();
    ...

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

=head2 config_update

Read the old config file section by section and use a template to
preserve | edit the comments and the order of the sections.

=cut

sub config_update {
    my $self = shift;

    my $app_info = Tpda3::Devel::Info::App->new();

    my $scrcfg_fn   = $self->{opt}{config_fn};
    my $scrcfg_ap   = $self->{opt}{config_ap};
    my $scrcfg_apfn = $self->{opt}{config_apfn};

    my $data = $self->prepare_config_data($scrcfg_apfn);

    # Backup existing config file
    my $backup_ok = $self->backup_config( $scrcfg_ap, $scrcfg_fn );
    unless ($backup_ok) {
        die "Backup of old config file failed!";
    }

    Tpda3::Devel::Render->render( 'config-update', $scrcfg_fn, $data,
        $scrcfg_ap );

    return;
}

=head2 prepare_config_data

Prepare and return config data.

Force array is on, so we must take special care about [ field ]
constructs.

=cut

sub prepare_config_data {
    my ($self, $scrcfg_fn) = @_;

    tie my %cfg, "Tie::IxHash";    # keep the order

    my $conf = Config::General->new(
        -UTF8       => 1,
        -ForceArray => 1,
        -ConfigFile => $scrcfg_fn,
        -Tie        => 'Tie::IxHash',
    );

    %cfg = $conf->getall;

    my $screen          = make_screen( $cfg{screen} );
    my $defaultreport   = make_defaultreport( $cfg{defaultreport} );
    my $defaultdocument = make_defaultdocument( $cfg{defaultdocument} );
    my $lists_ds        = make_lists_ds( $cfg{lists_ds} );
    my $list_header     = make_list_header( $cfg{list_header} );
    my $bindings        = make_bindings( $cfg{bindings} );
    my $tablebindings   = make_tablebindings( $cfg{tablebindings} );
    my $maintable       = make_maintable( $cfg{maintable} );
    my $deptable        = make_deptable( $cfg{deptable} );
    my $scrtoolbar      = make_scrtoolbar( $cfg{scrtoolbar} );
    my $toolbar         = make_toolbar( $cfg{toolbar} );

    my %data = (
        screen          => $screen,
        defaultreport   => $defaultreport,
        defaultdocument => $defaultdocument,
        lists_ds        => $lists_ds,
        list_header     => $list_header,
        bindings        => $bindings,
        tablebindings   => $tablebindings,
        maintable       => $maintable,
        deptable        => $deptable,
        scrtoolbar      => $scrtoolbar,
        toolbar         => $toolbar,
    );

    return \%data;
}

=head2 backup_config

Copy the old config file with and I<.orig> suffix.

=cut

sub backup_config {
    my ($self, $scrcfg_ap, $scrcfg_fn ) = @_;

    my $file_old = catfile($scrcfg_ap, $scrcfg_fn);
    my $file_bak = catfile($scrcfg_ap, "$scrcfg_fn.orig");

    if ( copy($file_old, $file_bak) ) {
        return 1;
    }
    else {
        die "Backup for: $file_bak failed!\n";
    }

    return;
}

=head1 CONFIG SECTIONS

=head2 make_screen

screen.

=cut

sub make_screen {
    my ($data) = @_;

    return unless keys %{$data};

    my $conf = Config::General->new(
        -AllowMultiOptions => 1,
        -SplitPolicy       => 'equalsign',
        -Tie               => "Tie::IxHash",
    );

    my $rec = {};
    tie %{$rec}, 'Tie::IxHash::Easy';

    $rec->{screen}{version}     = 4;
    $rec->{screen}{name}        = $data->{name};
    $rec->{screen}{description} = $data->{description};
    $rec->{screen}{style}       = $data->{style};
    $rec->{screen}{geometry}    = $data->{geometry};

    if ( exists $data->{details}{detail} ) {
        $rec->{screen}{details}{match}  = $data->{details}{match};
        $rec->{screen}{details}{filter} = $data->{details}{filter};
        my $idx = 0;
        my @detdata = @{ $data->{details}{detail} };
        foreach my $details (@detdata) {
            $rec->{screen}{details}{detail}[$idx]{name}  = $details->{name};
            $rec->{screen}{details}{detail}[$idx]{value} = $details->{value};
            $idx++;
        }
    }

    return $conf->save_string($rec);
}

=head2 make_defaultreport

defaultreport.

=cut

sub make_defaultreport {
    my ($data) = @_;

    return unless keys %{$data};

    my $conf = Config::General->new(
        -AllowMultiOptions => 1,
        -SplitPolicy       => 'equalsign',
        -Tie               => "Tie::IxHash",
    );

    my $rec = {};
    tie %{$rec}, 'Tie::IxHash::Easy';

    $rec->{defaultreport}{name} = $data->{name};
    $rec->{defaultreport}{file} = $data->{file};

    return $conf->save_string($rec);
}

=head2 make_defaultdocument

defaultdocument

=cut

sub make_defaultdocument {
    my ($data) = @_;

    return unless keys %{$data};

    my $conf = Config::General->new(
        -AllowMultiOptions => 1,
        -SplitPolicy       => 'equalsign',
        -Tie               => "Tie::IxHash",
    );

    my $rec = {};
    tie %{$rec}, 'Tie::IxHash::Easy';

    $rec->{defaultdocument}{name} = $data->{name};
    $rec->{defaultdocument}{file} = $data->{file};

    return $conf->save_string($rec);
}

=head2 make_lists_ds

lists_ds.

=cut

sub make_lists_ds {
    my ($data) = @_;

    return unless keys %{$data};

    my $conf = Config::General->new(
        -AllowMultiOptions => 1,
        -SplitPolicy       => 'equalsign',
        -Tie               => "Tie::IxHash",
    );

    my $rec = {};
    tie %{$rec}, 'Tie::IxHash::Easy';

    foreach my $field ( keys %{$data} ) {
        foreach my $key ( keys %{ $data->{$field} } ) {
            $rec->{lists_ds}{$field}{$key} = $data->{$field}{$key};
        }
    }

    return $conf->save_string($rec);
}

=head2 make_list_header

list_header.

=cut

sub make_list_header {
    my ($data) = @_;

    return unless keys %{$data};

    my $conf = Config::General->new(
        -AllowMultiOptions => 1,
        -SplitPolicy       => 'equalsign',
        -Tie               => "Tie::IxHash",
    );

    my $rec = {};
    tie %{$rec}, 'Tie::IxHash::Easy';

    foreach my $field ( keys %{$data} ) {
        if ( ref $data->{$field} eq 'ARRAY' ) {
            my @fields = @{ $data->{$field} };
            if ( scalar @fields == 1 ) {
                my $field_value = join ' ', @{ $data->{$field} };
                $rec->{list_header}{$field} = "[ $field_value ]";
            }
            else {
                push @{$rec->{list_header}{$field}}, $_ foreach @fields;
            }
        }
        else {
            $rec->{list_header}{$field} = $data->{$field};
        }
    }

    return $conf->save_string($rec);
}

=head2 make_bindings

bindings.

=cut

sub make_bindings {
    my $data = shift;

    return unless keys %{$data};

    my $conf = Config::General->new(
        -AllowMultiOptions => 1,
        -SplitPolicy       => 'equalsign',
        -Tie               => "Tie::IxHash",
    );

    my $rec = {};
    tie %{$rec}, 'Tie::IxHash::Easy';

    foreach my $field ( keys %{$data} ) {

        # table
        $rec->{bindings}{$field}{table} = $data->{$field}{table};

        # search
        if ( ref $data->{$field}{search} ) {
            foreach my $search ( keys %{ $data->{$field}{search} } ) {
                if (ref $data->{$field}{search}{$search} ) {
                    # v3
                    $rec->{bindings}{$field}{search}{$search}
                        = $data->{$field}{search}{$search}{name};
                }
                else {
                    # v4
                    $rec->{bindings}{$field}{search}{$search}
                        = $data->{$field}{search}{$search};
                }
            }
        }
        else {
            $rec->{bindings}{$field}{search} = $data->{$field}{search};
        }

        # field - lokup
        if ( ref $data->{$field}{field} eq 'HASH' ) {
            foreach my $key ( keys %{ $data->{$field}{field} } ) {
                if ( ref $data->{$field}{field}{$key} ) {
                    # v3
                    $rec->{bindings}{$field}{field}{$key}
                        = $data->{$field}{field}{$key}{name};
                }
                else {
                    # v4
                    $rec->{bindings}{$field}{field}{$key}
                        = $data->{$field}{field}{$key};
                }
            }
        }
        elsif ( ref $data->{$field}{field} eq 'ARRAY' ) {
            my $field_value = join ' ',@{ $data->{$field}{field} };
            $rec->{bindings}{$field}{field} = "[ $field_value ]";
        }
        else {
            $rec->{bindings}{$field}{field} = $data->{$field}{field};
        }
    }

    return $conf->save_string($rec);
}


=head2 make_tablebindings

Table bindings (Tk::TM).

=cut

sub make_tablebindings {
    my $data = shift;

    return unless keys %{$data};

    my $conf = Config::General->new(
        -AllowMultiOptions => 1,
        -SplitPolicy       => 'equalsign',
        -Tie               => "Tie::IxHash",
    );

    my $rec = {};
    tie %{$rec}, 'Tie::IxHash::Easy';

    foreach my $tm_ds ( keys %{$data} ) {
        foreach my $section ( keys %{ $data->{$tm_ds} } ) {
            foreach my $field ( keys %{ $data->{$tm_ds}{$section} } ) {
                foreach
                    my $key ( keys %{ $data->{$tm_ds}{$section}{$field} } )
                {
                    $rec->{tablebindings}{$tm_ds}{$section}{$field}{$key}
                        = $data->{$tm_ds}{$section}{$field}{$key};
                    if (ref $data->{$tm_ds}{$section}{$field}{$key} eq
                        'ARRAY' )
                    {
                        my @fields
                            = @{ $data->{$tm_ds}{$section}{$field}{$key} };
                        if ( scalar @fields == 1 ) {
                            my $field_value = join ' ',
                                @{ $data->{$tm_ds}{$section}{$field}{$key} };
                            $rec->{tablebindings}{$tm_ds}{$section}{$field}
                                {$key} = "[ $field_value ]";
                        }
                        else {
                            push @{ $rec->{tablebindings}{$tm_ds}{$section}
                                    {$field}{$key} }, $_
                                foreach @fields;
                        }
                    }
                    else {
                        $rec->{tablebindings}{$tm_ds}{$section}{$field}{$key}
                            = $data->{$tm_ds}{$section}{$field}{$key};
                    }
                }
            }
        }
    }

    return $conf->save_string($rec);
}

=head2 make_maintable

maintable.

=cut

sub make_maintable {
    my ($data) = @_;

    return unless keys %{$data};

    my $conf = Config::General->new(
        -AllowMultiOptions => 1,
        -SplitPolicy       => 'equalsign',
        -Tie               => "Tie::IxHash",
    );

    my $rec = {};
    tie %{$rec}, 'Tie::IxHash::Easy';

    $rec->{maintable}{name} = $data->{name};
    $rec->{maintable}{view} = $data->{view};

    # PK and FK
    if ( exists $data->{pkcol}{name} ) {
        $rec->{maintable}{pkcol}{name} = $data->{pkcol}{name};
    }
    if ( exists $data->{fkcol}{name} ) {
        $rec->{maintable}{fkcol}{name} = $data->{fkcol}{name};
    }

    foreach my $field ( keys %{ $data->{columns} } ) {
        $rec->{maintable}{columns}{$field}{label}
            = $data->{columns}{$field}{label};

        $rec->{maintable}{columns}{$field}{state}
            = $data->{columns}{$field}{state};

        $rec->{maintable}{columns}{$field}{ctrltype}
            = $data->{columns}{$field}{ctrltype};

        if (exists $data->{columns}{$field}{width} ) {
            # It's pre v3, migrate to v3
            $rec->{maintable}{columns}{$field}{displ_width}
                = $data->{columns}{$field}{width};
            $rec->{maintable}{columns}{$field}{valid_width}
                = $data->{columns}{$field}{width};
        }
        else {
            $rec->{maintable}{columns}{$field}{displ_width}
                = $data->{columns}{$field}{displ_width};
            $rec->{maintable}{columns}{$field}{valid_width}
                = $data->{columns}{$field}{valid_width};
        }

        if (exists $data->{columns}{$field}{places} ) {
            $rec->{maintable}{columns}{$field}{numscale}
                = $data->{columns}{$field}{places};
        }
        else {
            $rec->{maintable}{columns}{$field}{numscale}
                = $data->{columns}{$field}{numscale};
        }

        if ( exists $data->{columns}{$field}{rw} ) {
            $rec->{maintable}{columns}{$field}{readwrite}
                = $data->{columns}{$field}{rw};
        }
        else {
            $rec->{maintable}{columns}{$field}{readwrite}
                = $data->{columns}{$field}{readwrite};
        }

        $rec->{maintable}{columns}{$field}{findtype}
            = $data->{columns}{$field}{findtype};

        $rec->{maintable}{columns}{$field}{bgcolor}
            = $data->{columns}{$field}{bgcolor};

        if ( exists $data->{columns}{$field}{validation} ) {
            $rec->{maintable}{columns}{$field}{datatype}
                = $data->{columns}{$field}{validation};
        }
        elsif ( exists $data->{columns}{$field}{coltype}) {
            $rec->{maintable}{columns}{$field}{datatype}
                = $data->{columns}{$field}{coltype};
        }
        else {
            $rec->{maintable}{columns}{$field}{datatype}
                = $data->{columns}{$field}{datatype};
        }
    }

    return $conf->save_string($rec);
}

=head2 make_deptable

deptable

=cut

sub make_deptable {
    my ($data) = @_;

    return unless keys %{$data};

    my $conf = Config::General->new(
        -AllowMultiOptions => 1,
        -SplitPolicy       => 'equalsign',
        -Tie               => "Tie::IxHash",
    );

    my $rec = {};
    tie %{$rec}, 'Tie::IxHash::Easy';

    foreach my $tm_ds ( keys %{$data} ) {
        $rec->{deptable}{$tm_ds}{name}        = $data->{$tm_ds}{name};
        $rec->{deptable}{$tm_ds}{view}        = $data->{$tm_ds}{view};
        $rec->{deptable}{$tm_ds}{updatestyle} = $data->{$tm_ds}{updatestyle};
        $rec->{deptable}{$tm_ds}{selectorcol} = $data->{$tm_ds}{selectorcol};
        $rec->{deptable}{$tm_ds}{colstretch}  = $data->{$tm_ds}{colstretch};
        $rec->{deptable}{$tm_ds}{orderby}     = $data->{$tm_ds}{orderby};

        # PK and FK
        if ( exists $data->{$tm_ds}{pkcol}{name} ) {
            $rec->{deptable}{$tm_ds}{pkcol}{name} = $data->{$tm_ds}{pkcol}{name};
        }
        if ( exists $data->{$tm_ds}{fkcol}{name} ) {
            $rec->{deptable}{$tm_ds}{fkcol}{name} = $data->{$tm_ds}{fkcol}{name};
        }

        foreach my $field ( keys %{ $data->{$tm_ds}{columns} } ) {
            $rec->{deptable}{$tm_ds}{columns}{$field}{id}
                = $data->{$tm_ds}{columns}{$field}{id};

            $rec->{deptable}{$tm_ds}{columns}{$field}{label}
                = $data->{$tm_ds}{columns}{$field}{label};

            $rec->{deptable}{$tm_ds}{columns}{$field}{tag}
                = $data->{$tm_ds}{columns}{$field}{tag};

            if ( exists $data->{$tm_ds}{columns}{$field}{width} ) {
                $rec->{deptable}{$tm_ds}{columns}{$field}{displ_width}
                    = $data->{$tm_ds}{columns}{$field}{width};
                $rec->{deptable}{$tm_ds}{columns}{$field}{valid_width}
                    = $data->{$tm_ds}{columns}{$field}{width};
            }
            else {
                $rec->{deptable}{$tm_ds}{columns}{$field}{displ_width}
                    = $data->{$tm_ds}{columns}{$field}{displ_width};
                $rec->{deptable}{$tm_ds}{columns}{$field}{valid_width}
                    = $data->{$tm_ds}{columns}{$field}{valid_width};
            }

            if ( exists $data->{$tm_ds}{columns}{$field}{places} ) {
                $rec->{deptable}{$tm_ds}{columns}{$field}{numscale}
                    = $data->{$tm_ds}{columns}{$field}{places};
            }
            else {
                $rec->{deptable}{$tm_ds}{columns}{$field}{numscale}
                    = $data->{$tm_ds}{columns}{$field}{numscale};
            }

            if ( exists $data->{$tm_ds}{columns}{$field}{rw} ) {
                $rec->{deptable}{$tm_ds}{columns}{$field}{readwrite}
                    = $data->{$tm_ds}{columns}{$field}{rw};
            }
            else {
                $rec->{deptable}{$tm_ds}{columns}{$field}{readwrite}
                    = $data->{$tm_ds}{columns}{$field}{readwrite};
            }

            if ( exists $data->{$tm_ds}{columns}{$field}{validation} ) {
                $rec->{deptable}{$tm_ds}{columns}{$field}{datatype}
                    = $data->{$tm_ds}{columns}{$field}{validation};
            }
            elsif ( exists $data->{$tm_ds}{columns}{$field}{coltype} ) {
                $rec->{deptable}{$tm_ds}{columns}{$field}{datatype}
                    = $data->{$tm_ds}{columns}{$field}{coltype};
            }
            else {
                $rec->{deptable}{$tm_ds}{columns}{$field}{datatype}
                    = $data->{$tm_ds}{columns}{$field}{datatype};
            }
        }
    }

    return $conf->save_string($rec);
}

=head2 make_scrtoolbar

scrtoolbar.

=cut

sub make_scrtoolbar {
    my $data = shift;

    return unless keys %{$data};

    my $conf = Config::General->new(
        -AllowMultiOptions => 1,
        -SplitPolicy       => 'equalsign',
        -Tie               => "Tie::IxHash",
    );

    my $rec = {};
    tie %{$rec}, 'Tie::IxHash::Easy';

    my @rec;
    foreach my $tm_ds ( keys %{$data} ) {
        foreach my $tm_rec ( @{ $data->{$tm_ds} } ) {
            push @rec, $tm_rec;
        }
        $rec->{scrtoolbar}{$tm_ds} = [@rec];
    }

    return $conf->save_string($rec);
}

=head2 make_toolbar

toolbar.

=cut

sub make_toolbar {
    my $data = shift;

    return unless keys %{$data};

    my $conf = Config::General->new(
        -AllowMultiOptions => 1,
        -SplitPolicy       => 'equalsign',
        -Tie               => "Tie::IxHash",
    );

    my $rec = {};
    tie %{$rec}, 'Tie::IxHash::Easy';

    foreach my $tb ( keys %{$data} ) {
        foreach my $page ( keys %{ $data->{$tb}{state} } ) {
            foreach my $key ( keys %{ $data->{$tb}{state}{$page} } ) {
                $rec->{toolbar}{$tb}{state}{$page}{$key}
                    = $data->{$tb}{state}{$page}{$key};
            }
        }
    }

    return $conf->save_string($rec);
}

=head1 AUTHOR

Stefan Suciu, C<< <stefan@s2i2.ro> >>

=head1 BUGS

Please report any bugs or feature requests to the autor.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tpda3::Devel::Edit::Config

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

1; # End of Tpda3::Devel::Edit::Config
