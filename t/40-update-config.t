#!perl

use Test::More tests => 4;
use Test::Exception;
use File::Spec::Functions;

use_ok('Tpda3::Devel');

# Check functions

use_ok('Tpda3::Devel::Edit::Config');

my $scrcfg_fn   = 'scrtest.conf';
my $scrcfg_ap   = catdir('t', 'output');
my $scrcfg_apfn = catfile($scrcfg_ap, $scrcfg_fn);

my $args = {
    scrcfg_fn   => $scrcfg_fn,
    scrcfg_ap   => $scrcfg_ap,
    scrcfg_apfn => $scrcfg_apfn,
};

ok my $tdec = Tpda3::Devel::Edit::Config->new, 'new config editor';
is $tdec->config_update($args), undef, 'update config';

# done
