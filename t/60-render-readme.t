#!perl

use utf8;
use Test::More tests => 5;
use Test::Exception;

use_ok('Tpda3::Devel');

# Check functions

use_ok('Tpda3::Devel::Render');

is( Tpda3::Devel::Render->get_template_for('readme'),
    'readme.tt', 'template for readme' );

dies_ok { Tpda3::Devel::Render->get_template_for('fail-test') };

# Render

my %data = (
    module      => 'TestModule',
    copy_author => 'Ștefan Suciu',
    copy_email  => "stefan 'la' s2i2 .ro",
    copy_year   => '2013',
);

my $out = 't/output';
ok( Tpda3::Devel::Render->render( 'readme', 'README', \%data, $out ),
    'render readme file' );

# done
