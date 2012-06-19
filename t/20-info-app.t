#!perl

# use Data::Dumper;
use Test::More tests => 7;

BEGIN {
    use_ok( 'Tpda3::Devel' ) || print "Bail out!\n";
}

use_ok('Tpda3::Devel::Info::App');

ok(Tpda3::Devel::Info::App->check_app_path(), 'check app path');
ok(Tpda3::Devel::Info::App->check_cfg_path(), 'check cfg path');
is(Tpda3::Devel::Info::App->get_app_name(), 'NewApp', 'get app name');
is(Tpda3::Devel::Info::App->get_cfg_name(), 'newapp', 'get cfg name');
ok(-d Tpda3::Devel::Info::App->get_screen_path(), 'check screen path');

# my $args = {
#     cfname => 'test-tk',
#     user   => undef,
#     pass   => undef,
# };

# my $ic  = Tpda3::Devel::Info::Config->new($args);
# my $icd = $ic->config_info();
# diag Dumper( $icd );

# like($icd->{apps_dir}, qr/\.tpda3\/apps$/, 'check apps_dir');
# is($icd->{name}, 'test-tk', 'check config name');
# is($icd->{module}, 'Test', 'check app module name');

# done
