#
# Tpda3 use test script
#

use Test::More tests => 26;

diag( "Testing with Perl $], $^X" );

#-- Tpda3 framework

use_ok('Tpda3');
use_ok('Tpda3::Utils');
use_ok('Tpda3::Config');
use_ok('Tpda3::Config::Utils');
use_ok('Tpda3::Db');
use_ok('Tpda3::Db::Connection');
use_ok('Tpda3::Db::Connection::Postgresql');
use_ok('Tpda3::Model');
use_ok('Tpda3::Observable');
use_ok('Tpda3::Tk::Controller');
use_ok('Tpda3::Tk::View');
use_ok('Tpda3::Tk::Screen');
use_ok('Tpda3::Tk::TB');
use_ok('Tpda3::Tk::TM');
use_ok('Tpda3::Tk::Entry');
use_ok('Tpda3::Tk::Text');
use_ok('Tpda3::Tk::Validation');

#-- Tpda3-AppName application

use_ok('Tpda3::Tk::App::AppName::Screen1');

