package Tpda3::Devel::Utils;

# ABSTRACT: Return the current context (can be called only from a CLIF::Command)

use strict;
use warnings;

use Exporter;

use base 'Exporter';
our @EXPORT = qw( app_context );

sub app_context {
    my $self = shift;
    my $context = $self->cache->get('context');
    my $name    = $self->cache->get('appname');
    my $scope;
    $scope = 'create a new Tpda3 application' if $context eq 'new';
    $scope = 'update a Tpda3 application'     if $context eq 'upd';
    qq{# Current project: $name\n# Current scope  : $scope};
}

1;
