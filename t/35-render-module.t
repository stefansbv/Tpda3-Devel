#!perl

use Test::More tests => 5;
use Test::Exception;
use Path::Tiny;

use_ok('Tpda3::Devel');

# Check functions

use_ok('Tpda3::Devel::Render');

is( Tpda3::Devel::Render->get_template_for('module'),
    'module.tt', 'template for module' );

dies_ok { Tpda3::Devel::Render->get_template_for('fail-test') };

# Render

my $data = {
    module      => 'TestModule',
    copy_author => 'Ștefan Suciu',
    copy_email  => "stefan 'la' s2i2 .ro",
    copy_year   => '2012',
};

my $args = {
    type        => 'module',
    output_file => 'TestModule.pm',
    data        => $data,
    output_path => path('t', 'output'),
    templ_path  => path( 'share', 'templates' ),
};

ok( Tpda3::Devel::Render->render($args), 'render screen module file' );

# done
