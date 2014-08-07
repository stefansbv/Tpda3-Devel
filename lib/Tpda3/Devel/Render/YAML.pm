package Tpda3::Devel::Render::YAML;

# ABSTRACT: Create a YAML configuration file

use 5.010001;
use strict;
use warnings;
use utf8;

require Tpda3::Devel::Info::App;
require Tpda3::Devel::Render;

=head2 new

Constructor.

=cut

sub new {
    my $class = shift;

    my $self = {};

    bless $self, $class;

    return $self;
}

=head2 generate_config

Generate a YAML config from a template.

=cut

sub generate_config {
    my ($self, $args, $yml_tmpl, $yml_name) = @_;

    my $module = $args->{module};

    die "Module name required, in 'generate_config'!" unless $module;

    my $data = $args->{dsn};
    $data->{module} = $module;

    my $app_info = Tpda3::Devel::Info::App->new($module);
    my $output_path = $app_info->get_config_ap_for('etc');

    my $opts = {
        type        => $yml_tmpl,
        output_file => $yml_name,
        data        => { r => $data },
        output_path => $output_path,
        templ_path  => undef,
    };

    Tpda3::Devel::Render->render($opts);

    return;
}

1;
