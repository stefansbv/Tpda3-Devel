#!perl

use Test::More; # tests => 8;

plan skip_all => "CWD has to be a Tpda3 app source.";

use_ok('Tpda3::Devel');
use_ok('Tpda3::Devel::Info::App');

ok(my $app_info = Tpda3::Devel::Info::App->new(), 'Info::App object');
ok($app_info->check_app_path(), 'check app path');
ok($app_info->check_cfg_path(), 'check cfg path');
is($app_info->get_app_name(), 'NewApp', 'get app name');
is($app_info->get_cfg_name(), 'newapp', 'get cfg name');
ok(-d $app_info->get_screen_path(), 'check screen path');

# done
