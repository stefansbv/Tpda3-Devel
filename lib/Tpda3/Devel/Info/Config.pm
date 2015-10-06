package Tpda3::Devel::Info::Config;

# ABSTRACT: Tpda3 application config related info

use 5.010001;
use strict;
use warnings;

require Tpda3::Config;
require Tpda3::Devel::Info::App;


sub new {
    my ( $class, $opt ) = @_;

    my $self = bless {}, $class;
    $self->_init($opt);

    return $self;
}

sub _init {
    my ($self, $opt) = @_;

    my $args = {
        cfname => $opt->{mnemonic},
        user   => undef,
        pass   => undef,
    };

    $self->{_cfg} = Tpda3::Config->instance($args);

    return;
}


sub config_info {
    my ($self) = @_;

    my $appcfg = $self->{_cfg};

    my $cfname = $appcfg->cfname;
    my $apps   = $appcfg->cfapps;
    my $module = $appcfg->application->{module};

    # Check configured toolkit type
    my $toolkit = $appcfg->application->{widgetset};
    die "Fatal!: $toolkit toolkit not supported!"
        unless $toolkit eq 'Tk';

    return {
        cfname   => $cfname,
        apps_dir => $apps,
        module   => $module,
    };
}

1;

__END__

=pod

=head2 new

Constructor.

=head2 config_info

Application configuration info.

=cut
