#!perl

use Test::More tests => 7;
use Test::Exception;

BEGIN {
    use_ok( 'Tpda3::Devel' ) || print "Bail out!\n";
}

# Check functions

use_ok('Tpda3::Devel::Render');

is( Tpda3::Devel::Render::get_template_for('newapp'),
    'newapp.tt', 'template for newapp' );

dies_ok { Tpda3::Devel::Render->get_template_for('fail-test') };

ok( -d Tpda3::Devel::Render::get_output_path_for('newapp'),
    'output path for newapp' );

dies_ok { Tpda3::Devel::Render->get_output_path_for('fail-test') };

# Render

my %data = (
    name        => 'NewApp',
    description => 'NewApp description',
    copy_author => 'Ștefan Suciu',
    copy_email  => "stefan 'la' s2i2 .ro",
    copy_year   => '2012',
);

ok( Tpda3::Devel::Render->render( 'newapp', 'NewApp.pm', \%data ),
    'render screen module file' );

# done
