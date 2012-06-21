#
# Makefile.PL for Tpda3-AppName
#
# Copyright (C) 2010-2011  Stefan Suciu
# GNU General Public License v3
#

use strict;
use warnings;

use inc::Module::Install;

name     'Tpda3-AppName';
version  '0.01';
license  'gpl';
abstract ' ... - Application for the Tpda3 framework';
author   'A.U. Thor, <author@domain.net>';

requires 'perl' => '5.008009';

#- Tk
requires 'Tk'                   => '804.030';
requires 'Tk::ToolBar'          => '0.09';
requires 'Tk::StatusBar'        => '0.04';
requires 'Tk::MListbox'         => '1.11';
requires 'Tk::JComboBox'        => '0';
requires 'Tk::DateEntry'        => '0';
requires 'Tk::TableMatrix'      => '1.23';
requires 'Tk::RadiobuttonGroup' => '0';

#- Database
recommends 'DBD::Pg'       => '1.32';
recommends 'DBD::Firebird' => '0.91';

install_share  'share';

WriteAll;
