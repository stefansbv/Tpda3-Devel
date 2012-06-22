#!perl

use Test::More tests => 5;
use Test::Exception;

use_ok('Tpda3::Devel');

# Check functions

use_ok('Tpda3::Devel::Render');

is( Tpda3::Devel::Render->get_template_for('screen'),
    'screen.tt', 'template for screen' );

dies_ok { Tpda3::Devel::Render->get_template_for('fail-test') };

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

my $out = 't/output';
ok( Tpda3::Devel::Render->render( 'screen', 'ScrTest.pm', \%data, $out ),
    'render screen module file' );

# done
