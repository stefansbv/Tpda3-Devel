use strict;
use warnings;

use Test::More tests => 11;

#use Data::Dumper;

use_ok('Tpda3::Devel');
use_ok('Tpda3::Devel::Info::Config');
use_ok('Tpda3::Devel::Info::Table');

my $args = {
    cfname => 'test-tk',
    user   => undef,
    pass   => undef,
};

ok my $ic = Tpda3::Devel::Info::Config->new($args),
    'create Info::Config instance';
isa_ok $ic, 'Tpda3::Devel::Info::Config', 'instance';

ok my $it = Tpda3::Devel::Info::Table->new(), 'create Info::Table instance';
isa_ok $it, 'Tpda3::Devel::Info::Table', 'instance';

my $dbh = $it->dbh;
ok $dbh->isa('DBI::db'), 'created db handle';

ok my $dbc = $it->dbc, 'created dbc';

ok my $tb_list = $it->table_list, 'get table list';
is ref $tb_list, 'ARRAY', 'table list isa array';
#diag Dumper($tb_list);

# done
