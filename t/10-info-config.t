#!perl

#use Data::Dumper;
use Test::More tests => 5;

BEGIN {
    use_ok( 'Tpda3::Devel' ) || print "Bail out!\n";
}

use_ok('Tpda3::Devel::Info::Config');

my $args = {
    cfname => 'test-tk',
    user   => undef,
    pass   => undef,
};

my $ic  = Tpda3::Devel::Info::Config->new($args);
my $info = $ic->config_info();
#diag Dumper( $info );

like($info->{apps_dir}, qr/\.tpda3\/apps$/, 'check apps_dir');
is($info->{name}, 'test-tk', 'check config name');
is($info->{module}, 'Test', 'check app module name');

# done
