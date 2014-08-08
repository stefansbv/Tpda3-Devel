package Tpda3::Devel::Command::Print;

# ABSTRACT: Print miscellaneous info

use strict;
use warnings;

use base qw( CLI::Framework::Command );

use Tpda3::Devel::Utils;
require Tpda3::Devel::Info::Table;

sub usage_text {
    q{
info -t [<table>] | -c | -m [<name>] | -a

    OPTIONS
        -t,--table    [<table>]   list the tables from the database
        -c,--configs              list the screen config files of the project
        -m,--mnemonic             list the application configurations
        -a,--app                  show info about the current application
}
}

sub option_spec {
    [ 'table|t:s' => 'List the tables or a table info' ],
    [ 'configs|c' => 'List the screen config files of the project' ],
    [ 'mnemonic|m:s' => 'List the application configurations' ],
    [ 'app|a' => 'Show info about the current project' ],
}

sub validate {
    my ($self, $cmd_opts, @args) = @_;
    die "Only one of the options is alowed.  Usage:\n"
        . $self->usage_text . "\n"
        . $self->app_context . "\n"
        if keys %{$cmd_opts} > 1;
    die "One of the options is mandatory.  Usage:\n"
        . $self->usage_text . "\n"
        . $self->app_context . "\n"
        if keys %{$cmd_opts} < 1;
}

sub run {
    my ($self, $opts, @args) = @_;

    my $context = $self->cache->get('context');
    if ($context eq 'new') {
        print "# NOTE: Info regarding the default configuration.\n";
    }

    $self->get_app_info                     if $opts->{app};
    $self->get_configs_info                 if $opts->{configs};
    $self->get_table_info( $opts->{table} ) if $opts->{table};
    $self->get_table_list                   if defined $opts->{table};
    $self->get_mnemonics_info( $opts->{mnemonic} )
        if defined $opts->{mnemonic};

    return;
}

sub get_mnemonics_info {
    my ($self, $mnemonic) = @_;

    my $ic = $self->cache->get('config');
    print "\n";
    $ic->list_mnemonics($mnemonic);
}

sub get_table_list {
    my $self = shift;
    my $output = "\nTables:\n - ";
    $output .= join "\n - ", @{ $self->_table_info };
    $output .= "\n";
    print $output;
}

sub get_table_info {
    my ($self, $table) = @_;

    die "Wrong parameter for 'get_table_info'" unless $table;

    my $it  = Tpda3::Devel::Info::Table->new();
    my $itd = $it->table_info($table);

    my $output = "\nTable [$table] columns info:\n - ";
    $output .= join "\n - ", @{ $itd->{fields} };
    $output .= "\n";
    print $output;
}

sub _table_info {
    my $self = shift;
    my $it = Tpda3::Devel::Info::Table->new;
    return $it->table_list;
}

sub get_configs_info {
    my $self = shift;
    my $ic = $self->cache->get('config');
    print "\n";                        # an empty line before the list
    print $ic->list_config_files;
}

sub get_app_info {
    my $self = shift;
    my $info = Tpda3::Devel::Info::App->new;
    my $app_name = $info->get_app_name || q{none};
    my $cfg_name = $info->get_cfg_name || q{none};
    print "Current application: $app_name ($cfg_name)\n";
}

1;
