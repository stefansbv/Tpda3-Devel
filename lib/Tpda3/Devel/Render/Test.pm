package Tpda3::Devel::Render::Test;

# ABSTRACT: Create a test file

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

=head2 generate_test

Generate test from template.

=cut

sub generate_test {
    my ($self, $args, $test_tmpl, $test_name) = @_;

    my $module = $args->{module};

    die "Need a app name!" unless $module;
    die "Need a test template!" unless $test_tmpl;
    die "Need a test name!" unless $test_name;

    $args->{appname} = "Tpda3::Tk::App::$module";

    my $data = {};
    $data->{module}   = $args->{module};
    $data->{mnemonic} = $args->{mnemonic};

    my $app_info = Tpda3::Devel::Info::App->new($module);
    my $output_path = $app_info->get_tests_path();

    my $opts = {
        type        => $test_tmpl,
        output_file => $test_name,
        data        => { r => $data },
        output_path => $output_path,
        templ_path  => undef,
    };

    Tpda3::Devel::Render->render($opts);

    return;
}

1;
