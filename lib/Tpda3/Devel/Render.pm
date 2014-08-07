package Tpda3::Devel::Render;

# ABSTRACT: Render a file from a template

use 5.010001;
use strict;
use warnings;
use utf8;

use Template;
use File::ShareDir qw(dist_dir);
use File::Spec::Functions;

=head2 render

Generate a file from templates.

If the output file parameter is just the file extension, then use type
as file name.

=cut

sub render {
    my ($self, $args) = @_;

    my $type        = $args->{type};
    my $output_file = $args->{output_file};
    my $data        = $args->{data};
    my $output_path = $args->{output_path};
    my $templ_path  = $args->{templ_path}
        // catdir( dist_dir('Tpda3-Devel'), 'templates' );

    my $template = $self->get_template_for($type);

    $output_file = "${type}$output_file" if $output_file =~ m{^\.};

    my $tt = Template->new(
        INCLUDE_PATH => $templ_path,
        OUTPUT_PATH  => $output_path,
    );

    $tt->process( $template, $data, $output_file, binmode => ':utf8' )
        or die $tt->error(), "\n";

    return $output_file;
}

=head2 get_template_for

Return the template name for one of the two known types: I<config> or
I<screen>.

=cut

sub get_template_for {
    my ($self, $type) = @_;

    die "The type argument is required" unless defined $type;

    my $template =
         $type eq q{}               ? die("Empty type argument")
       : $type eq 'config'          ? 'config.tt'
       : $type eq 'config-update'   ? 'config-refactor.tt'
       : $type eq 'screen'          ? 'screen.tt'
       : $type eq 'module'          ? 'module.tt'
       : $type eq 'makefile'        ? 'makefile.tt'
       : $type eq 'readme'          ? 'readme.tt'
       : $type eq 'cfg-application' ? 'config/application.tt'
       : $type eq 'cfg-menu'        ? 'config/menu.tt'
       : $type eq 'cfg-connection'  ? 'config/connection.tt'
       : $type eq 'test-load'       ? 'test/load.tt'
       : $type eq 'test-config'     ? 'test/config.tt'
       : $type eq 'test-connection' ? 'test/connection.tt'
       :                              die("Unknown type $type")
       ;

    return $template;
}

1;
