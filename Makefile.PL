#
# Makefile.PL for Tpda3::Devel
#
# Copyright (C) 2011-2013  Stefan Suciu
# GNU General Public License v3
#

use 5.008009;
use strict;
use warnings;
use File::Copy::Recursive;
use inc::Module::Install;

name     'Tpda3-Devel';
all_from 'lib/Tpda3/Devel.pm';
author   q{Stefan Suciu <stefan@s2i2.ro>};
license  'gpl';

requires 'File::ShareDir'        => '0';
requires 'File::Spec::Functions' => '0';
requires 'Template'              => '0';
requires 'Config::General'       => '0';
requires 'Tie::IxHash::Easy'     => '0.01';
requires 'List::Compare'         => '0';
requires 'File::Basename'        => '0';

requires 'Tpda3' => '0.46';

build_requires 'Test::More';
build_requires 'File::Copy::Recursive';

install_share 'share';
install_script 'bin/tpda3d';

WriteAll;

print "Copy inc/ to share/ ...\r";
File::Copy::Recursive::dircopy( './inc', './share/dirtree/inc' )
    or die "Failed to copy module tree to 'share'";
print "Copy inc/ to share/ ... done\n";
