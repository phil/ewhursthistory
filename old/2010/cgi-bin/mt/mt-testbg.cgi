#!/usr/bin/perl -w

# Copyright 2001-2005 Six Apart. This code cannot be redistributed without
# permission from www.sixapart.com.  For more information, consult your
# Movable Type license.
#
# $Id: mt-testbg.cgi 16385 2005-08-18 20:59:46Z ezra $

use strict;

local $| = 1;
print "Content-Type: text/html\n\n";
print "<html>\n<body>\n<pre>\n\n";

eval {
    local $SIG{__WARN__} = sub { print "**** WARNING: $_[0]\n" };

    my $pid = fork(); 
    if (defined $pid)
    {
        if ($pid) {
            print wait() > 0
                   ? "Background tasks are available\n" 
                   : "Background tasks are not available\n";
        } else { 
            sleep 1;
            exit(0);
        } 
    } else { print "Background tasks are not available\n"; }
};
print "Got an error: $@" if $@;

print "\n\n</pre>\n</body>\n</html>";

