#!perl

use Test::More tests => 7;
use Test::Exception;

BEGIN {
    use_ok( 'Tpda3::Devel' ) || print "Bail out!\n";
}

# Check functions

use_ok('Tpda3::Devel::Render');

is( Tpda3::Devel::Render::get_template_for('config'),
    'config.tt', 'template for config' );

dies_ok { Tpda3::Devel::Render->get_template_for('fail-test') };

ok( -d Tpda3::Devel::Render::get_output_path_for('config'),
    'output path for config' );

dies_ok { Tpda3::Devel::Render->get_output_path_for('fail-test') };

# Render

my %data = (
    maintable   => '',
    deptable    => '',
    screenname  => 'scrtest',
    screendescr => 'Screen Test',
    pkfields    => '',
    fkfields    => '',
    columns     => '',
);

ok( Tpda3::Devel::Render->render( 'config', 'scrtest.conf', \%data ),
    'render config file' );

# done
