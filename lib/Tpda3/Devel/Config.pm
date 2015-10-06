package Tpda3::Devel::Config;

# ABSTRACT: Get user name and email from git config.

use 5.010001;
use strict;
use warnings;
use utf8;

use File::HomeDir;
use Path::Tiny;
use Config::GitLike;


sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}


sub get_gitconfig {
    my $self = shift;

    my $config_file = path( File::HomeDir->my_home, '.gitconfig');

    unless ( $config_file->is_file ) {
        print "Git configuration file not found!\n";
        print "Please configure with:\n";
        print "# git config --global user.name 'John Doe'\n";
        print "# git config --global user.email johndoe\@example.com\n";
        return ('<user name here>', '<user e-mail here>');
    }

    my $c = Config::GitLike->new( confname => $config_file->stringify );
    my $user  = $c->get( key => 'user.name' );
    my $email = $c->get( key => 'user.email' );

    return ($user, $email);
}

1;

__END__

=pod

=head1 SYNOPSIS

    use Tpda3::Devel::Config;

    my $dip = Tpda3::Devel::Config->new();

=head2 new

Constructor.

=head2 get_app_path

Check and return the application path.

=cut
