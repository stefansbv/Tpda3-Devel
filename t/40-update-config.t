#!perl

use Test::More tests => 5;
use Test::Exception;

use_ok('Tpda3::Devel');

# Check functions

use_ok('Tpda3::Devel::Render');

is( Tpda3::Devel::Render->get_template_for('config-update'),
    'config-refactor.tt', 'template for config' );

dies_ok { Tpda3::Devel::Render->get_template_for('fail-test') };

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

my $out = 't/output';
ok( Tpda3::Devel::Render->render( 'config', 'scrtest.conf', \%data, $out ),
    'render config file' );

# done
