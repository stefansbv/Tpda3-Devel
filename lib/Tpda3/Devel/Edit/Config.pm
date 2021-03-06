package Tpda3::Devel::Edit::Config;

# ABSTRACT: Tpda3 application config update

use 5.010001;
use strict;
use warnings;
use utf8;

use Cwd;
use File::Basename;
use Path::Tiny;
use Tie::IxHash::Easy;
use Config::General qw{ParseConfig};
use File::Copy;

require Tpda3::Devel::Info::App;
require Tpda3::Devel::Info::Config;
require Tpda3::Devel::Render;


sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    $self->{ver} = undef;                    # screen config version

    return $self;
}


sub config_update {
    my ($self, $opts) = @_;

    my $app_info = Tpda3::Devel::Info::App->new();

    my $scrcfg_fn   = $opts->{scrcfg_fn};
    my $scrcfg_ap   = $opts->{scrcfg_ap};
    my $scrcfg_apfn = $opts->{scrcfg_apfn};

    my $data = $self->prepare_config_data($scrcfg_apfn);

    # Backup existing config file
    my $backup_ok = $self->backup_config( $scrcfg_ap, $scrcfg_fn );
    die "Backup of old config file failed!" unless $backup_ok;

    my $args = {
        type        => 'config-update',
        output_file => $scrcfg_fn,
        data        => { r => $data },
        output_path => $scrcfg_ap,
        templ_path  => undef,
    };

    Tpda3::Devel::Render->render($args);

    return;
}


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

    my $screen          = $self->make_screen( $cfg{screen} );
    my $defaultreport   = $self->make_defaultreport( $cfg{defaultreport} );
    my $defaultdocument = $self->make_defaultdocument( $cfg{defaultdocument} );
    my $lists_ds        = $self->make_lists_ds( $cfg{lists_ds} );
    my $list_header     = $self->make_list_header( $cfg{list_header} );
    my $bindings        = $self->make_bindings( $cfg{bindings} );
    my $tablebindings   = $self->make_tablebindings( $cfg{tablebindings} );
    my $maintable       = $self->make_maintable( $cfg{maintable} );
    my $deptable        = $self->make_deptable( $cfg{deptable} );
    my $scrtoolbar      = $self->make_scrtoolbar( $cfg{scrtoolbar} );
    my $toolbar         = $self->make_toolbar( $cfg{toolbar} );

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


sub backup_config {
    my ($self, $scrcfg_ap, $scrcfg_fn ) = @_;

    my $file_old = path($scrcfg_ap, $scrcfg_fn);
    my $file_bak = path($scrcfg_ap, "$scrcfg_fn.orig");

    if ( copy($file_old, $file_bak) ) {
        return 1;
    }
    else {
        die "Backup for: $file_bak failed!\n";
    }

    return;
}


sub make_screen {
    my ($self, $data) = @_;

    return unless keys %{$data};

    my $conf = Config::General->new(
        -AllowMultiOptions => 1,
        -SplitPolicy       => 'equalsign',
        -Tie               => "Tie::IxHash",
    );

    my $rec = {};
    tie %{$rec}, 'Tie::IxHash::Easy';

    $self->{ver} = $data->{version};         # store the version
    print "Confg version is ", $self->{ver}, "\n";

    $rec->{screen}{version}     = 5;         # from Tpda3 v0.70
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
    my ($self, $data) = @_;

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
    my ($self, $data) = @_;

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
    my ($self, $data) = @_;

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


sub make_list_header {
    my ($self, $data) = @_;

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


sub make_bindings {
    my ($self, $data) = @_;

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



sub make_tablebindings {
    my ($self, $data) = @_;

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


sub make_maintable {
    my ($self, $data) = @_;

    return unless keys %{$data};

    my $conf = Config::General->new(
        -AllowMultiOptions => 1,
        -SplitPolicy       => 'equalsign',
        -Tie               => "Tie::IxHash::Easy",
    );

    my $rec = {};
    tie %{$rec}, 'Tie::IxHash::Easy';

    $rec->{maintable}{name} = $data->{name};
    $rec->{maintable}{view} = $data->{view};

    # Keys
    if ( $self->{ver} <= 4 ) {
        my $count = 0;
        if ( exists $data->{pkcol}{name} ) {
            push @{ $rec->{maintable}{keys}{name} },
                $data->{pkcol}{name};
            $count++;
        }
        if ( exists $data->{fkcol}{name} ) {
            push @{ $rec->{maintable}{keys}{name} },
                $data->{fkcol}{name};
            $count++;
        }
        if ( $count == 1 ) {

            # Corection, add [, ]
            $rec->{maintable}{keys}{name} = '[ '. $data->{pkcol}{name} .' ]';
        }
    }
    elsif ( $self->{ver} >= 5 ) {

        # New
        # dd $data->{keys};
        my $keys = $data->{keys};
        # dd $keys;
        $rec->{maintable}{keys} = $data->{keys};
        # dd $rec->{maintable};

        # Bug: the keys content is deleted
        # See BUGS section in:
        # https://metacpan.org/pod/Tie::Autotie
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
    my ($self, $data) = @_;

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
        # TODO check if works for v < 4
        if ( $self->{ver} <= 4 ) {
            my $count = 0;
            if ( exists $data->{$tm_ds}{pkcol}{name} ) {
                push @{ $rec->{deptable}{$tm_ds}{keys}{name} },
                    $data->{$tm_ds}{pkcol}{name};
                $count++;
            }
            if ( exists $data->{$tm_ds}{fkcol}{name} ) {
                push @{ $rec->{deptable}{$tm_ds}{keys}{name} },
                    $data->{$tm_ds}{fkcol}{name};
                $count++;
            }
            if ( $count == 1 ) {
                # Corection, add [, ]
                $rec->{deptable}{$tm_ds}{keys}{name}
                    = '[ ' . $data->{$tm_ds}{pkcol}{name} . ' ]';
            }
        }
        elsif ( $self->{ver} >= 5 ) {
            # New
            $rec->{deptable}{$tm_ds}{keys} = $data->{$tm_ds}{keys};
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


sub make_scrtoolbar {
    my ($self, $data) = @_;

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


sub make_toolbar {
    my ($self, $data) = @_;

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

1;

__END__

=pod

=head2 new

Constructor.

=head2 config_update

Read the old config file section by section and use a template to
preserve | edit the comments and the order of the sections.

=head2 prepare_config_data

Prepare and return config data.

Force array is on, so we must take special care about [ field ]
constructs.

=head2 backup_config

Copy the old config file with and I<.orig> suffix.

=head1 CONFIG SECTIONS

=head2 make_screen

screen.

=head2 make_defaultreport

defaultreport.

=head2 make_defaultdocument

defaultdocument

=head2 make_lists_ds

lists_ds.

=head2 make_list_header

list_header.

=head2 make_bindings

bindings.

=head2 make_tablebindings

Table bindings (Tk::TM).

=head2 make_maintable

maintable.

=head2 make_deptable

deptable

=head2 make_scrtoolbar

scrtoolbar.

=head2 make_toolbar

toolbar.

=cut
