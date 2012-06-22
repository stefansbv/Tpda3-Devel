#!perl

#use Data::Dumper;
use Test::More tests => 9;

use_ok('Tpda3::Devel');
use_ok('Tpda3::Devel::Info::Config');
use_ok('Tpda3::Devel::Info::Table');

my $args = {
    cfname => 'test-tk',
    user   => undef,
    pass   => undef,
};

my $ic  = Tpda3::Devel::Info::Config->new($args);
ok( $ic->isa('Tpda3::Devel::Info::Config'), 'created Info::Config instance' );

my $it  = Tpda3::Devel::Info::Table->new();
ok( $it->isa('Tpda3::Devel::Info::Table'), 'created Info::Table instance' );

my $dbh =  $it->dbh;
ok( $dbh->isa('DBI::db'), 'created db handle' );

my $dbc =  $it->dbc;
# diag $dbc;
ok( $dbc->isa('Tpda3::Db::Connection::Postgresql'), 'created dbc' );

my $table = 'orderdetails';
my $itd = $it->table_info($table);
# diag Dumper( $itd );

is($itd->{name}, $table, 'check table name');

my $tb_list = $it->table_list;

my $table_list = [
    qw{
        payments
        customers
        orderdetails
        products
        orders
        productlines
        employees
        offices
        country
        status
        reports_det
        reports
        }
];

is_deeply( $tb_list, $table_list, 'table list' );

# done
