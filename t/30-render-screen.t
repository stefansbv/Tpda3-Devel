#!perl

use Test::More tests => 7;
use Test::Exception;

BEGIN {
    use_ok( 'Tpda3::Devel' ) || print "Bail out!\n";
}

# Check functions

use_ok('Tpda3::Devel::Render');

is( Tpda3::Devel::Render::get_template_for('screen'),
    'screen.tt', 'template for screen' );

dies_ok { Tpda3::Devel::Render->get_template_for('fail-test') };

ok( -d Tpda3::Devel::Render::get_output_path_for('screen'),
    'output path for screen' );

dies_ok { Tpda3::Devel::Render->get_output_path_for('fail-test') };

# Render

my %cfg =  ();

my %data = (
    copy_author => 'Ștefan Suciu',
    copy_email  => 'stefan at s2i2 .ro',
    copy_year   => '2012',
    module      => 'ScrTest',
    screen      => 'scrtest',
    columns     => $cfg{maintable}{columns},
);

ok( Tpda3::Devel::Render->render( 'screen', 'ScrTest.pm', \%data ),
    'render screen module file' );

# done
