package Tpda3::Devel::Render::Screen;

# ABSTRACT: Create a screen module file

use 5.010001;
use strict;
use warnings;
use utf8;

use Config::General qw{ParseConfig};
use Path::Tiny;
use Tie::IxHash;

require Tpda3::Devel::Config;
require Tpda3::Devel::Info::App;
require Tpda3::Devel::Render;


sub new {
    my ( $class, $opt ) = @_;

    my $self = {};

    bless $self, $class;
    $self->{opt} = $opt;

    return $self;
}


sub generate_screen {
    my ($self, $opts) = @_;

    my $screen = $opts->{screen};

    print "Creating screen module ........\r";

    die "A screen name is required!" unless $screen;

    my $config_file = $opts->{scrcfg_apfn};

    die unless defined $config_file;

    unless (-f $config_file) {
        die "Can't locate config file:\n$config_file";
    }

    tie my %cfg, "Tie::IxHash";     # keep the sections order

    %cfg = ParseConfig(
        -ConfigFile => $config_file,
        -Tie        => 'Tie::IxHash',
    );

    my $app_info = Tpda3::Devel::Info::App->new;

    my $tdc = Tpda3::Devel::Config->new;
    my ($user_name, $user_email) = $tdc->get_gitconfig;

    my $data = {
        copy_author => $user_name,
        copy_email  => $user_email,
        copy_year   => (localtime)[5] + 1900,
        module      => $app_info->get_app_name,
        screen      => $screen,
        conf        => lc $screen . '.conf',
        columns     => $cfg{maintable}{columns},
        pkcol       => $cfg{maintable}{pkcol}{name},
    };

    my $screen_fn   = "$screen.pm";
    my $output_path = $app_info->get_screen_module_ap;

    die "No screen output path!" unless $output_path;
    die "No screen file name!"   unless $screen_fn;

    if ( -f path($output_path, $screen_fn) ) {
        print "Creating screen module .... skipped\n";
        return;
    }

    my $args = {
        type        => 'screen',
        output_file => $screen_fn,
        data        => { r => $data },
        output_path => $output_path,
        templ_path  => undef,
    };

    Tpda3::Devel::Render->render($args);

    print "Creating screen module ....... done\n";

    return;
}

1;

__END__

=pod

=head2 new

Constructor.

=head2 generate_screen

Generate a screen module from templates.

=cut
