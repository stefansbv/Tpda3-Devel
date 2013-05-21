#!perl

#use Data::Dumper;
use Test::More tests => 5;

use_ok('Tpda3::Devel');
use_ok('Tpda3::Devel::Info::Config');

my $args = {
    cfname => 'test-tk',
    user   => undef,
    pass   => undef,
};

my $ic  = Tpda3::Devel::Info::Config->new($args);
my $info = $ic->config_info();
#diag Dumper( $info );

like($info->{apps_dir}, qr{\.?[Tt]pda3[\\/]apps$}, 'check apps_dir');
is($info->{name}, 'test-tk', 'check config name');
is($info->{module}, 'Test', 'check app module name');

# done
