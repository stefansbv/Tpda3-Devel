#!perl

use Test::More; # tests => 7;

plan skip_all => "CWD has to be a Tpda3 app module.";

use_ok('Tpda3::Devel');
use_ok('Tpda3::Devel::Info::App');

ok(Tpda3::Devel::Info::App->check_app_path(), 'check app path');
ok(Tpda3::Devel::Info::App->check_cfg_path(), 'check cfg path');
is(Tpda3::Devel::Info::App->get_app_name(), 'NewApp', 'get app name');
is(Tpda3::Devel::Info::App->get_cfg_name(), 'newapp', 'get cfg name');
ok(-d Tpda3::Devel::Info::App::get_screen_path(), 'check screen path');

# done
