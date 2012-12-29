#!perl

use utf8;
use Test::More tests => 2;
use Test::Exception;
use File::Spec;
use YAML::Tiny qw<Load LoadFile>;

use Tpda3::Devel::Edit::Menu;

my $e = Tpda3::Devel::Edit::Menu->new();

my $menu_file = File::Spec->catfile( 't', 'output', 'menu.yml' );

is($e->menu_update($menu_file, 'Label1'), undef, 'update menu');

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
my @document2 = LoadFile($menu_file);

is_deeply(\@document1, \@document2, 'compare structure');

# done
