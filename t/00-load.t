#!perl -T

use 5.010001;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Tpda3::Devel' ) || print "Bail out!\n";
}

diag( "Testing Tpda3::Devel $Tpda3::Devel::VERSION, Perl $], $^X" );
