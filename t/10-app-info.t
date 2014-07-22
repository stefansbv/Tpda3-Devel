use 5.010001;
use strict;
use warnings;
use utf8;

use File::Spec::Functions;
use Cwd;
use Test::More tests => 12;

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

#--  A test tree for an Tpda3 app dist

my $cwd = Cwd::cwd();
chdir catdir(qw{t test-tree old-app})
    or die "Can't cd to 't/test-tree/old-app': $!\n";

ok $dip->get_app_path, "In a Tpda3 app dir";
ok $dip->get_cfg_path, "Has an Tpda3 apps cfg dir";
ok $dip->is_app_dir, "Is a Tpda3 application distribution dir";

#--  New app dist tree, not in the CWD, module name parameter: TastApp

#diag "CWD is: $cwd";
chdir catdir($cwd, 't', 'test-tree');

ok $dip = Tpda3::Devel::Info::App->new('TestApp'),
    'New instance with module name';
ok my $cfg_path = $dip->get_cfg_path, "In a Tpda3 app dist cfg dir";
#diag $cfg_path;
like $dip->get_tests_path, qr/t$/, "Has a test dir";
is $dip->get_cfg_name, 'testapp', "The mnemonic is testapp";

#--  End
