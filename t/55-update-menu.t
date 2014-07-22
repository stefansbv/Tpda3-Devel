#!perl

use utf8;
use Test::More tests => 3;
use Test::Exception;
use File::Spec;
use YAML::Tiny qw<Load LoadFile>;

require Tpda3::Devel::Edit::Menu;

my $opt = {};
my $label     = 'Label1';
my $menu_file = File::Spec->catfile( 't', 'output', 'menu.yml' );

ok( my $em = Tpda3::Devel::Edit::Menu->new, 'new editor' );

is( $em->menu_update($label, $menu_file), undef, 'update menu' );

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
