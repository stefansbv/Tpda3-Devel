#!perl

use Test::More tests => 5;
use Test::Exception;

use_ok('Tpda3::Devel');

# Check functions

use_ok('Tpda3::Devel::Render');

is( Tpda3::Devel::Render->get_template_for('module'),
    'module.tt', 'template for module' );

dies_ok { Tpda3::Devel::Render->get_template_for('fail-test') };

# Render

my %data = (
    module      => 'TestModule',
    copy_author => 'Ștefan Suciu',
    copy_email  => "stefan 'la' s2i2 .ro",
    copy_year   => '2012',
);

# output to current dir
my $out = 't/output';
ok( Tpda3::Devel::Render->render( 'module', 'TestModule.pm', \%data, $out),
    'render screen module file' );

# done
