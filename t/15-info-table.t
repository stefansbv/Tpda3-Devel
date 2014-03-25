use strict;
use warnings;

use Test::More tests => 12;

#use Data::Dumper;

use_ok('Tpda3::Devel');
use_ok('Tpda3::Devel::Info::Config');
use_ok('Tpda3::Devel::Info::Table');

my $args = {
    cfname => 'test-tk',
    user   => undef,
    pass   => undef,
};

$args->{user} = $ENV{DBI_USER} unless defined $args->{user};
$args->{pass} = $ENV{DBI_PASS} unless defined $args->{pass};

ok my $ic = Tpda3::Devel::Info::Config->new($args),
    'create Info::Config instance';
isa_ok $ic, 'Tpda3::Devel::Info::Config', 'instance';

ok my $it = Tpda3::Devel::Info::Table->new(), 'create Info::Table instance';
isa_ok $it, 'Tpda3::Devel::Info::Table', 'instance';

my $dbh = $it->dbh;
ok $dbh->isa('DBI::db'), 'created db handle';

ok my $dbc = $it->dbc, 'created dbc';

my $table = 'orderdetails';
my $itd   = $it->table_info($table);
#diag Dumper($itd);

is $itd->{name}, $table, 'check table name';

ok my $tb_list = $it->table_list, 'get table list';
is ref $tb_list, 'ARRAY', 'table list isa array';
#diag Dumper($tb_list);

# done
