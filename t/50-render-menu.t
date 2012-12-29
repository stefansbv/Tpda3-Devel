#!perl

use utf8;
use Test::More tests => 6;
use Test::Exception;

use_ok('Tpda3::Devel');

# Check functions

use_ok('Tpda3::Devel::Render');
use_ok('Tpda3::Devel::Render::YAML');

ok( my $tdry = Tpda3::Devel::Render::YAML->new({}) );

is( Tpda3::Devel::Render->get_template_for('cfg-menu'),
    'config/menu.tt', 'template for menu' );

# Render

my %data = ( r => { module => 'TestModule' } );

my $out = 't/output';
ok( Tpda3::Devel::Render->render( 'cfg-menu', 'menu.yml', \%data, $out ),
    'render menu file' );

# done
