#!perl

use utf8;
use Test::More tests => 6;
use Test::Exception;
use File::Spec::Functions;

use_ok('Tpda3::Devel');

# Check functions

use_ok('Tpda3::Devel::Render');
use_ok('Tpda3::Devel::Render::YAML');

ok( my $tdry = Tpda3::Devel::Render::YAML->new({}) );

is( Tpda3::Devel::Render->get_template_for('cfg-menu'),
    'config/menu.tt', 'template for menu' );

# Render

my $data = {
    r => { module => 'TestModule' },
};

my $args = {
    type        => 'cfg-menu',
    output_file => 'menu.yml',
    data        => $data,
    output_path => catdir('t', 'output'),
    templ_path  => catdir( 'share', 'templates' ),
};

ok( Tpda3::Devel::Render->render($args), 'render menu file' );

# done
