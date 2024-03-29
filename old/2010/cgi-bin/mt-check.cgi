#!/usr/bin/perl -w

# Copyright 2001-2005 Six Apart. This code cannot be redistributed without
# permission from www.sixapart.com.  For more information, consult your
# Movable Type license.
#
# $Id: mt-check.cgi.pre 17330 2005-09-09 21:55:03Z bchoate $

use strict;
sub BEGIN {
    my $dir;
    require File::Spec;
    if (!($dir = $ENV{MT_HOME})) {
        if ($0 =~ m!(.*[/\\])!) {
            $dir = $1;
        } else {
            $dir = './';
        }
        $ENV{MT_HOME} = $dir;
    }
    unshift @INC, File::Spec->catdir($dir, 'lib');
    unshift @INC, File::Spec->catdir($dir, 'extlib');
}

local $| = 1;

my $mt;
eval {
    require MT;
    $mt = MT->new();
};

use MT::L10N;
my $LH = $mt ? $mt->language_handle : MT::L10N->get_handle('en_US');

sub trans_templ {
    my($text) = @_;
    return $mt->translate_templatized($text) if $mt;
    $text =~ s!(<MT_TRANS(?:\s+((?:\w+)\s*=\s*(["'])(?:<[^>]+?>|[^\3]+?)+?\3))+?\s*/?>)!
        my($msg, %args) = ($1);
        #print $msg;
        while ($msg =~ /\b(\w+)\s*=\s*(["'])((?:<[^>]+?>|[^\2])*?)\2/g) {  #"
            $args{$1} = $3;
        }
        $args{params} = '' unless defined $args{params};
        my @p = map MT::Util::decode_html($_),
                split /\s*%%\s*/, $args{params};
        @p = ('') unless @p;
        my $translation = translate($args{phrase}, @p);
        $translation =~ s/([\\'])/\\$1/sg if $args{escape};
        $translation;
    !ge;
    $text;
}

sub translate {
    return $mt->translate(@_) if $mt;
    $LH->maketext(@_);
}

my $charset = $LH->encoding;
print "Content-Type: text/html; charset=$charset\n\n";
print trans_templ(<<HTML);

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<meta http-equiv="content-language" content="en" />
	
	<title><MT_TRANS phrase="Movable Type System Check"> [mt-check.cgi]</title>
	
	<style type=\"text/css\">
		<!--
		
			body {
				font-family : Trebuchet MS, Tahoma, Verdana, Arial, Helvetica, Sans Serif;
				font-size : smaller;
				padding-top : 0px;
				padding-left : 0px;
				margin : 0px;
				padding-bottom : 40px;
				width : 80%;
				border-right : 1px dotted #8faebe;
			}
			
			h1 {
				background : #8faebe;
				font-size: large;
				color : white;
				padding : 10px;
				margin-top : 0px;
				margin-bottom : 20px;
				text-align : center;
			}
			
			h2 {
				color: #fff;
				font-size: small;
				background : #8faebe;
				padding : 5px 10px 5px 10px;
				margin-top : 30px;
				margin-left : 40px;
				margin-right : 40px;
			}
			
			h3 {
				color: #333;
				font-size: small;
				margin-left : 40px;
				margin-bottom : 0px;
				padding-left : 20px;
			}
	
			p {
				padding-left : 20px;
				margin-left : 40px;
				margin-right : 60px;
				color : #666;
			}
			
			ul {
				padding-left : 40px;
				margin-left : 40px;
			}
			
			.info {
				margin-left : 60px;
				margin-right : 60px;
				padding : 20px;
				border : 1px solid #666;
				background : #eaf2ff;
				color : black;
			}
		
			.alert {
				padding : 15px;
				border : 1px solid #666;
				background : #ff9;
				color : black;
			}
			

			.ready {
				color: #fff;
				background-color: #9C6;
			}

			.bad {
				padding-top : 0px;
				margin-top : 4px;
				border-left : 1px solid red;
				padding-left : 10px;
				margin-left : 60px;
			}
			
			.good {
				color: #93b06b;
				padding-top : 0px;
				margin-top : 0px;
			}
		
		//-->
	</style>

</head>

<body>

<h1><MT_TRANS phrase="Movable Type System Check"> [mt-check.cgi]</h1>

<p class="info"><MT_TRANS phrase="This page provides you with information on your system\'s configuration and determines whether you have all of the components you need to run Movable Type."></p>


HTML


my $is_good = 1;

my @REQ = (
    [ 'CGI', 0, 1, translate('CGI is required for all Movable Type application functionality.') ],

    [ 'HTML::Template', 2, 1, translate('HTML::Template is required for all Movable Type application functionality.') ],

    [ 'Image::Size', 0, 1, translate('Image::Size is required for file uploads (to determine the size of uploaded images in many different formats).') ],

    [ 'File::Spec', 0.8, 1, translate('File::Spec is required for path manipulation across operating systems.') ],

    [ 'CGI::Cookie', 0, 1, translate('CGI::Cookie is required for cookie authentication.') ],
);

my @DATA = (
    [ 'DB_File', 0, 0, translate('DB_File is required if you want to use the Berkeley DB/DB_File backend.') ],

    [ 'DBI', 1.21, 0, translate('DBI is required if you want to use any of the SQL database drivers.') ],

    [ 'DBD::mysql', 0, 0, translate('DBI and DBD::mysql are required if you want to use the MySQL database backend.') ],

    [ 'DBD::Pg', 1.32, 0, translate('DBI and DBD::Pg are required if you want to use the PostgreSQL database backend.') ],

    [ 'DBD::SQLite', 0, 0, translate('DBI and DBD::SQLite are required if you want to use the SQLite database backend.') ],
);

my @OPT = (
    [ 'HTML::Entities', 0, 0, translate('HTML::Entities is needed to encode some characters, but this feature can be turned off using the NoHTMLEntities option in mt.cfg.') ],

    [ 'LWP::UserAgent', 0, 0, translate('LWP::UserAgent is optional; It is needed if you wish to use the TrackBack system, the weblogs.com ping, or the MT Recently Updated ping.') ],

    [ 'SOAP::Lite', 0.50, 0, translate('SOAP::Lite is optional; It is needed if you wish to use the MT XML-RPC server implementation.') ],

    [ 'File::Temp', 0, 0, translate('File::Temp is optional; It is needed if you would like to be able to overwrite existing files when you upload.') ],

    [ 'Image::Magick', 0, 0, translate('Image::Magick is optional; It is needed if you would like to be able to create thumbnails of uploaded images.') ],

    [ 'Storable', 0, 0, translate('Storable is optional; it is required by certain MT plugins available from third parties.')],

    [ 'Crypt::DSA', 0, 0, translate('Crypt::DSA is optional; if it is installed, comment registration sign-ins will be accelerated.')],

    [ 'MIME::Base64', 0, 0, translate('MIME::Base64 is required in order to enable comment registration.')],

    [ 'XML::Atom', 0, 0, translate('XML::Atom is required in order to use the Atom API.')],
);

use Cwd;
my $cwd = '';
{
    my($bad);
    local $SIG{__WARN__} = sub { $bad++ };
    eval { $cwd = Cwd::getcwd() };
    if ($bad || $@) {
        eval { $cwd = Cwd::cwd() };
        if ($@ && $@ !~ /Insecure \$ENV{PATH}/) {
            die $@;
        }
    }
}

my $ver = $^V ? join('.', unpack 'C*', $^V) : $];
my $server = $ENV{SERVER_SOFTWARE};
my $inc_path = join "<br />\n", @INC;
print trans_templ(<<INFO);
<h2><MT_TRANS phrase="System Information:"></h2>
<ul>
	<li><strong><MT_TRANS phrase="Current working directory:"></strong> <code>$cwd</code></li>
	<li><strong><MT_TRANS phrase="MT home directory:"></strong> <code>$ENV{MT_HOME}</code></li>
	<li><strong><MT_TRANS phrase="Operating system:"></strong> $^O</li>
	<li><strong><MT_TRANS phrase="Perl version:"></strong> <code>$ver</code></li>
	<li><strong><MT_TRANS phrase="Perl include path:"></strong> <code>$inc_path</code></li>
INFO
if ($server) {
print trans_templ(<<INFO);
	<li><strong><MT_TRANS phrase="Web server:"></strong> <code>$server</code></li>
INFO
}

## Try to create a new file in the current working directory. This
## isn't a perfect test for running under cgiwrap/suexec, but it
## is a pretty good test.
my $TMP = "test$$.tmp";
local *FH;
if (open(FH, ">$TMP")) {
    my $mode = (stat($TMP))[2] & 07777;
    if (($mode & 07000) && !($mode & 07700)) {
        print trans_templ("	<li><MT_TRANS phrase=\"(Probably) Running under cgiwrap or suexec\"></li>\n");
    }
    unlink($TMP);
}

print "\n\n</ul>\n";

exit if $ENV{QUERY_STRING} && $ENV{QUERY_STRING} eq 'sys-check';

use Text::Wrap;
$Text::Wrap::columns = 72;

for my $list (\@REQ, \@DATA, \@OPT) {
    my $data = ($list == \@DATA);
    my $req = ($list == \@REQ);
    my $type;
    if ($data) {
        $type = translate("Data Storage");
    } elsif ($req) {
        $type = translate("Required");
    } else {
        $type = translate("Optional");
    }
    print trans_templ(qq{<h2><MT_TRANS phrase="Checking for [_1] Modules:" params="$type"></h2>\n\t<div>\n});
    if (!$req && !$data) {
        print trans_templ(<<MSG);
	<p class="info"><MT_TRANS phrase="The following modules are <strong>optional</strong>. If your server does not have these modules installed, you only need to install them if you require the functionality that the module provides."></p>

MSG
    }
    if ($data) {
        print trans_templ(<<MSG);
		<p class="info"><MT_TRANS phrase="Some of the following modules are required by the various data storage options in Movable Type. In order run the system, your server needs to have either DB_File, or else DBI and at least one of the other modules installed."></p>

MSG
    }
    my $got_one_data = 0;
    my $dbi_is_okay = 0;
    for my $ref (@$list) {
        my($mod, $ver, $req, $desc) = @$ref;
        print "    <h3>$mod" .
            ($ver ? " (version &gt;= $ver)" : "") . "</h3>";
        eval("use $mod" . ($ver ? " $ver;" : ";"));
        if ($@) {
            $is_good = 0 if $req;
            my $msg = $ver ?
                      trans_templ(qq{<p class="bad"><MT_TRANS phrase="Either your server does not have [_1] installed, the version that is installed is too old, or [_1] requires another module that is not installed." params="$mod"> }) :
                      trans_templ(qq{<p class="bad"><MT_TRANS phrase="Your server does not have [_1] installed, or [_1] requires another module that is not installed." params="$mod"> });
            $msg   .= $desc .
                      trans_templ(qq{ <MT_TRANS phrase="Please consult the installation instructions for help in installing [_1]." params="$mod"></p>\n\n});
            print wrap("        ", "        ", $msg), "\n\n";
        } else {
            if ($data) {
                $dbi_is_okay if $mod eq 'DBI';
                if ($mod eq 'DB_File') {
                    $got_one_data = 1;
                } elsif ($mod ne 'DBI') {
                    if ($mod eq 'DBD::mysql') {
                        if ($DBD::mysql::VERSION == 3.0000) {
                            print trans_templ(qq{<p class="bad"><MT_TRANS phrase="The DBD::mysql version you have installed is known to be incompatible with Movable Type. Please install the current release available from CPAN."></p>});
                        }
                    }
                    $got_one_data = 1 if $dbi_is_okay;
                }
            }
            print trans_templ(qq{<p class="good"><MT_TRANS phrase="Your server has [_1] installed (version [_2])." params="$mod%%} . $mod->VERSION . qq{"></p>\n\n});
        }
    }
    $is_good &= $got_one_data if $data;
    print "\n\t</div>\n\n";
}

if ($is_good) {
    print trans_templ(<<HTML);
    
	<h2 class="ready"><MT_TRANS phrase="Movable Type System Check Successful"></h2>

	<p><strong><MT_TRANS phrase="You're ready to go!"></strong> <MT_TRANS phrase="Your server has all of the required modules installed; you do not need to perform any additional module installations. Continue with the installation instructions."></p>

</div>


HTML
}

print "</body>\n\n</html>\n";
