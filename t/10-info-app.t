use 5.010001;
use strict;
use warnings;
use utf8;

use File::Spec::Functions;
use Cwd;
use Test::More tests => 28;

my $CLASS;
BEGIN {
    $CLASS = 'Tpda3::Devel::Info::App';
    use_ok $CLASS or die;
}

#-   Init

ok my $dip = Tpda3::Devel::Info::App->new(), 'New instance';
is $dip->get_app_path, undef, "Not a Tpda3 app dir";
is $dip->get_cfg_path, undef, "No Tpda3 apps cfg dir";
is $dip->is_app_dir, undef, "Not a Tpda3 application distribution dir";

#--  A test tree for an existing Tpda3 app dist

my $cwd = Cwd::cwd();
chdir catdir(qw{t test-tree old-app})
    or die "Can't cd to 't/test-tree/old-app': $!\n";

ok $dip->get_app_path, "In a Tpda3 app dir";
ok my $app_name = $dip->get_app_name, 'Get the app name';
is $app_name, 'Test', "The app name is Test";
ok $dip->get_cfg_path, "Has an Tpda3 apps cfg dir";
foreach my $dir (qw{etc rep scr tex}) {
    like $dip->get_user_path_for($dir), qr/$dir$/,
        "The user path for $dir";
}
like $dip->get_screen_module_ap, qr/$app_name$/, 'The screen modules path';
ok $dip->is_app_dir, "Is a Tpda3 application distribution dir";

#--  New app dist tree, not in the CWD, module name parameter: Test

#diag "CWD is: $cwd";
chdir catdir($cwd, 't', 'test-tree');

ok $dip = Tpda3::Devel::Info::App->new('Test'),
    'New instance with module name';
ok my $cfg_path = $dip->get_cfg_path, "In a Tpda3 app dist cfg dir";
like $dip->get_tests_path, qr/t$/, "Has a test dir";
is $dip->get_app_module_rp, 'Tpda3-Test/lib/Tpda3/Tk/App',
    'The app main module path';
is $dip->get_cfg_name, 'test', "The mnemonic is test";
foreach my $dir (qw{etc rep scr tex}) {
    like $dip->get_config_ap_for($dir), qr/$dir$/,
        "The config path for $dir";
}
foreach my $file (qw{application.yml connection.yml menu.yml toolbar.yml}) {
    like $dip->get_config_apfn_for( 'etc', $file ), qr/$file$/,
        "The config apfn '$file'";
}

#--  End
