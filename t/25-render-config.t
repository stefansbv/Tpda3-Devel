#!perl

use Test::More tests => 5;
use Test::Exception;
use File::Spec::Functions;

use_ok('Tpda3::Devel');

# Check functions

use_ok('Tpda3::Devel::Render');

is( Tpda3::Devel::Render->get_template_for('config'),
    'config.tt', 'template for config' );

dies_ok { Tpda3::Devel::Render->get_template_for('fail-test') };

# Render

my $data = {
    maintable   => '',
    deptable    => '',
    modulename  => 'scrtest',
    moduledescr => 'Screen Test',
    key_fields  => qw(field0 field1),
    columns     => '',
};

my $args = {
    type        => 'config',
    output_file => 'scrtest.conf',
    data        => $data,
    output_path => catdir('t', 'output'),
    templ_path  => catdir( 'share', 'templates' ),
};

ok( Tpda3::Devel::Render->render($args), 'render config file' );

# done
