#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Tpda3::Devel' ) || print "Bail out!\n";
}

diag( "Testing Tpda3::Devel $Tpda3::Devel::VERSION, Perl $], $^X" );
