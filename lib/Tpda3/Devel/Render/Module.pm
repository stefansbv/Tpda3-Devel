package Tpda3::Devel::Render::Module;

# ABSTRACT: Create a screen module file

use 5.010001;
use strict;
use warnings;
use utf8;

require Tpda3::Devel::Config;
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

=head2 generate_module

Generate the main application module from template.

=cut

sub generate_module {
    my ($self, $args) = @_;

    my $module = $args->{module};

    die "Need a module name!" unless $module;

    my $tdc = Tpda3::Devel::Config->new;
    my ($user_name, $user_email) = $tdc->get_gitconfig;

    my $data = {
        module      => $module,
        copy_author => $user_name,
        copy_email  => $user_email,
        copy_year   => (localtime)[5] + 1900,
    };

    my $app_info = Tpda3::Devel::Info::App->new($module);
    my $output_path = $app_info->get_app_module_rp();

    my $opts = {
        type        => 'module',
        output_file => "$module.pm",
        data        => $data,
        output_path => $output_path,
        templ_path  => undef,
    };

    Tpda3::Devel::Render->render($opts);

    return $output_path;
}

1;
