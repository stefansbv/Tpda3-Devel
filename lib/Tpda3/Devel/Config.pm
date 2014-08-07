package Tpda3::Devel::Config;

# ABSTRACT: Get user name and email from git config.

use 5.010001;
use strict;
use warnings;
use utf8;

use File::Spec::Functions;
use File::HomeDir;
use Config::GitLike;

=head1 SYNOPSIS

    use Tpda3::Devel::Config;

    my $dip = Tpda3::Devel::Config->new();

=head2 new

Constructor.

=cut

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

=head2 get_app_path

Check and return the application path.

=cut

sub get_gitconfig {
    my $self = shift;

    my $config_file = catfile( File::HomeDir->my_home, '.gitconfig');

    unless (-f $config_file) {
        print "Git configuration file not found!\n";
        print "Please configure with:\n";
        print "# git config --global user.name 'John Doe'\n";
        print "# git config --global user.email johndoe\@example.com\n";
        return ('<user name here>', '<user e-mail here>');
    }

    my $c = Config::GitLike->new( confname => $config_file );
    my $user  = $c->get( key => 'user.name' );
    my $email = $c->get( key => 'user.email' );

    return ($user, $email);
}

1;
