package Tpda3::Devel::Config::Update;

use 5.008009;
use strict;
use warnings;

use Cwd;
use File::Basename;
use File::Spec::Functions;
use Config::General qw{ParseConfig};
use File::Copy;

require Tpda3::Config;
require Tpda3::Devel::Config::Info;

=head1 NAME

Tpda3::Devel::Config::Update - Tpda3 application config update.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use Tpda3::Devel::Config::Update;

    my $dci = Tpda3::Devel::Config::Update->new();
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
    $self->{cfg} = Tpda3::Config->instance;

    return $self;
}

sub config_update {
    my $self = shift;

    my $scr_cfg_name = $self->{opt}{config} . '.conf';
    my $scr_cfg_path = $self->screen_cfg_path();
    my $scr_cfg_file = $self->screen_cfg_file($scr_cfg_path);

    tie my %cfg, "Tie::IxHash";    # keep the order

    %cfg = ParseConfig(
        -ConfigFile => $scr_cfg_file,
        -Tie        => 'Tie::IxHash',
    );

    my $screen          = make_screen( $cfg{screen} );
    my $defaultreport   = make_defaultreport( $cfg{defaultreport} );
    my $defaultdocument = make_defaultdocument( $cfg{defaultdocument} );
    my $lists_ds        = make_lists_ds( $cfg{lists_ds} );
    my $list_header     = make_list_header( $cfg{list_header} );
    my $bindings        = make_bindings( $cfg{bindings} );
    my $maintable       = make_maintable( $cfg{maintable} );
    my $deptable        = make_deptable( $cfg{deptable} );

    my %parsed = (
        screen          => $screen,
        defaultreport   => $defaultreport,
        defaultdocument => $defaultdocument,
        lists_ds        => $lists_ds,
        list_header     => $list_header,
        bindings        => $bindings,
        tablebindings   => $cfg{tablebindings},
        maintable       => $maintable,
        deptable        => $deptable,
        toolbar         => $cfg{toolbar},
    );

    $self->apply_template( \%parsed, $scr_cfg_path, $scr_cfg_name );

    return;
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
        print "\n Can't read the config from\n '$scr_cfg_path'\n";
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

    my $scr_cfg_file = $self->{opt}{config} . '.conf';

    return catfile($scr_cfg_path, $scr_cfg_file);
}

sub backup_config {
    my ($self, $scr_cfg_path, $scr_cfg_name ) = @_;

    my $file_old = catfile($scr_cfg_path, $scr_cfg_name);
    my $file_bak = catfile($scr_cfg_path, "$scr_cfg_name.orig");

    if ( copy($file_old, $file_bak) ) {
        return 1;
    }
    else {
        die "Backup for: $file_bak failed!\n";
    }

    return;
}

sub apply_template {
    my ($self, $data, $scr_cfg_path, $scr_cfg_name) = @_;

    # Backup existing config file
    my $backup_ok = $self->backup_config( $scr_cfg_path, $scr_cfg_name );
    unless ($backup_ok) {
        die "Backup of old config file failed!";
    }

    print "\n Output goes to\n '$scr_cfg_path\n";
    print " File is '$scr_cfg_name'\n";

    my $tt = Template->new(
        INCLUDE_PATH => $self->{opt}{templ_path},
        OUTPUT_PATH  => $scr_cfg_path,
    );

    $tt->process( 'config-refactor.tt', $data, $scr_cfg_name,
        binmode => ':utf8' )
        or die $tt->error(), "\n";

    my $scr_cfg_file = $self->screen_cfg_file($scr_cfg_path);
    if ( -f $scr_cfg_file ) {
        print " done.\n";
    }
    else {
        print " Failed to create: $scr_cfg_name!\n";
    }

    return;
}

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

    $rec->{screen}{version}     = 3;
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

    my $idx = 0;
    foreach my $field ( keys %{ $data } ) {
        $rec->{lists_ds}[$idx]{$field}{table}   = $data->{$field}{table};
        $rec->{lists_ds}[$idx]{$field}{code}    = $data->{$field}{code};
        $rec->{lists_ds}[$idx]{$field}{name}    = $data->{$field}{name};
        $rec->{lists_ds}[$idx]{$field}{default} = $data->{$field}{default};
        $rec->{lists_ds}[$idx]{$field}{orderby} = $data->{$field}{orderby};
        $idx++;
    }

    return $conf->save_string($rec);
}

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

    foreach my $field ( keys %{ $data } ) {
        $rec->{list_header}{$field} = $data->{$field};
    }

    return $conf->save_string($rec);
}

sub make_bindings {
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
        my $record = $data->{$field};
        $rec->{bindings}{$field}{table}  = $data->{$field}{table};
        $rec->{bindings}{$field}{search} = $data->{$field}{search};
        if ( exists $data->{$field}{field}
            and ref( $data->{$field}{field} ) eq 'ARRAY' )
        {
            my $idx = 0;
            my @fld = @{ $data->{$field}{field} };
            foreach my $det (@fld) {
                $rec->{bindings}{$field}{field}[$idx] = $det;
                $idx++;
            }
        }
        else {
            $rec->{bindings}{$field}{field} = $data->{$field}{field};
        }
    }

    return $conf->save_string($rec);
}

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

=head1 AUTHOR

Stefan Suciu, C<< <stefan@s2i2.ro> >>

=head1 BUGS

Please report any bugs or feature requests to the autor.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Tpda3::Devel::Config::Update

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

1; # End of Tpda3::Devel::Config::Update
