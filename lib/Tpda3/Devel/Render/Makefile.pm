package Tpda3::Devel::Render::Makefile;

# ABSTRACT: Create a screen module file

use 5.010001;
use strict;
use warnings;
use utf8;

require Tpda3::Devel::Config;
require Tpda3::Devel::Info::App;
require Tpda3::Devel::Render;


sub new {
    my $class = shift;

    my $self = {};

    bless $self, $class;

    return $self;
}


sub generate_makefile {
    my ($self, $args) = @_;

    my $module = $args->{module};

    die "Need a module name!" unless $module;

    my $tdc = Tpda3::Devel::Config->new;
    my ($user_name, $user_email) = $tdc->get_gitconfig;

    my $data = {
        module      => $module,
        copy_author => $user_name,
        copy_email  => $user_email,
        copy_year   => (localtime)[5] + 1900,
    };

    my $app_info = Tpda3::Devel::Info::App->new($module);
    my $output_path = $app_info->get_app_rp($module);

    my $opts = {
        type        => 'makefile',
        output_file => 'Makefile.PL',
        data        => $data,
        output_path => $output_path,
        templ_path  => undef,
    };

    Tpda3::Devel::Render->render($opts);

    return;
}

1;

__END__

=pod

=head2 new

Constructor.

=head2 generate_makefile

Generate screen module.

=cut
