#!perl

use utf8;
use Test::More tests => 2;
use Test::Exception;
use File::Spec;
use YAML::Tiny qw<Load LoadFile>;

use Tpda3::Devel::Edit::Menu;

my $opt = {};
$opt->{screen}    = 'Label1';
$opt->{menu_apfn} = File::Spec->catfile( 't', 'output', 'menu.yml' );

my $e = Tpda3::Devel::Edit::Menu->new($opt);

is($e->menu_update(), undef, 'update menu');

my $yaml_str = <<'YAML_TEXT';
---
appmenubar:
  menu_user:
    id: 1001
    label: TestModule
    underline: 0
    popup:
      1:
        key: ~
        label: Label1
        name: Label1
        sep: none
        underline: 0
YAML_TEXT

my @document1 = Load($yaml_str);
my @document2 = LoadFile( $opt->{menu_apfn} );

is_deeply(\@document1, \@document2, 'compare structure');

# done
