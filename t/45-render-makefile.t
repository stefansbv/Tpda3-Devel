#!perl

use utf8;
use Test::More tests => 5;
use Test::Exception;
use File::Spec::Functions;

use_ok('Tpda3::Devel');

# Check functions

use_ok('Tpda3::Devel::Render');

is( Tpda3::Devel::Render->get_template_for('makefile'),
    'makefile.tt', 'template for makefile' );

dies_ok { Tpda3::Devel::Render->get_template_for('fail-test') };

# Render

my $data = {
    module      => 'TestModule',
    copy_author => 'Ștefan Suciu',
    copy_email  => "stefan 'la' s2i2 .ro",
    copy_year   => '2012',
};

my $args = {
    type        => 'makefile',
    output_file => 'Makefile.PL',
    data        => $data,
    output_path => catdir('t', 'output'),
    templ_path  => catdir( 'share', 'templates' ),
};

ok( Tpda3::Devel::Render->render($args), 'render makefile file' );

# done
