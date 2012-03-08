use strict;
use warnings;

use inc::Module::Install;

name     'Tpda3-Devel';
all_from 'lib/Tpda3/Devel.pm';
author   q{Stefan Suciu <stefan@s2i2.ro>};
license  'gpl';

requires 'Tpda3' => '0.46';

build_requires 'Test::More';

auto_install;

WriteAll;
