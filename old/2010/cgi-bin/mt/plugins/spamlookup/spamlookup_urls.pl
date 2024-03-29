# SpamLookup
# Original copyright (c) 2004-2005, Brad Choate and Tobias Hoellrich
#
# Modifications and integration Copyright 2005 Six Apart.
# This code cannot be redistributed without permission from www.sixapart.com.
# For more information, consult your Movable Type license.
#
# $Id: spamlookup_urls.pl 16984 2005-09-01 01:55:29Z bchoate $

package MT::Plugin::SpamLookup::Link;

use strict;
use MT;
use MT::Plugin;

use vars qw($VERSION);
sub BEGIN {
    @MT::Plugin::SpamLookup::Link::ISA = ('MT::Plugin');
    $VERSION = '2.0';
    my $plugin;
    $plugin = new MT::Plugin::SpamLookup::Link({
        name => 'SpamLookup - Link',
        version => $VERSION,
        description => 'SpamLookup module for junking and moderating feedback based on link filters.',
        doc_link => 'http://www.spamlookup.com/wiki/LinkFilter',
        author_name => 'Six Apart, Ltd.',
        author_link => 'http://www.sixapart.com/',
        config_template => 'url_config.tmpl',
        settings => new MT::PluginSettings([
            ['urlcount_none_mode', { Default => 1 }],
            ['urlcount_none_weight', { Default => 1 }],
            ['urlcount_moderate_mode', { Default => 1 }],
            ['urlcount_moderate_limit', { Default => 3 }],
            ['urlcount_junk_mode', { Default => 1 }],
            ['urlcount_junk_limit', { Default => 10 }],
            ['urlcount_junk_weight', { Default => 1 }],
            ['priorurl_mode', { Default => 1 }],
            ['priorurl_weight', { Default => 1 }],
            ['prioremail_mode', { Default => 1 }],
            ['prioremail_weight', { Default => 1 }],
        ])
    });
    MT->add_plugin($plugin);
    MT->register_junk_filter({
        code => sub { $plugin->runner('urls', @_) },
        plugin => $plugin,
        name => 'SpamLookup Link Filter'
    });
    MT->register_junk_filter({
        code => sub { $plugin->runner('link_memory', @_) },
        plugin => $plugin,
        name => 'SpamLookup Link Memory'
    });
    MT->register_junk_filter({
        code => sub { $plugin->runner('email_memory', @_) },
        plugin => $plugin,
        name => 'SpamLookup Email Memory'
    });
}

sub config_tmpl {
    my $plugin = shift;
    my $tmpl = $plugin->load_tmpl('url_config.tmpl');
    $tmpl->param('sql', UNIVERSAL::isa(MT::Object->driver, 'MT::ObjectDriver::DBI'));
    $tmpl;
}

sub runner {
    my $plugin = shift;
    my $method = shift;
    require spamlookup;
    return $_->($plugin, @_) if $_ = \&{"spamlookup::$method"};
    die "Failed to find spamlookup::$method";
}

sub apply_default_settings {
    my $plugin = shift;
    my ($data, $scope) = @_;
    if ($scope ne 'system') {
        my $sys = $plugin->get_config_obj('system');
        my $sysdata = $sys->data();
        if ($plugin->{settings} && $sysdata) {
            foreach (keys %$sysdata) {
                $data->{$_} = $sysdata->{$_}
                    if (!exists $data->{$_}) || (!defined $data->{$_});
            }
        }
    } else {
        $plugin->SUPER::apply_default_settings(@_);
    }
}

1;
