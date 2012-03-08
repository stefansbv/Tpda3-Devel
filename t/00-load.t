#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Tpda3::Devel::Screen' ) || print "Bail out!\n";
}

diag( "Testing Tpda3::Devel::Screen $Tpda3::Devel::Screen::VERSION, Perl $], $^X" );
