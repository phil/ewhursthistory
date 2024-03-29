package MT::Bootstrap;

use strict;
use MT;

sub BEGIN {
    my ($dir, $orig_dir);
    require File::Spec;
    if (!($dir = $ENV{MT_HOME})) {
        if ($0 =~ m!(.*([/\\]))!) {
            $orig_dir = $dir = $1;
            my $slash = $2;
            $dir =~ s!(?:[/\\]|^)(?:plugins[/\\].*|tools[/\\])$!$slash!;
            $dir = '' if ($dir =~ m!^\.?[\\/]$!);
        } elsif ($] >= 5.006) {
            # MT_DIR/lib/MT/Bootstrap.pm -> MT_DIR/lib/MT -> MT_DIR/lib -> MT_DIR
            require File::Basename;
            $dir = File::Basename::dirname(File::Basename::dirname(
                File::Basename::dirname(File::Spec->rel2abs(__FILE__))));
        }
        unless ($dir) {
            $orig_dir = $dir = $ENV{PWD} || '.';
            $dir =~ s!(?:[/\\]|^)(?:plugins[/\\].*|tools[/\\]?)$!!;
        }
        $ENV{MT_HOME} = $dir;
    }
    unshift @INC, File::Spec->catdir($dir, 'extlib');
    unshift @INC, File::Spec->catdir($orig_dir, 'lib')
        if $orig_dir && ($orig_dir ne $dir);
}

sub import {
    my ($pkg, %param) = @_;

    # use 'App' parameter, or MT_APP from the environment
    my $class = $param{App} || $ENV{MT_APP};

    if ($class) {
        # ready to run now... run inside an eval block so we can gracefully
        # die if something bad happens
        eval {
            eval "require $class; 1;" or die $@;
            my $app = $class->new( %param ) or die $class->errstr;
            local $SIG{__WARN__} = sub { $app->trace($_[0]) };
            MT->set_instance($app);
            $app->run;
        };
        if ($@) {
            my $err = $@;
            my $app = eval { MT->instance };
            if ($app && UNIVERSAL::isa($app, 'MT::App')) {
                eval {
                    my %param = ( error => $err );
                    if ($err =~ m/Bad ObjectDriver/) {
                        $param{error_database_connection} = 1;
                    } elsif ($err =~ m/Bad CGIPath/) {
                        $param{error_cgi_path} = 1;
                    } elsif ($err =~ m/Missing configuration file/) {
                        $param{error_config_file} = 1;
                    }
                    my $page = $app->build_page('error.tmpl', \%param)
                        or die $app->errstr;
                    print "Content-Type: text/html\n\n";
                    print $page;
                };
                if ($@) {
                    print "Content-Type: text/plain\n\n";
                    print $app ? $app->translate("Got an error: [_1]", $@) : "Got an error: $@";
                }
            } else {
                print "Content-Type: text/plain\n\n";
                print $app ? $app->translate("Got an error: [_1]", $err) : "Got an error: $err\n";
            }
        }
    }
}

1;
__END__

=head1 NAME

MT::Bootstrap

=head1 DESCRIPTION

Startup module used to simplify MT application CGIs.

=head1 SYNOPSIS

Movable Type CGI scripts should utilize the C<MT::Bootstrap> module
to invoke the application code itself. When run, it is necessary
to add the MT "lib" directory to the Perl include path.

Example (for CGIs in the main MT directory itself):

    #!/usr/bin/perl -w
    use strict;
    use lib $ENV{MT_HOME} ? "$ENV{MT_HOME}/lib" : 'lib';
    use MT::Bootstrap App => 'MT::App::CMS';

Example (for CGIs in a plugin subdirectory, ie MT/plugins/plugin_x):

    #!/usr/bin/perl -w
    use strict;
    use lib "lib", ($ENV{MT_HOME} ? "$ENV{MT_HOME}/lib" : "../../lib");
    use MT::Bootstrap App => 'MyApp';

=cut
