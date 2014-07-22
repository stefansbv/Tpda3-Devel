#!perl

use Test::More tests => 5;
use Test::Exception;
use File::Spec::Functions;

use_ok('Tpda3::Devel');

# Check functions

use_ok('Tpda3::Devel::Render');

is( Tpda3::Devel::Render->get_template_for('screen'),
    'screen.tt', 'template for screen' );

dies_ok { Tpda3::Devel::Render->get_template_for('fail-test') };

# Render

my %cfg =  ();
my $data = {
    copy_author => 'Ștefan Suciu',
    copy_email  => 'stefan at s2i2 .ro',
    copy_year   => '2012',
    module      => 'ScrTest',
    screen      => 'scrtest',
    columns     => $cfg{maintable}{columns},
};

my $args = {
    type        => 'screen',
    output_file => 'ScrTest.pm',
    data        => $data,
    output_path => catdir('t', 'output'),
    templ_path  => catdir( 'share', 'templates' ),
};

ok( Tpda3::Devel::Render->render($args), 'render screen module file' );

# done
