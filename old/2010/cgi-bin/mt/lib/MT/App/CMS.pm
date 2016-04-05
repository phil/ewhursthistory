# Copyright 2001-2005 Six Apart. This code cannot be redistributed without
# permission from www.sixapart.com.  For more information, consult your
# Movable Type license.
#
# $Id: CMS.pm 18049 2005-10-04 19:55:02Z mschenk $

package MT::App::CMS;
use strict;

use Symbol;
use File::Spec;
use MT::Util qw( encode_html format_ts offset_time_list offset_time epoch2ts
                 remove_html get_entry mark_odd_rows first_n_words
                 perl_sha1_digest_hex is_valid_email relative_date ts2epoch
                 perl_sha1_digest encode_url dirify encode_js is_valid_date);
use MT::App;
use MT::Author qw(:constants);
use MT::Permission;
@MT::App::CMS::ISA = qw( MT::App );

sub init {
    my $app = shift;
    $app->SUPER::init(@_) or return;
    $app->add_methods(
            'menu' => \&show_menu,
            'admin' => \&show_admin,
            'status' => \&show_status,
            'save' => \&save_object,
            'view' => \&edit_object,
            'list' => \&list_objects,
            'list_plugins' => \&list_plugins,
            'list_pings' => \&list_pings,
            'list_entries' => \&list_entries,
            'list_comments' => \&list_comments,
            'list_authors' => \&list_authors,
            'list_commenters' => \&list_commenters,
            'save_commenter_perm' => \&save_commenter_perm,
            'trust_commenter' => \&trust_commenter,
            'ban_commenter' => \&ban_commenter,
            'approve_item' => \&approve_item,
            'save_entries' => \&save_entries,
            'save_entry' => \&save_entry,
            'preview_entry' => \&preview_entry,
            'cfg_archives' => \&cfg_archives,
            'cfg_archives_do_add' => \&cfg_archives_do_add,
            'cfg_prefs' => \&cfg_prefs,
            'cfg_entries' => \&cfg_entries,
            'cfg_plugins' => \&cfg_plugins,
            'cfg_feedback' => \&cfg_feedback,
            'list_blogs' => \&list_blogs,
            'system_list_blogs' => \&system_list_blogs,
            'list_cat' => \&list_categories,
            'save_cat' => \&save_category,
            'edit_placements' => \&edit_placements,
            'save_placements' => \&save_placements,
            'delete_confirm' => \&delete_confirm,
            'delete' => \&delete,
            'edit_permissions' => \&edit_permissions,
            'save_permissions' => \&save_permissions,
            'ping' => \&send_pings,
            'rebuild_phase' => \&rebuild_phase,
            'rebuild' => \&rebuild_pages,
            'rebuild_new_phase' => \&rebuild_new_phase,
            'start_rebuild' => \&start_rebuild_pages,
            'rebuild_confirm' => \&rebuild_confirm,
            'send_notify' => \&send_notify,
            'start_upload' => \&start_upload,
            'upload_file' => \&upload_file,
            'start_upload_entry' => \&start_upload_entry,
            'show_upload_html' => \&show_upload_html,
            'logout' => \&logout,
            'start_recover' => \&start_recover,
            'recover' => \&recover_password,
            'bookmarklets' => \&bookmarklets,
            'make_bm_link' => \&make_bm_link,
            'view_log' => \&view_log,
            'list_log' => \&view_log,
            'reset_log' => \&reset_log,
            'export_log' => \&export_log,
            'start_import' => \&start_import,
            'search_replace' => \&search_replace,
            'export' => \&export,
            'import' => \&do_import,
            'pinged_urls' => \&pinged_urls,
            'show_entry_prefs' => \&show_entry_prefs,
            'save_entry_prefs' => \&save_entry_prefs,
            'reg_file' => \&reg_file,
            'reg_bm_js' => \&reg_bm_js,
            'category_add' => \&category_add,
            'category_do_add' => \&category_do_add,
            'cc_return' => \&cc_return,
            'reset_blog_templates' => \&reset_blog_templates,
            'handshake' => \&handshake,
            'itemset_action' => \&itemset_action,
            'handle_junk' => \&handle_junk,
            'not_junk' => \&not_junk,
            'cfg_system' => \&cfg_system_feedback,
            'cfg_system_feedback' => \&cfg_system_feedback,
            'save_plugin_config' => \&save_plugin_config,
            'reset_plugin_config' => \&reset_plugin_config,
            'save_cfg_system_feedback' => \&save_cfg_system_feedback,
            'update_list_prefs' => \&update_list_prefs,
            'update_welcome_message' => \&update_welcome_message,
            'upgrade' => \&upgrade,
            'plugin_control' => \&plugin_control,
    );
    $app->{state_params} = ['_type', 'id', 'tab', 'offset', 'filter', 'filter_val', 'blog_id', 'is_power_edit'];
    $app->{template_dir} = 'cms';
    $app->{plugin_template_path} = '';
    $app->{is_admin} = 1;
    $app->init_core_itemset_actions();
    $app;
}

sub init_request {
    my $app = shift;
    $app->SUPER::init_request(@_);
    $app->{default_mode} = 'list_blogs';
    my $mode = $app->mode;
    if (($mode ne 'logout') && ($mode ne 'start_recover') && ($mode ne 'recover')) {
        my $schema = $app->{cfg}->SchemaVersion;
        if (!$schema || ($schema < $app->schema_version)) {
            $mode = 'upgrade';
            $app->mode($mode);
        }
    }
    $app->{requires_login} = $mode && ($mode eq 'start_recover' ||
        $mode eq 'recover' || $mode eq 'reg_bm_js' ||
        $mode eq 'upgrade' || $mode eq 'logout') ?
        0 : 1;
}

sub init_core_itemset_actions {
    my $app = shift;
    $app->add_itemset_action({type => 'entry',
                              key => "set_published",
                              label => "Publish Entries",
                              code => \&publish_entries,
                          }, 1);
    $app->add_itemset_action({type => 'entry',
                              key => "set_draft",
                              label => "Unpublish Entries",
                              code => \&draft_entries,
                          }, 1);
    $app->add_itemset_action({type => 'ping',
                              key => "unapprove_ping",
                              label => "Unpublish TrackBack(s)",
                              code => \&unapprove_item,
                              condition => sub { $_[0] ne 'junk' }, # param is tab name
                          }, 1);
    $app->add_itemset_action({type => 'comment',
                              key => "unapprove_comment",
                              label => "Unpublish Comment(s)",
                              code => \&unapprove_item,
                              condition => sub { $_[0] ne 'junk' },
                          }, 1);
    $app->add_itemset_action({type => 'comment',
                              key => "trust_commenter",
                              label => "Trust Commenter(s)",
                              code => \&trust_commenter_by_comment,
                              condition => sub { $app->user_can_admin_commenters },
                          }, 1);
    $app->add_itemset_action({type => 'comment',
                              key => "untrust_commenter",
                              label => "Untrust Commenter(s)",
                              code => \&untrust_commenter_by_comment,
                              condition => sub { $app->user_can_admin_commenters },
                              }, 1);
    $app->add_itemset_action({type => 'comment',
                              key => "ban_commenter",
                              label => "Ban Commenter(s)",
                              code => \&ban_commenter_by_comment,
                              condition => sub { $app->user_can_admin_commenters },
                              }, 1);
    $app->add_itemset_action({type => 'comment',
                              key => "unban_commenter",
                              label => "Unban Commenter(s)",
                              code => \&unban_commenter_by_comment,
                              condition => sub { $app->user_can_admin_commenters },
                              }, 1);
    $app->add_itemset_action({type => 'commenter',
                              key => "untrust",
                              label => "Untrust Commenter(s)",
                              code => \&untrust_commenter,
                              condition => sub { $app->user_can_admin_commenters },
                          }, 1);
    $app->add_itemset_action({type => 'commenter',
                              key => "unban",
                              label => "Unban Commenter(s)",
                              code => \&unban_commenter,
                              condition => sub { $app->user_can_admin_commenters },
                          }, 1);
}

sub user_can_admin_commenters {
    my $app = shift;
    $app->{author}->is_superuser() ||
        ($app->{perms} && ($app->{perms}->can_administer_blog || $app->{perms}->can_edit_config));
}

sub update_welcome_message {
    my $app = shift;
    $app->validate_magic or return;

    # FIXME: permission check
    my $perms = $app->{perms};
    return $app->error("No permissions") unless $perms&& $perms->can_edit_config;

    my $blog_id = $app->param('blog_id');
    my $message = $app->param('welcome-message-text');
    my $blog = MT::Blog->load($blog_id, {cached_ok=>1}) or return $app->error("Invalid blog");
    $blog->welcome_msg($message);
    $blog->save;
    $app->redirect($app->uri( mode => 'menu', args => { blog_id => $blog_id } ));
}

sub upgrade {
    my $app = shift;

    # check for an empty database... no author table would do it...
    my $driver = MT::Object->driver;
    my $upgrade_script = $app->config('UpgradeScript');
    if (!$driver || !$driver->table_exists('MT::Author')) {
        return $app->redirect($app->path . $upgrade_script .
                              $app->uri_params( mode => 'install'));
    }

    if ($app->{cfg}->SchemaVersion &&
       ($app->{cfg}->SchemaVersion == $app->schema_version)) {
        return $app->redirect($app->uri);
    }

    return $app->redirect($app->path . $upgrade_script);
}

sub pre_run {
    my $app = shift;
    $app->SUPER::pre_run();
    ## Localize the label of the default text filter.
    $MT::Text_filters{__default__}{label} =
        $app->translate('Convert Line Breaks');
}

sub logout {
    my $app = shift;
    $app->SUPER::logout(@_);
}

sub start_recover {
    my $app = shift;
    $app->add_breadcrumb($app->translate('Password Recovery'));
    $app->build_page('recover.tmpl');
}

sub recover_password {
    my $app = shift;
    my $q = $app->param;
    my $name = $q->param('name');
    my $class;
    if (MT::Object->driver->isa('MT::ObjectDriver::DBM')) {
        $class = $app->user_class;
    } else {
        $class = 'MT::BasicAuthor';
    }
    eval "use $class;";
    my @author = $class->load({ name => $name });
    my $author;
    foreach (@author) {
        next unless ($_->email && $_->password) && ($_->password ne '(none)');
        $author = $_;
    }
    $app->log($app->translate("Invalid author name '[_1]' in password recovery attempt", $name)),
        return $app->error($app->translate(
            "Author name or birthplace is incorrect.")) unless $author;
    return $app->error($app->translate(
        "Author has not set birthplace; cannot recover password"))
        unless $author->hint;
    my $hint = $q->param('hint');
    $app->log($app->translate("Invalid attempt to recover password (used birthplace '[_1]')", $hint)),
    return $app->error($app->translate(
        "Author name or birthplace is incorrect.")) unless $author->hint eq $hint;
    return $app->error($app->translate("Author does not have email address"))
        unless $author->email;
    my @pool = ('a'..'z', 0..9);
    my $pass;
    for (1..8) { $pass .= $pool[ rand @pool ] }
    $author->set_password($pass);
    $author->save;
    $app->log($app->translate("Password was reset for author '[_1]' (user #[_2])", $author->name, $author->id));
    my %head = ( To => $author->email,
                 From => $app->config('EmailAddressMain') || $author->email,
                 Subject => "Password Recovery" );
    
    my $charset = $app->config('PublishCharset') || 'iso-8859-1';
    $head{'Content-Type'} = qq(text/plain; charset="$charset");
		 
    my $body = $app->translate('_USAGE_FORGOT_PASSWORD_1') .
               "\n\n    $pass\n\n" .
               $app->translate('_USAGE_FORGOT_PASSWORD_2') . "\n";
    require Text::Wrap;
    $Text::Wrap::columns = 72;
    $body = Text::Wrap::wrap('', '', $body);
    require MT::Mail;
    MT::Mail->send(\%head, $body) or
        return $app->error($app->translate(
            "Error sending mail ([_1]); please fix the problem, then " .
            "try again to recover your password.", MT::Mail->errstr));
    $app->add_breadcrumb($app->translate('Password Recovery'));
    $app->build_page('recover.tmpl', { recovered => 1,
                                       email => $author->email });
}

sub is_authorized {
    my $app = shift;
    my $blog_id = $app->param('blog_id');
    return 1 unless $blog_id;
    return unless my $author = $app->user;
    require MT::Permission;
    my $perms;
    $perms = $app->{perms} = MT::Permission->load({
        author_id => $author->id,
        blog_id => $blog_id });
    if (!$perms && $author->is_superuser) {
        $perms = $app->{perms} = new MT::Permission;
        $perms->author_id($author->id);
        $perms->blog_id($blog_id);
        $perms->set_full_permissions();
    }
    $perms ? 1 :
        $app->error($app->translate(
            "You are not authorized to log in to this blog."));
}

sub build_page {
    my $app = shift;
    my($page, $param) = @_;
    $param->{mode} = $app->mode;
    if (my $perms = $app->{perms}) {
        $param->{can_post} = $perms->can_post;
        $param->{can_upload} = $perms->can_upload;
        $param->{can_edit_entries} =
            $perms->can_post || $perms->can_edit_all_posts;
        $param->{can_search_replace} = $perms->can_edit_all_posts;
        $param->{can_edit_templates} = $perms->can_edit_templates;
        $param->{can_edit_authors} = $perms->can_administer_blog;
        $param->{can_edit_config} = $perms->can_edit_config;
        # FIXME: once we have edit_commenters permission
        $param->{can_edit_commenters} = $perms->can_edit_config();
        $param->{can_rebuild} = $perms->can_rebuild;
        $param->{can_edit_categories} = $perms->can_edit_categories;
        $param->{can_edit_notifications} = $perms->can_edit_notifications;
        $param->{has_manage_label} =
            $perms->can_edit_templates  || $perms->can_administer_blog ||
            $perms->can_edit_categories || $perms->can_edit_config;
        $param->{has_posting_label} =
            $perms->can_post  || $perms->can_edit_all_posts ||
            $perms->can_upload;
        $param->{has_community_label} =
            $perms->can_post  || $perms->can_edit_config ||
            $perms->can_edit_notifications || $perms->can_edit_all_posts;
        $param->{can_view_log} = $perms->can_view_blog_log;
    }
    my $blog_id = $app->param('blog_id');
    require MT::Blog;
    if (my $auth = $app->user) {
        $param->{is_administrator} = $auth->is_superuser;
        $param->{can_create_blog} = $auth->can_create_blog;
        $param->{can_view_log} ||= $auth->can_view_log;
        $param->{author_id} = $auth->id;
        $param->{author_name} = $auth->name;
        require MT::Permission;
        my @perms = MT::Permission->load({ author_id => $auth->id });
        my @data;
        for my $perms (@perms) {
            next unless $perms->role_mask;
            my $blog = MT::Blog->load($perms->blog_id, {cached_ok=>1})
                or die("Couldn't load blog; perhaps you have not " 
                       . "upgraded your MT database? - " . MT::Blog->errstr);
            push @data, { top_blog_id => $blog->id,
                          top_blog_name => $blog->name };
            $data[-1]{top_blog_selected} = 1
                if $blog_id && ($blog->id == $blog_id);
        }
        @data = sort { $a->{top_blog_name} cmp $b->{top_blog_name} } @data;
        $param->{top_blog_loop} = \@data;
    }
    if ($blog_id && $page ne 'login.tmpl') {
        my $blog = MT::Blog->load($blog_id, {cached_ok=>1});
	if ($blog) {
	    $param->{blog_name} = encode_html($blog->name);
	    $param->{blog_id} = $blog->id;
	    $param->{blog_url} = $blog->site_url;
	} else {
	    $app->error($app->translate("No such blog [_1]", $blog_id));
	}
    }
    if ($app->param('is_bm')) {
        $param->{is_bookmarklet} = 1;
    }
    if ($page ne 'login.tmpl') {
        if (ref $app eq 'MT::App::CMS') {
            $param->{system_overview_nav} = 1
                unless $blog_id ||
                exists $param->{system_overview_nav} ||
                $param->{no_breadcrumbs} ||
                $param->{is_bookmarklet};
            $param->{quick_search} = 1 unless defined $param->{quick_search};
        }
    }
    my $author = $app->user;
    if ($author && !$blog_id) {
        # then we're in a system overview area.
        my @perms = MT::Permission->load({author_id => $author->id});
        $param->{has_authors_button} = $author->is_superuser ||
            grep { $_->can_administer_blog } @perms;
    }

    my $static_app_url = $app->static_path;
    $param->{help_url} = $app->config('HelpURL') || $static_app_url . 'docs/';

    $param->{show_ip_info} ||= $app->config('ShowIPInformation');
    $param->{agent_mozilla} = ($ENV{HTTP_USER_AGENT} || '') =~ /gecko/i;
    $param->{have_tangent} = eval { require MT::Tangent; 1 } ? 1 : 0;
    my $type = $app->param('_type') || '';
    my $mode = $app->mode;
    $param->{plugin_action_loop} ||= $MT::PluginActions{$mode} || [];
    $param->{"mode_$mode" . ($type ? "_$type" : '')} = 1;
    $param->{return_args} ||= $app->make_return_args;
    if ($param->{system_overview_nav}) {
        unshift @{$app->{breadcrumbs}}, { bc_name => $app->translate("System Overview"),
                             bc_uri => $app->uri('mode' => 'admin') };
    } elsif ($param->{blog_id}) {
        if (my $blog = MT::Blog->load($param->{blog_id}, {cached_ok=>1})) {
            unshift @{$app->{breadcrumbs}}, { bc_name => $blog->name,
                             bc_uri => $app->uri('mode' => 'menu', args => { blog_id => $blog->id})};
        }
    }
    unshift @{$app->{breadcrumbs}}, { bc_name => $app->translate('Main Menu'),
                              bc_uri => $app->mt_uri };

    $app->SUPER::build_page($page, $param);
}

sub get_newsbox_content {
    my $app = shift;

    my $newsbox_url = $app->config('NewsboxURL');
    if ($newsbox_url && $newsbox_url ne 'disable') {
        my $NEWSCACHE_TIMEOUT = 60 * 60 * 24;
        require MT::Session;
        my ($news_object) = ("");
        my $retries = 0;
        $news_object = MT::Session->load({ id => 'NW' });
        if ($news_object &&
            ($news_object->start() < (time - $NEWSCACHE_TIMEOUT))) {
            $news_object->remove;
            $news_object = undef;
        }

        return $news_object->data()
            if ($news_object);

        eval { require LWP::UserAgent;
               require HTTP::Request;
           } or return;
        
        my $ua = new LWP::UserAgent(agent => 'Movable Type');
        my $req = new HTTP::Request(GET => $newsbox_url);
        my $resp = $ua->request($req);
        return unless $resp->is_success();
        my $result = $resp->content();
        
        if ($result) {
            $news_object = MT::Session->new();
            $news_object->set_values({id => 'NW',
                                      kind => 'NW',
                                      start => time(),
                                      data => $result});
            $news_object->save();
        }
        return $result;
    }
}

sub make_blog_list {
    my $app = shift;
    my ($blogs, $perms) = @_;

    require MT::TBPing;
    require MT::Entry;
    require MT::Comment;
    my $author = $app->user;
    my $can_edit_authors = $author->is_superuser;
    my $data;
    my $i;
    for my $blog (@$blogs) {
        my $blog_id = $blog->id;
        my $perms = $author->is_superuser
                    ? $author->blog_perm($blog_id) : $perms->{ $blog_id };
        $can_edit_authors = 1 if $perms->can_administer_blog;
        my $row = { id => $blog->id, name => encode_html($blog->name),
                    description => $blog->description,
                    site_url => $blog->site_url
                    };
        $row->{num_entries} = MT::Entry->count({ blog_id => $blog_id });
        $row->{num_comments} = MT::Comment->count({ blog_id => $blog_id,
                                                    junk_status => [ 0, 1 ] },
                                      { 'range_incl' => { 'junk_status' => 1 }});
        $row->{num_pings} = MT::TBPing->count({ blog_id => $blog_id,
            junk_status => [ 0, 1 ] },{ 'range_incl' => { 'junk_status' => 1 }});
        $row->{num_authors} = 0;
        my $iter = MT::Permission->load_iter({ blog_id => $blog_id });
        while (my $p = $iter->()) {
            $row->{num_authors}++ if ($p->can_post);
        }
        $row->{can_post} = $perms->can_post;
        $row->{can_edit_entries} = $perms->can_post|| $perms->can_edit_all_posts;
        $row->{can_edit_templates} = $perms->can_edit_templates;
        $row->{can_edit_config} = $perms->can_edit_config || $perms->can_administer_blog;
        $row->{can_administer_blog} = $perms->can_administer_blog;
        push @$data, $row;
    }
    return ($data, $can_edit_authors);
}

## Application methods

sub list_blogs {
    my $app = shift;
    my $q = $app->param;
    require MT::Blog;
    require MT::Permission;
    require MT::Entry;
    require MT::Comment;
    my $author = $app->user;
    my @perms = MT::Permission->load({ author_id => $author->id });
    my %perms = map { $_->blog_id => $_ } @perms;
    my %args;
    my $list_pref = $app->list_pref('main_menu');
    if ($list_pref->{'sort'} eq 'name') {
        $args{'sort'} = 'name';
    } elsif ($list_pref->{'sort'} eq 'created') {
        $args{'sort'} = 'id';
    } elsif ($list_pref->{'sort'} eq 'updated') {
        $args{'sort'} = 'children_modified_on';
    }
    if ($list_pref->{'order'} eq 'descend') {
        $args{'direction'} = 'descend';
    }
    $args{join} = ['MT::Permission', 'blog_id',
                   { author_id => $author->id,
                     role_mask => [1, undef] }, # don't count those with mask 0
                   { range_incl => {role_mask => 1} }];
    my @blogs = MT::Blog->load(undef, \%args);
    my %param = %$list_pref;
    my $i = 1;

    ($param{blog_loop}, $param{can_edit_authors}) = 
        $app->make_blog_list(\@blogs, \%perms);
    delete $param{blog_loop} unless ref $param{blog_loop};

    $param{can_create_blog} = $author->can_create_blog;
    $param{can_view_log} = $author->can_view_log;
    $param{saved_deleted} = $q->param('saved_deleted');
    if ($author->can_create_blog()) {
        $param{blog_count} = MT::Blog->count();
        $param{blog_count_plural} = $param{blog_count} != 1;
        $param{author_count} = MT::Author->count({type => AUTHOR});
        $param{author_count_plural} = $param{author_count} != 1;
        $param{can_view_blog_count} = 1;
    }

    $param{news_html} = $app->get_newsbox_content();
    $param{system_overview_nav} = 0;
    $param{quick_search} = 0;
    $param{no_breadcrumbs} = 1;
    $app->build_page('list_blog.tmpl', \%param);
}

sub list_pref {    # FIXME: Can the user manip. the cookie to modify $param arbitrarily?
    my $app = shift;
    my ($list) = @_;
    my $updating = $app->mode eq 'update_list_prefs';
    unless ($updating) {
        my $pref = $app->request("list_pref_$list");
        return $pref if defined $pref;
    }

    my $cookie = $app->cookie_val('mt_list_pref') || '';
    my $mode = $app->mode;
    # defaults:
    my $list_pref;
    if ($list eq 'main_menu') {
        $list_pref = { 'sort' => 'name', order => 'ascend', view => 'compact', dates => 'relative' };
    } else {
        $list_pref = { rows => 20, view => 'compact', bar => 'above', dates => 'relative' };
    }
    my @list_prefs = split /;/, $cookie;
    my $new_cookie = '';
    foreach my $pref (@list_prefs) {
        my ($name, $prefs) = $pref =~ m/^(\w+):(.*)$/;
        next unless $name && $prefs;
        if ($name eq $list) {
            my @prefs = split /,/, $prefs;
            foreach (@prefs) {
                my ($k, $v) = split /=/;
                $list_pref->{$k} = $v if exists $list_pref->{$k};
            }
        } else {
            $new_cookie .= ($new_cookie ne '' ? ';' : '') . $pref;
        }
    }

    if ($updating) {
        my $updated = 0;
        if (my $limit = $app->param('limit')) {
            $list_pref->{rows} = $limit eq 'none' ? $limit : ($limit > 0 ? $limit : 20);
            $updated = 1;
        }
        if (my $view = $app->param('verbosity')) {
            if ($view =~ m!^compact|expanded$!) {
                $list_pref->{view} = $view;
                $updated = 1;
            }
        }
        if (my $bar = $app->param('actions')) {
            if ($bar =~ m!^above|below|both$!) {
                $list_pref->{bar} = $bar;
                $updated = 1;
            }
        }
        if (my $ord = $app->param('order')) {
            if ($ord =~ m!^ascend|descend$!) {
                $list_pref->{order} = $ord;
                $updated = 1;
            }
        }
        if (my $sort = $app->param('sort')) {
            if ($sort =~ m!^name|created|updated$!) {
                $list_pref->{'sort'} = $sort;
                $updated = 1;
            }
        }
        if (my $dates = $app->param('dates')) {
            if ($dates =~ m!^relative|full$!) {
                $list_pref->{'dates'} = $dates;
                $updated = 1;
            }
        }

        if ($updated) {
            my @list_prefs;
            foreach (keys %$list_pref) {
                push @list_prefs, $_ . '=' . $list_pref->{$_};
            }
            my $prefs = join ',', @list_prefs;
            $new_cookie .= ($new_cookie ne '' ? ';' : '') . $list . ':' . $prefs;
            $app->bake_cookie(-name => 'mt_list_pref', -value => $new_cookie,
                -expires => '+10y');
        }
    }

    if ($list_pref->{rows}) {
        $list_pref->{"limit_" . $list_pref->{rows}} = $list_pref->{rows};
    }
    if ($list_pref->{view}) {
        $list_pref->{"view_" . $list_pref->{view}} = 1;
    }
    if ($list_pref->{dates}) {
        $list_pref->{"dates_" . $list_pref->{dates}} = 1;
    }
    if ($list_pref->{bar}) {
        if ($list_pref->{bar} eq 'both') {
            $list_pref->{"position_actions_both"} = 1;
            $list_pref->{"position_actions_top"} = 1;
            $list_pref->{"position_actions_bottom"} = 1;
        } elsif ($list_pref->{bar} eq 'below') {
            $list_pref->{"position_actions_bottom"} = 1;
        } elsif ($list_pref->{bar} eq 'above') {
            $list_pref->{"position_actions_top"} = 1;
        }
    }
    if ($list_pref->{'sort'}) {
        $list_pref->{'sort_' . $list_pref->{'sort'}} = 1;
    }
    if ($list_pref->{'order'}) {
        $list_pref->{'order_' . $list_pref->{'order'}} = 1;
    }
    $app->request("list_pref_$list", $list_pref);
}

sub system_list_blogs {
    my $app = shift;
    my $author = $app->user;
    my $list_pref = $app->list_pref('blog');

    my $limit = $list_pref->{rows};
    my $offset = $limit eq 'none' ? 0 : ($app->param('offset') || 0);
    my $args = { offset => $offset, sort => 'name' };
    $args->{limit} = $limit + 1 unless $limit eq 'none';
    unless ($author->is_superuser) {
        $args->{join} = ['MT::Permission', 'blog_id',
                         { author_id => $author->id }, { unique => 1 } ];
    }
    require MT::Blog;
    my %param = %$list_pref;
    my @blogs = MT::Blog->load(undef, $args);
    my @perms = MT::Permission->load({ author_id => $author->id });
    my %perms = map { $_->blog_id => $_ } @perms;
    my $can_edit_authors;
    ($param{blog_loop}, $can_edit_authors) = 
        $app->make_blog_list(\@blogs, \%perms);
    delete $param{blog_loop} unless ref $param{blog_loop};

    if ($param{blog_loop} && ($limit ne 'none')) {
        ## We tried to load $limit + 1 entries above; if we actually got
        ## $limit + 1 back, we know we have another page of entries.
        my $have_next = @{$param{blog_loop}} > $limit;
        pop @{$param{blog_loop}} while @{$param{blog_loop}} > $limit;
        if ($offset) {
            $param{prev_offset} = 1;
            $param{prev_offset_val} = $offset - $limit;
            $param{prev_offset_val} = 0 if $param{prev_offset_val} < 0;
        }
        if ($have_next) {
            $param{next_offset} = 1;
            $param{next_offset_val} = $offset + $limit;
        }
    }
    $param{object_type} = 'blog';
    $param{object_type_plural} = $app->translate('weblogs');
    $param{list_start} = $offset + 1;
    delete $args->{limit};
    delete $args->{offset};
    $param{list_total} = MT::Blog->count(undef, $args);
    $param{list_end} = $offset + (scalar @blogs);
    $param{next_max} = $param{list_total} - ($limit eq 'none' ? 0 : $limit);
    $param{next_max} = 0 if ($param{next_max} || 0) < $offset + 1;
    $param{can_create_blog} = $author->can_create_blog;
    $param{saved_deleted} = $app->param('saved_deleted');
    $param{nav_blogs} = 1;

    my $plugin_actions = $app->plugin_itemset_actions('blog');
    $param{plugin_itemset_action_loop} = $plugin_actions
        if $plugin_actions;
    my $core_actions = $app->core_itemset_actions('blog');
    $param{core_itemset_action_loop} = $core_actions
        if $core_actions;
    $param{has_itemset_actions} =
        ($plugin_actions || $core_actions) ? 1 : 0;

    $app->add_breadcrumb($app->translate("Weblogs"));
    $param{nav_weblogs} = 1;
    $app->build_page('system_list_blog.tmpl', \%param)
}

sub list_authors {
    my $app = shift;
    my $this_author = $app->user;
    my $this_author_id = $this_author->id;
    my $list_pref = $app->list_pref('author');
    my %param = %$list_pref;
    my $limit = $list_pref->{rows};
    my $offset = $limit eq 'none' ? 0 : ($app->param('offset') || 0);
    my $args = { offset => $offset, sort => 'name' };
    $args->{limit} = $limit + 1 if $limit ne 'none';
    my %author_entry_count;
    require MT::Entry;
    unless (MT::Object->driver->isa('MT::ObjectDriver::DBM')) {
        # Berkeley DB users don't get the count of entries per author
        my $author_entry_count_iter =
            MT::Entry->count_group_by(undef, {group => ['author_id']});
        while (my ($count, $author_id) = $author_entry_count_iter->()) {
            $author_entry_count{$author_id} = $count;
        }
    }
    $param{can_create_user} = $this_author->is_superuser; # really, "can_edit_authors" when it exists
    my $author_iter = MT::Author->load_iter({ type => MT::Author::AUTHOR() },
                                            $args);
    my (@data, %authors);
    while (my $au = $author_iter->()) {
        my $has_edit_access = $this_author->can_administer($au);
        #next unless $au->id == $this_author->id
        #    || $has_edit_access
        #    || $this_author->is_superuser(); # in spirit, "can_edit_users"
        my $row = $au->column_values;
        $row->{name} = '(unnamed)' if !$row->{name};
        $authors{$au->id} ||= $au;
        $row->{id} = $au->id;
        $row->{email} = '' unless $au->email =~ /@/;
        $row->{entry_count} = $author_entry_count{$au->id};
        $row->{is_me} = $au->id == $this_author_id;
        $row->{has_edit_access} = !$row->{is_me} &&
            ($this_author->is_superuser
                || ($row->{created_by} && $row->{created_by} == $this_author_id)
                || $has_edit_access);
        my $parent_author = $authors{$au->created_by} ||= MT::Author->load($au->created_by) if $au->created_by;
        $row->{created_by} = $parent_author->name if $parent_author;
        my ($last) = MT::Entry->load({author_id => $au->id},
                                     {'sort' => 'created_on',
                                      direction => 'descend',
                                      limit => 1});
        if ($last) {
            if (my $ts = $last->created_on) {
                $row->{last_entry_formatted} =
                    format_ts("%Y.%m.%d", $ts); 
                $row->{last_entry_time_formatted} =
                    format_ts("%Y-%m-%d %H:%M:%S", $ts); 
                $row->{last_entry_relative} =
                    relative_date($ts, time, $last->blog);
            }
        }
        push @data, $row;
        last if ($limit ne 'none') && (scalar @data == $limit);
    }
    $param{object_loop} = \@data;
    $param{object_type} = 'author';
    $param{object_type_plural} = $app->translate('authors');

    $param{limit} = $limit;
    $param{list_start} = $offset + 1;
    delete $args->{limit}; delete $args->{offset};
    $param{list_total} = MT::Author->count({ type => MT::Author::AUTHOR() }, $args);
    $param{list_end} = $offset + (scalar @data);
    $param{next_offset_val} = $offset + (scalar @data);
    $param{next_offset} = $param{next_offset_val} < $param{list_total} ? 1 : 0;
    $param{next_max} = $param{list_total} - ($limit eq 'none' ? 0 : $limit);
    $param{next_max} = 0 if ($param{next_max} || 0) < $offset + 1;
    if ($offset > 0) {
        $param{prev_offset} = 1;
        $param{prev_offset_val} = $offset - ($limit eq 'none' ? 0 : $limit);
        $param{prev_offset_val} = 0 if $param{prev_offset_val} < 0;
    }
    $param{saved_deleted} = $app->param('saved_deleted');

    $app->add_breadcrumb($app->translate("Authors"));
    $param{nav_authors} = 1;
    $app->build_page('list_author.tmpl', \%param)
}

sub bookmarklets {
    my $app = shift;
    $app->add_breadcrumb($app->translate('QuickPost'));
    $app->build_page('bookmarklets.tmpl');
}

sub make_bm_link {
    my $app = shift;
    my %param = ( have_link => 1 );
    my @show = $app->param('show');
    my $height = 440;
    s/[^\w]//g foreach @show; # non-word chars could be harmful
    my %show = map { $_ => 1 } @show;
    $height += 50 if $show{t};  # trackback
    $height += 40 if $show{ac}; # allow comments
    $height += 20 if $show{ap}; # allow pings
    $height += 40 if $show{cb}; # convert breaks
    $height += 50 if $show{c}; # category
    $height += 80 if $show{e}; # excerpt
    $height += 80 if $show{k}; # keywords
    $height += 80 if $show{'m'}; # more text
    $param{bm_show} = join ',', @show;
    $param{bm_height} = $height;
    $param{bm_js} = $app->_bm_js($param{bm_show}, $height);
    $app->add_breadcrumb($app->translate('QuickPost'));
    $app->build_page('bookmarklets.tmpl', \%param);
}

sub _bm_js {
    my $app = shift;
    my($show, $height) = @_;
    my %args = (is_bm => 1, bm_show => $show, '_type' => 'entry');
    my $uri = $app->base . $app->uri('mode' => 'view', args => \%args);
    qq!javascript:d=document;w=window;t='';if(d.selection)t=d.selection.createRange().text;else{if(d.getSelection)t=d.getSelection();else{if(w.getSelection)t=w.getSelection()}}void(w.open('$uri&link_title='+escape(d.title)+'&link_href='+escape(d.location.href)+'&text='+escape(t),'_blank','scrollbars=yes,width=400,height=$height,status=yes,resizable=yes,scrollbars=yes'))!;
}

sub view_log {
    my $app = shift;
    my $author = $app->user;
    my $blog_id = $app->param('blog_id');
    if ($blog_id) {
        return $app->error($app->translate("Permission denied."))
            unless $app->{perms}->can_view_blog_log;
    } else {
        return $app->error($app->translate("Permission denied."))
            unless $author->can_view_log;
    }
    require MT::Log;
    my $list_pref = $app->list_pref('log');
    my $limit = $list_pref->{rows};
    my $offset = $limit eq 'none' ? 0 : ($app->param('offset') || 0);
    my $arg = { $blog_id ? (blog_id => $blog_id) : () };
    my $cfg = $app->{cfg};
    my $iter = MT::Log->load_iter($arg,
        { ($cfg->ObjectDriver ne 'DBM' ?  # work around a flaw in DBM driver
           ('sort' => 'id') :
           ('sort' => 'created_on')),
           'direction' => 'descend',
          'offset' => $offset,
          $limit ne 'none' ? ('limit' => $limit) : () });
    my %param = ( %$list_pref );
    my $log = $app->build_log_table(iter => $iter, param => \%param);
    if ($blog_id) {
        my $so = $app->blog->server_offset;
        if ($so) {
            my $partial_hour_offset = 60 * abs($so - int($so));
            my $tz = sprintf("%s%02d:%02d", $so < 0 ? '-' : '+',
                abs($so), $partial_hour_offset);
            $param{time_offset} = $tz;
        }
    }
    $param{object_type} = 'log';
    $param{object_type_plural} = $app->translate('log records');
    $param{search_type} = $app->translate('Activity Log');
    $param{list_start} = $offset + 1;
    $param{list_total} = MT::Log->count($arg);
    $param{list_end} = $offset + (scalar @$log);
    $param{next_offset_val} = $offset + (scalar @$log);
    $param{next_offset} = $param{next_offset_val} < $param{list_total} ? 1 : 0;
    $param{next_max} = $param{list_total} - ($limit eq 'none' ? 0 : $limit);
    $param{next_max} = 0 if ($param{next_max} || 0) < $offset + 1;
    if ($offset > 0) {
        $param{prev_offset} = 1;
        $param{prev_offset_val} = $offset - ($limit eq 'none' ? 0 : $limit);
        $param{prev_offset_val} = 0 if $param{prev_offset_val} < 0;
    }
    $param{'reset'} = $app->param('reset');
    $param{nav_log} = 1;
    $app->add_breadcrumb($app->translate('Activity Log'));
    unless ($app->param('blog_id')) {
        $param{system_overview_nav} = 1;
    }
    $app->build_page('view_log.tmpl', \%param);
}

sub build_log_table {
    my $app = shift;
    my (%args) = @_;

    my $blog = $app->blog;
    my $blog_view = $blog ? 1 : 0;
    my $i = 1;
    my @log;
    my $iter;
    if ($args{load_args}) { 
        my $class = $app->_load_driver_for('log');
        $iter = $class->load_iter( @{ $args{load_args} } );
    } elsif ($args{iter}) {
        $iter = $args{iter};
    } elsif ($args{items}) {
        $iter = sub { pop @{ $args{items} } };
    }
    my $param = $args{param};
    my %blogs;
    while (my $log = $iter->()) {
        my $row = { log_message => $log->message, log_ip => $log->ip };
        if (my $ts = $log->created_on) {
            if ($blog_view) {
                $row->{created_on_formatted} = format_ts("%Y.%m.%d %H:%M:%S",
                    epoch2ts($blog, ts2epoch(undef, $ts)));
            } else {
                $row->{created_on_formatted} = format_ts("%Y.%m.%d %H:%M:%S",
                    $ts);
            }
            #my $blog = $blogs{$log->blog_id} = MT::Blog->load($log->blog_id)
            #    if $log->blog_id;
            $row->{created_on_relative} = relative_date($ts, time); #, $blog);
        }
        push @log, $row;
    }
    return [] unless @log;
    $param->{log_table}[0]{object_loop} = \@log;
    \@log;
}

sub reset_log {
    my $app = shift;
    my $author = $app->user;
    return $app->error($app->translate("Permission denied."))
        unless $author->can_view_log;
    $app->validate_magic() or return;
    require MT::Log;
    if (my $blog_id = $app->param('blog_id')) {
        my @obj = MT::Log->load({ blog_id => $blog_id });
        if (@obj) {
            $_->remove foreach @obj;
            $app->log($app->translate("Application log for blog '[_1]' reset by '[_2]' (user #[_3])", $blog_id, $author->name, $author->id));
        }
    } else {
        MT::Log->remove_all;
        $app->log($app->translate("Application log reset by '[_1]' (user #[_2])", $author->name, $author->id));
    }
    $app->add_return_arg('reset' => 1);
    $app->call_return;
}

sub export_log {
    my $app = shift;
    my $author = $app->user;
    my $perms = $app->{perms};
    my $blog = $app->blog;
    my $blog_view = $blog ? 1 : 0;
    if ($blog_view) {
        return $app->error($app->translate("Permission denied."))
            unless $author->can_view_log || ($perms && $perms->can_view_blog_log);
    } else {
        return $app->error($app->translate("Permission denied."))
            unless $author->can_view_log;
    }
    $app->validate_magic() or return;
    $| = 1;
    my $charset = $app->config('PublishCharset');
    my (%terms) = @_;
    if ($blog) {
        $terms{blog_id} = $blog->id;
    }
    require MT::Log;
    my $iter = MT::Log->load_iter(\%terms, { 'sort' => 'created_on', 'direction' => 'ascend' });
    my %blogs;


    my $file = '';
    $file = dirify($blog->name) . '-' if $blog;
    my @ts = gmtime(time);
    my $ts = sprintf "%04d-%02d-%02d-%02d-%02d-%02d",
        $ts[5]+1900, $ts[4]+1, @ts[3,2,1,0];
    $file .= "log_$ts.csv";
    $app->{no_print_body} = 1;
    $app->set_header("Content-Disposition" => "attachment; filename=$file");
    $app->send_http_header($charset ? "text/csv; charset=$charset"
                                    : 'text/csv');

    my $csv = "timestamp,ip,weblog,message\n";
    while (my $log = $iter->()) {
        # columns:
        # date, ip address, weblog, log message
        my @col;
        my $ts = $log->created_on;
        if ($blog_view) {
            push @col, format_ts("%Y-%m-%d %H:%M:%S",
                epoch2ts($blog, ts2epoch(undef, $ts)));
        } else {
            push @col, format_ts("%Y-%m-%d %H:%M:%S", $log->created_on);
        }
        push @col, $log->ip;
        if ($log->blog_id) {
            my $blog = $blogs{$log->blog_id} ||= MT::Blog->load($log->blog_id, {cached_ok=>1});
            my $name = $blog->name;
            $name =~ s/"/\\"/gs;
            $name =~ s/[\r\n]+/ /gs;
            push @col, '"' . $name . '"';
        } else {
            push @col, '';
        }
        my $msg = $log->message;
        $msg =~ s/"/\\"/gs;
        $msg =~ s/[\r\n]+/ /gs;
        push @col, '"' . $msg . '"';
        $csv .= (join ',', @col) . "\n";
        $app->print($csv);
        $csv = '';
    }
}

sub start_import {
    my $app = shift;
    my $blog_id = $app->param('blog_id');
    my %param;
    require MT::Category;
    my $iter = MT::Category->load_iter({ blog_id => $blog_id });
    my @data;
    while (my $cat = $iter->()) {
        push @data, { category_id => $cat->id,
                      category_label => $cat->label };
    }
    @data = sort { $a->{category_label} cmp $b->{category_label} }
            @data;
    $param{category_loop} = \@data;
    $param{nav_import} = 1;
    $param{can_edit_authors} = $app->{perms}->can_administer_blog;
    $app->add_breadcrumb($app->translate('Import/Export'));
    $app->build_page('import.tmpl', \%param);
}

sub show_admin {
    my $app = shift;
    my %param;
    $param{nav_admin} = 1;

    # System Stats

    require MT::Blog;
    $param{blog_count} = MT::Blog->count();

    # active author count: someone who has posted within 90 days
    require MT::Author;
    require MT::Entry;
    my $to = time + (60*60*24);
    my $from = time - (60*60*24*90 + 60*60*24);
    my $to_ts = epoch2ts(undef, $to);
    my $from_ts = epoch2ts(undef, $from);
    $param{active_author_count} = MT::Author->count( { type => MT::Author::AUTHOR() },
        { join => [ 'MT::Entry', 'author_id', { created_on => [ $from_ts, $to_ts ] }, { unique => 1, range_incl => { created_on => 1 } } ] } );

    $param{author_count} = MT::Author->count( { type => MT::Author::AUTHOR() });

    require MT::Entry;
    $param{entry_count} = MT::Entry->count();

    require MT::Comment;
    $param{comment_count} = MT::Comment->count( { junk_status => [0, 1] }, { range_incl => { junk_status => 1 } } );

    require MT::TBPing;
    $param{trackback_count} = MT::TBPing->count( { junk_status => [0, 1] }, { range_incl => { junk_status => 1 } } );

    $param{nav_info} = 1;
    $param{news_html} = $app->get_newsbox_content();
    $param{quick_search} = 0;
    $app->build_page('admin.tmpl', \%param);
}

sub show_status {
    my $app = shift;
    my %param;
    $param{nav_status} = 1;

    # System Stats

    require MT::Blog;
    $param{blog_count} = MT::Blog->count();

    # active author count: someone who has posted within 90 days
    require MT::Author;
    my $to = time;
    my $from = epoch2ts(undef, time - (60*60*24*90 + 1));
    $param{active_author_count} = MT::Author->count( { type => MT::Author::AUTHOR() },
        { join => [ 'MT::Entry', 'author_id', { created_on => [ $from, $to ] }, { unique => 1, range_incl => { created_on => 1 } } ] } );

    require MT::Author;
    $param{author_count} = MT::Author->count( { type => MT::Author::AUTHOR() });

    require MT::Entry;
    $param{entry_count} = MT::Entry->count();

    require MT::Comment;
    $param{comment_count} = MT::Comment->count( { junk_status => [0, 1] }, { range_incl => { junk_status => 1 } } );

    require MT::TBPing;
    $param{trackback_count} = MT::TBPing->count( { junk_status => [0, 1] }, { range_incl => { junk_status => 1 } } );

    $param{nav_info} = 1;
    $param{quick_search} = 0;
    $app->build_page('system_info.tmpl', \%param);
}

sub show_menu {
    my $app = shift;
    my $perms = $app->{perms}
        or return $app->error($app->translate("No permissions"));
    require MT::Comment;
    require MT::TBPing;
    require MT::Trackback;
    require MT::Permission;
    require MT::Entry;
    my $blog_id = $app->param('blog_id');
    my $iter = MT::Entry->load_iter({ blog_id => $blog_id },
        { 'sort' => 'created_on',
          direction => 'descend',
          limit => 5 });
    my @e_data;
    my $i = 1;
    my $author_id = $app->user->id;
    while (my $entry = $iter->()) {
        my $row = { entry_id => $entry->id,
                    entry_blog_id => $entry->blog_id, };
        $row->{entry_title} = $entry->title;
        unless (defined($row->{entry_title})) {
            my $title = remove_html($entry->text);
            $row->{entry_title} = substr($title||"", 0, 22) . '...';
        } else {
            $row->{entry_title} = substr($row->{entry_title}, 0, 22) . '...'
                if $row->{entry_title} && $row->{entry_title} =~ m(\S{22,});
        }
        $row->{entry_title} = encode_html($row->{entry_title}, 1);
        $row->{entry_created_on} = format_ts("%Y.%m.%d", $entry->created_on);
        $row->{has_edit_access} = $perms->can_edit_all_posts ||
            $entry->author_id == $author_id;
        push @e_data, $row;
    }
    $iter = MT::Comment->load_iter({ blog_id => $blog_id, junk_status => [ 0, 1 ] },
        { 'sort' => 'created_on',
          direction => 'descend',
          limit => 5, range_incl => { junk_status => 1 } });
    my @c_data;
    $i = 1;
    while (my $comment = $iter->()) {
        my $row = { comment_id => $comment->id,
                    comment_author => $comment->author,
                    comment_blog_id => $comment->blog_id, };
        $row->{comment_author} = substr($row->{comment_author}, 0, 22) . '...'
            if $row->{comment_author} && $row->{comment_author} =~ m(\S{22,});
        $row->{comment_created_on} = format_ts("%Y.%m.%d",
            $comment->created_on);
        if (my $entry = $comment->entry) {
            $row->{has_edit_access} = $perms->can_edit_all_posts ||
                $entry->author_id == $author_id;
        }
        push @c_data, $row;
    }
    $iter = MT::TBPing->load_iter({ blog_id => $blog_id, junk_status => [ 0, 1 ] },
        { 'sort' => 'created_on',
          direction => 'descend',
          limit => 5, range_incl => { junk_status => 1 } });
    my @p_data;
    $i = 1;
    while (my $ping = $iter->()) {
        my $row = { ping_id => $ping->id,
                    ping_title => $ping->title || '[No title]',
                    ping_url => $ping->source_url,
                    ping_blog_id => $ping->blog_id, };
        # FIXME: trim this shorter.
        $row->{ping_title} = substr($row->{ping_title}, 0, 22) . '...'
            if $row->{ping_title} =~ m(\S{22,});
        $row->{ping_created_on} = format_ts("%Y.%m.%d", $ping->created_on);
        my $tb = MT::Trackback->load($ping->tb_id);
        if ($tb->entry_id) {
            my $entry = MT::Entry->load($tb->entry_id);
            $row->{has_edit_access} = $perms->can_edit_all_posts ||
                $entry->author_id == $author_id;
            $row->{ping_entry_id} = $entry->id;
        }
        push @p_data, $row;
    }
    require MT::Blog;
    my $blog = MT::Blog->load($blog_id, {cached_ok=>1});
    my %param = (entry_loop => \@e_data, comment_loop => \@c_data,
                 ping_loop => \@p_data);
    require MT::Entry;
    my $future_entry = MT::Entry->load({blog_id => $blog_id,
                                        author_id => $author_id,
                                        status => MT::Entry::FUTURE()});
    if (defined($MT::PluginActions{'blog'})) {
        $param{plugin_action_loop} = $MT::PluginActions{'blog'};
    }
    $param{blog_description} = $blog->description;
    $param{welcome} = $blog->welcome_msg;
    $param{num_entries} = MT::Entry->count({ blog_id => $blog_id });
    $param{num_comments} = MT::Comment->count({ blog_id => $blog_id });
    $param{num_authors} = 0;
    $param{has_edit_access} = $perms->can_post || $perms->can_edit_all_posts;
    $iter = MT::Permission->load_iter({ blog_id => $blog_id });
    while (my $p = $iter->()) {
        $param{num_authors}++ if $p->can_post;
    }
    if ($blog->junk_folder_expiry) {
        $app->expire_junk($blog);
    }
    $app->build_page('menu.tmpl', \%param);
}


my %API = (
        author => 'MT::Author',
        commenter => 'MT::Author',
        comment => 'MT::Comment',
        entry   => 'MT::Entry',
        template => 'MT::Template',
        blog => 'MT::Blog',
        notification => 'MT::Notification',
        templatemap => 'MT::TemplateMap',
        category => 'MT::Category',
        banlist => 'MT::IPBanList',
        ping => 'MT::TBPing',
        ping_cat => 'MT::TBPing',
        log => 'MT::Log',
    );

sub edit_object {
    my $app = shift;
    my %param = $_[0] ? %{ $_[0] } : ();
    my $q = $app->param;
    my $type = $q->param('_type');
    return unless $API{$type};
    my $blog_id = $q->param('blog_id');
    my $id = $q->param('id');
    my $perms = $app->{perms};
    my $author = $app->user;
    my $cfg = $app->config;
    $param{styles} = '';
    return $app->error($app->translate("No permissions"))
        if !$perms && $id && $type ne 'author';

    MT->_register_core_callbacks({
        CMSViewPermissionFilter_blog => sub {
            my ($eh, $app, $id) = @_;
            if ( ($id && !$app->{perms}->can_edit_config) ||
                (!$id && !$app->user->can_create_blog)) {
                return 0;
            }
            1;
        },
        CMSViewPermissionFilter_template => sub {
            my ($eh, $app, $id) = @_;
            return !$id || $app->{perms}->can_edit_templates;
        },
        CMSViewPermissionFilter_entry => sub {
            my ($eh, $app, $id) = @_;
            if (!$id && !$app->param('is_bm') &&
                !$app->{perms}->can_post) {
                return 0;
            }
            my $obj = MT::Entry->load($id, {cached_ok=>1}) if $id;
            if ($id && !$app->{perms}->can_edit_entry($obj, $app->user)) {
                return 0;
            }
            1;
        },
        CMSViewPermissionFilter_author => sub {
            my ($eh, $app, $id) = @_;
            return $id && ($app->user->id == $id);
        },
        CMSViewPermissionFilter_category => sub {
            my ($eh, $app, $id) = @_;
            return $app->{perms}->can_edit_categories();
        },
        CMSViewPermissionFilter_commenter => sub {
            my $eh = shift;
            my ($app, $id) = @_;
            my $auth = MT::Author->load( { id => $id, 
                                           type => MT::Author::COMMENTER });
            $auth ? 1 : 0;
        },
        CMSViewPermissionFilter_comment => sub {
            my $eh = shift;
            my ($app, $id, $objp) = @_;
            return 0 unless ($id);
            $objp->force() or return 0;
            require MT::Entry;
            my $entry = MT::Entry->load($objp->force()->entry_id, {cached_ok=>1})
                or return 0;
            if (!($entry->author_id == $app->user->id
                  || $app->{perms}->can_edit_all_posts)) {
                return 0;
            }
            1;
        },
        CMSViewPermissionFilter_ping => sub {
            my $eh = shift;
            my ($app, $id, $objp) = @_;
            $objp->force() or return 0;
            require MT::Trackback;
            my $tb = MT::Trackback->load($objp->force->tb_id, {cached_ok=>1});
            if ($tb) {
                if ($tb->entry_id) {
                    require MT::Entry;
                    my $entry = MT::Entry->load($tb->entry_id, {cached_ok=>1});
                    return ($entry->author_id == $app->user->id
                            || $app->{perms}->can_edit_all_posts);
                } elsif ($tb->category_id) {
                    require MT::Category;
                    my $cat = MT::Category->load($tb->category_id,{cached_ok=>1});
                    return $cat && $app->{perms}->can_edit_categories;
                }
            } else {
                return 0;   # no TrackBack center--no edit
            }
        }        
    });

    my $class = $app->_load_driver_for($type) or return;
    my $cols = $class->column_names;
    require MT::Promise;
    my $obj_promise = MT::Promise::delay(sub {
        return $class->load($id) || undef;
    });

    if (!$author->is_superuser) {
        MT->run_callbacks('CMSViewPermissionFilter_' . $type,
                          $app, $id, $obj_promise)
            || return $app->error($app->translate("Permission denied. ")
                                  . MT->errstr());
    }
    my $obj;
    my $blog;
    require MT::Blog;
    if ($blog_id) {
        $blog = MT::Blog->load($blog_id, {cached_ok=>1});
    }

    if ($id) {          # object exists, we're just editing it.
        # Stash the object itself so we don't have to keep forcing the promise
        $obj = $obj_promise->force() or
            return $app->error($app->translate("Load failed: [_1]",
                $class->errstr || "(no reason given)"));
        # Populate the param hash with the object's own values
        for my $col (@$cols) {
            $param{$col} = defined $q->param($col) ?
                $q->param($col) : $obj->$col();
        }
        # Set type-specific display parameters
        if ($type eq 'entry') {
            $param{nav_entries} = 1;
            $param{entry_edit} = 1;
            $app->add_breadcrumb($app->translate('Entries'),
                                 $app->uri( 'mode' => 'list_entries',
                                     args => { blog_id => $blog_id }));
            $app->add_breadcrumb($obj->title || $app->translate('(untitled)'));
            ## Don't pass in author_id, because it will clash with the
            ## author_id parameter of the author currently logged in.
            delete $param{'author_id'};
            delete $param{'category_id'};
            if (my $cat = $obj->category) {
                $param{category_id} = $cat->id;
            }
            $blog_id = $obj->blog_id;
            my $status = $q->param('status') || $obj->status;
            $param{"status_" . MT::Entry::status_text($status)} = 1;
            $param{"allow_comments_" . ($q->param('allow_comments')
                                        || $obj->allow_comments || 0)} = 1;
            my $df = $q->param('created_on_manual') ||
                format_ts("%Y-%m-%d %H:%M:%S", $obj->created_on);
            $param{'created_on_formatted'} = $df;
            my $comments = $obj->comments;
            my @c_data;
            my $i = 1;
            @$comments = grep { $_->junk_status > -1 } @$comments;
            @$comments = sort { $a->created_on cmp $b->created_on }
                         @$comments;
            my $c_data = $app->build_comment_table( items => $comments, param => \%param );
            $param{num_comment_rows} = @$c_data + 3;
            $param{num_comments} = @$c_data;
            $param{can_send_notifications} = $perms->can_send_notifications;

            ## Load list of trackback pings sent for this entry.
            require MT::Trackback;
            require MT::TBPing;
            my $tb = MT::Trackback->load({ entry_id => $obj->id });
            my $tb_data;
            if ($tb) {
                my $iter = MT::TBPing->load_iter({ tb_id => $tb->id,
                    'junk_status' => [ 0, 1 ] },
                    { 'sort' => 'created_on',
                      direction => 'descend',
                      'range_incl' => { 'junk_status' => 1 } });
                $tb_data = $app->build_ping_table( iter => $iter, param => \%param );
            } else {
                $tb_data = [];
            }
            $param{num_ping_rows} = @$tb_data + 3;
            $param{num_pings} = @$tb_data;

            $param{show_pings_tab} = @$tb_data || $obj->allow_pings;
            $param{show_comments_tab} = @$c_data || $obj->allow_comments;

            ## Load next and previous entries for next/previous links
            if (my $next = $obj->next) {
                $param{next_entry_id} = $next->id;
            }
            if (my $prev = $obj->previous) {
                $param{previous_entry_id} = $prev->id;
            }

            $param{ping_errors} = $q->param('ping_errors');
            $param{can_view_log} = $app->user->can_view_log;

            $param{"tab_" . ($app->param('tab') || 'entry')} = 1;
            $param{entry_permalink} = $obj->permalink;
            $param{'mode_view_entry'} = 1;
            $param{'basename_old'} = $obj->basename;

            my $plugin_actions = $app->plugin_itemset_actions($type);
            $param{plugin_itemset_action_loop} = $plugin_actions
                if $plugin_actions;
            $param{plugin_itemset_action_loop} = []
                if !$plugin_actions;
            # disabling for now since the existing core actions aren't terribly
            # useful on for edit entry screen.
            #my $core_actions = $app->core_itemset_actions($type);
            #$param{core_itemset_action_loop} = $core_actions
            #    if $core_actions;
            my $core_actions;
            $param{has_itemset_actions} =
                ($plugin_actions || $core_actions) ? 1 : 0;
        } elsif ($type eq 'category') {
            $param{nav_categories} = 1;
            $app->add_breadcrumb($app->translate('Categories'),
                                 $app->uri( 'mode' => 'list_cat',
                                     args => { blog_id => $obj->blog_id }));
            $app->add_breadcrumb($obj->label);
            require MT::Trackback;
            my $tb = MT::Trackback->load({ category_id => $obj->id });
            if ($tb) {
                my $path = $app->config('CGIPath');
                $path .= '/' unless $path =~ m!/$!;
                my $script = $app->config('TrackbackScript');
                $param{tb_url} = $path . $script . '/' . $tb->id;
                if ($param{tb_passphrase} = $tb->passphrase) {
                    $param{tb_url} .= '/' .
                        encode_url($param{tb_passphrase});
                }
            }
        } elsif ($type eq 'template') {
            $param{nav_templates} = 1;
            my $tab;
            if ($obj->type eq 'index') {
                $tab = 'index';
            } elsif ($obj->type eq 'archive' || $obj->type eq 'individual' || $obj->type eq 'category') {
                $tab = 'archive';
            } elsif ($obj->type eq 'custom') {
                $tab = 'module';
            } else {
                $tab = 'system';
            }
            $app->add_breadcrumb($app->translate('Templates'),
                        $app->uri( 'mode' => 'list', args => {
                            '_type' => 'template',
                            'blog_id' => $obj->blog_id,
                            'tab' => $tab }));
            $app->add_breadcrumb($obj->name);
            $blog_id = $obj->blog_id;
            $param{has_name} = $obj->type eq 'index' ||
                               $obj->type eq 'custom' ||
                               $obj->type eq 'archive' ||
                               $obj->type eq 'category' ||
                               $obj->type eq 'individual';
            $param{has_outfile} = $obj->type eq 'index';
            $param{has_rebuild} = $obj->type eq 'index';
            $param{custom_dynamic} = ($blog->custom_dynamic_templates||"") 
                                       eq 'custom';
            $param{has_build_options} = ($param{custom_dynamic}
                                          || $param{has_rebuild});
            $param{is_special} = $param{type} ne 'index'
                                 && $param{type} ne 'archive'
                                 && $param{type} ne 'category'
                                 && $param{type} ne 'individual';
            $param{has_build_options} = $param{has_build_options}
                                         && $param{type} ne 'custom'
                                         && ! $param{is_special};
            $param{rebuild_me} = defined $obj->rebuild_me ?
                $obj->rebuild_me : 1;
            $param{search_type} = $app->translate('Templates');
            $param{object_type} = 'template';
        } elsif ($type eq 'blog') {
            require MT::IPBanList;
            my $output = $param{output} || '';
            $param{need_full_rebuild} = 1 if $q->param('need_full_rebuild');
            $param{need_index_rebuild} = 1 if $q->param('need_index_rebuild');
            $param{show_ip_info} = MT::IPBanList->count({'blog_id' => $id});
            if ($output eq 'cfg_prefs.tmpl') {
                $app->add_breadcrumb($app->translate('General Settings'));
                $param{global_sanitize_spec} = $cfg->GlobalSanitizeSpec;
                $param{'sanitize_spec_' . ($obj->sanitize_spec ? 1 : 0)} = 1;
                $param{sanitize_spec_manual} = $obj->sanitize_spec
                    if $obj->sanitize_spec;
                $param{words_in_excerpt} = 40
                    unless defined $param{words_in_excerpt} &&
                    $param{words_in_excerpt} ne '';
                $param{'sort_order_comments_' . ($obj->sort_order_comments || 0)} = 1;
                $param{'sort_order_posts_' . ($obj->sort_order_posts || 0)} = 1;
                my $lang = $obj->language || 'en';
                $lang = 'en' if lc($lang) eq 'en-us' || lc($lang) eq 'en_us';
                $param{'language_' . $lang} = 1;
                if ($obj->cc_license) {
                    $param{cc_license_name} = MT::Util::cc_name($obj->cc_license);
                    $param{cc_license_image_url} = MT::Util::cc_image($obj->cc_license);
                    $param{cc_license_url} = MT::Util::cc_url($obj->cc_license);
                }
                my $entries_on_index = ($obj->entries_on_index || 0);
                if ($entries_on_index) {
                    $param{'list_on_index'} = $entries_on_index;
                    $param{'posts'} = 1;
                } else {
                    $param{'list_on_index'} = ($obj->days_on_index || 0);
                    $param{'days'} = 1;
                }
            } elsif ($output eq 'cfg_feedback.tmpl') {
                $app->add_breadcrumb($app->translate('Feedback Settings'));
                $param{system_allow_comments} = $cfg->AllowComments;
                $param{system_allow_pings} = $cfg->AllowPings;
                my $threshold = $obj->junk_score_threshold || 0;
                $threshold = '+' . $threshold if $threshold > 0;
                $param{junk_score_threshold} = $threshold;
                $param{tk_available} = eval { require MIME::Base64; 1; }
                                    && eval { require LWP::UserAgent; 1 };
                $param{email_new_comments_1} = ($obj->email_new_comments || 0) == 1;
                $param{email_new_comments_2} = ($obj->email_new_comments || 0) == 2;
                $param{email_new_pings_1} = ($obj->email_new_pings || 0) == 1;
                $param{email_new_pings_2} = ($obj->email_new_pings || 0) == 2;
                $param{junk_folder_expiry} = $obj->junk_folder_expiry || 60;
                $param{auto_delete_junk} = $obj->junk_folder_expiry;
                $param{'auto_approve_commenters'} =
                            !$obj->manual_approve_commenters;
                $param{identity_system} = $app->config('IdentitySystem');
                # FIXME: use $app->uri, or whatever, below
                $param{handshake_return} = ($app->config('CGIPath')
                                          . $app->config('AdminScript'));
                $param{"moderate_comments"} = $obj->moderate_unreg_comments;
                $param{"moderate_comments_" . ($obj->moderate_unreg_comments || 0)} = 1;
                $param{"moderate_pings_" . ($obj->moderate_pings || 0 )} = 1;
            } elsif ($output eq 'cfg_entries.tmpl') {
                $app->add_breadcrumb($app->translate('New Entry Default Settings'));
                $param{system_allow_comments} = $cfg->AllowComments && ($blog->allow_reg_comments || $blog->allow_unreg_comments);
                $param{system_allow_pings} = $cfg->AllowPings && $blog->allow_pings;
                $param{system_allow_selected_pings} = $cfg->OutboundTrackbackLimit eq 'selected';
                $param{system_allow_outbound_pings} = $cfg->OutboundTrackbackLimit eq 'any';
                $param{system_allow_local_pings} = ($cfg->OutboundTrackbackLimit eq 'local') || ($cfg->OutboundTrackbackLimit eq 'any');
                $param{'status_default_' . $obj->status_default} = 1 if
                    $obj->status_default;
                $param{'allow_comments_default_' . ($obj->allow_comments_default||0)} = 1;
            } elsif ($output eq 'cfg_archives.tmpl') {
                $app->add_breadcrumb($app->translate('Publishing Settings'));
                if ($obj->column('archive_path') || $obj->column('archive_url')) {
                    $param{enable_archive_paths} = 1;
                    $param{archive_path} = $obj->column('archive_path'); 
                    $param{archive_url} = $obj->column('archive_url'); 
                } else {
                    $param{archive_path} = '';
                    $param{archive_url} = '';
                }
                $param{'archive_type_preferred_' .
                       $blog->archive_type_preferred} = 1 if
                       $blog->archive_type_preferred;
                my $at = $blog->archive_type;
                if ($at && $at ne 'None') {
                    my @at = split /,/, $at;
                    for my $at (@at) {
                        $param{'archive_type_' . $at} = 1;
                    }
                }
            } elsif ($output eq 'list_plugin.tmpl') {

                $app->add_breadcrumb($app->translate('Plugin Settings'));
                my @data;
                my $next_is_first = 1;
                my $plugin_id = 1;
                my $icon = $app->static_path . 'images/plugin.gif';
                for my $plugin (@MT::Plugins) {
                    my $plugin_sig = $plugin->{plugin_sig};
                    my $profile = $MT::Plugins{$plugin_sig};
                    my ($snip_tmpl, $config_html);
                    my %param;
                    my $settings = $plugin->get_config_obj('blog:'. $blog_id);
                    $plugin->load_config(\%param, 'blog:' . $blog_id);
                    next unless $snip_tmpl = $plugin->config_template(\%param, 'blog');
                    my $plugin_name = remove_html($plugin->name());
                    $plugin->{description} = $plugin->{description};
                    (my $cgi_path = $app->config('AdminCGIPath') || $app->config('CGIPath')) =~ s|/$||;
                    my $plugin_page = ($cgi_path . '/' 
                                       . $plugin->envelope . '/'
                                       . $plugin->config_link())
                        if $plugin->{config_link};

                    my $tmpl;
                    if (ref $snip_tmpl ne 'HTML::Template') {
                        require HTML::Template;
                        $tmpl = HTML::Template->new(scalarref => ref $snip_tmpl ? $snip_tmpl : \$snip_tmpl,
                                                    die_on_bad_params => 0,
                                                    loop_context_vars => 1);
                    } else {
                        $tmpl = $snip_tmpl;
                    }
                    $config_html = $app->build_page_in_mem($tmpl, \%param);
                    my $row = {
                        first => $plugin_id == 1,
                        plugin_name => $plugin_name,
                        plugin_page => $plugin_page,
                        plugin_major => 1,
                        plugin_icon => $icon,
                        plugin_desc => $plugin->description(),
                        plugin_version => $plugin->version(),
                        plugin_author_name => $plugin->author_name(),
                        plugin_author_link => $plugin->author_link(),
                        plugin_plugin_link => $plugin->plugin_link(),
                        plugin_full_path => $plugin->{full_path},
                        plugin_doc_link => $plugin->doc_link(),
                        plugin_sig => $plugin->{plugin_sig},
                        plugin_key => $plugin->key(),
                        plugin_config_link => $plugin->config_link(),
                        plugin_config_html => $config_html,
                        plugin_settings_id => $settings->id,
                        plugin_id => $plugin_id++,
                    };
                    $row->{plugin_tags} = listify($profile->{tags}) if $profile->{tags};
                    $row->{plugin_attributes} = listify($profile->{attributes})
                        if $profile->{attributes};
                    $row->{plugin_junk_filters} = listify($profile->{junk_filters})
                        if $profile->{junk_filters};
                    $row->{plugin_text_filters} = listify($profile->{text_filters})
                        if $profile->{text_filters};
                    if ($profile->{text_filters} || $profile->{junk_filters}
                        || $profile->{tags} || $profile->{attributes}) {
                        $row->{plugin_resources} = 1;
                    }
                    push @data, $row;
                }
                $param{can_config} = 1;
                $param{plugin_loop} = \@data;
            } else {
                $app->add_breadcrumb($app->translate('General Settings'));
            }
            (my $offset = $obj->server_offset) =~ s![-\.]!_!g;
            $offset =~ s!_00$!!;
            $param{'server_offset_' . $offset} = 1;
            if ($output eq 'cfg_feedback.tmpl' || $output eq 'cfg_entries.tmpl') {
                ## Load text filters.
                my $filters = MT->all_text_filters;
                my $default_entries = $obj->convert_paras;
                my $default_comments = $obj->convert_paras_comments;
                if ($default_entries eq '1') {
                    $default_entries = '__default__';
                }
                if ($default_comments eq '1') {
                    $default_comments = '__default__';
                }
                $param{text_filters} = [];
                $param{text_filters_comments} = [];
                for my $filter (keys %$filters) {
                    my $row = {
                        filter_key => $filter,
                        filter_label => $filters->{$filter}{label},
                    };
                    my $rowc = { %$row };
                    $row->{filter_selected} = $filter eq $default_entries;
                    $rowc->{filter_selected} = $filter eq $default_comments;
                    push @{ $param{text_filters} }, $row;
                    push @{ $param{text_filters_comments} }, $rowc;
                }
                $param{text_filters} = [
                    sort { $a->{filter_key} cmp $b->{filter_key} }
                    @{ $param{text_filters} } ];
                unshift @{ $param{text_filters} }, {
                    filter_key => '0',
                    filter_label => $app->translate('None'),
                    filter_selected => !$default_entries,
                };
                unshift @{ $param{text_filters_comments} }, {
                    filter_key => '0',
                    filter_label => $app->translate('None'),
                    filter_selected => !$default_entries,
                };
            }
            $param{nav_config} = 1;

        } elsif ($type eq 'ping') {
            $param{nav_trackbacks} = 1;
            $app->add_breadcrumb($app->translate('TrackBacks'),
                $app->uri('mode' => 'list_pings', args => { blog_id => $blog_id }));
            $app->add_breadcrumb('Edit TrackBack');
            $param{approved} = $app->param('approved');
            $param{unapproved} = $app->param('unapproved');
            require MT::Trackback;
            if (my $tb = MT::Trackback->load($obj->tb_id, {cached_ok=>1})) {
                if ($tb->entry_id) {
                    $param{entry_ping} = 1;
                    require MT::Entry;
                    if (my $entry = MT::Entry->load($tb->entry_id, {cached_ok=>1})) {
                        $param{entry_title} = $entry->title;
                        $param{entry_id} = $entry->id;
                    }
                } elsif ($tb->category_id) {
                    $param{category_ping} = 1;
                    require MT::Category;
                    if (my $cat = MT::Category->load($tb->category_id, {cached_ok=>1})) {
                        $param{category_id} = $cat->id;
                        $param{category_label} = $cat->label;
                    }
                }
            }

            $param{"ping_approved"} = $obj->is_published or
                $param{"ping_pending"} = $obj->is_moderated or
                $param{"is_junk"} = $obj->is_junk;

            ## Load next and previous entries for next/previous links
            if (my $next = $obj->next) {
                $param{next_ping_id} = $next->id;
            }
            if (my $prev = $obj->previous) {
                $param{previous_ping_id} = $prev->id;
            }
            my $parent = $obj->parent;
            if (ref $parent eq 'MT::Entry') {
                if ($parent->status == MT::Entry::RELEASE()) {
                    $param{entry_permalink} = $parent->permalink;
                }
            }

            if ($obj->junk_log) {
                $app->build_junk_table(param => \%param, object => $obj);
            }

            $param{created_on_time_formatted} =
                format_ts("%Y-%m-%d %H:%M:%S", $obj->created_on());
            $param{created_on_day_formatted} =
                format_ts("%Y.%m.%d", $obj->created_on());

            $param{search_type} = $app->translate('TrackBacks');
            $param{object_type} = 'ping';

            # since MT::App::build_page clobbers it:
            $param{source_blog_name} = $param{blog_name};
        } elsif ($type eq 'comment') {
            $param{nav_comments} = 1;
            $app->add_breadcrumb($app->translate('Comments'),
               $app->uri('mode' => 'list_comments', args => { blog_id => $blog_id }));
            $app->add_breadcrumb($app->translate('Edit Comment'));
            if (my $entry = $obj->entry) {
                $param{entry_title} = $entry->title || $entry->text || "";
                $param{entry_title} = substr($param{entry_title}, 0, 25) . '...'
                    if $param{entry_title} && $param{entry_title} =~ m(\S{25,});
                $param{entry_permalink} = $entry->permalink;
            } else {
                $param{no_entry} = 1;
            }
            $param{comment_approved} = $obj->is_published or
                $param{comment_pending} = $obj->is_moderated or
                $param{is_junk} = $obj->is_junk;

            $param{created_on_time_formatted} =
                format_ts("%Y-%m-%d %H:%M:%S", $obj->created_on());
            $param{created_on_day_formatted} =
                format_ts("%Y.%m.%d", $obj->created_on());

            $param{approved} = $app->param('approved');
            $param{unapproved} = $app->param('unapproved');
            $param{is_junk} = $obj->is_junk;

            ## Load next and previous entries for next/previous links
            if (my $next = $obj->next) {
                $param{next_comment_id} = $next->id;
            }
            if (my $prev = $obj->previous) {
                $param{previous_comment_id} = $prev->id;
            }
            if ($obj->junk_log) {
                $app->build_junk_table(param => \%param, object => $obj);
            }

            my $perm = MT::Permission->load({author_id => $obj->commenter_id,
                                             blog_id => $obj->blog_id});
            if ($perm) {
                $param{commenter_approved} = ($perm->can_comment()
                                              && !$perm->can_not_comment()
                                               ? 1 : undef);
                $param{commenter_banned} = ($perm->can_not_comment()
                                               ? 1 : undef);
            }
            if ($obj->commenter_id) {
                if ($obj->email !~ m/@/) {  # no email for this commenter
                    $param{email_withheld} = 1;
                }
            }
            $param{invisible_unregistered} = !$obj->visible &&
                                             !$obj->commenter_id;

            $param{search_type} = $app->translate('Comments');
            $param{object_type} = 'comment';

        } elsif ($type eq 'author') {
            # TBD: Populate permissions / blogs for this user
            # populate blog_loop, permission_loop

            # General permissions...
            $param{can_create_blog} = $obj->can_create_blog;
            $param{can_view_log} = $obj->can_view_log;
            require MT::Permission;
            my $all_perms = MT::Permission->perms;
            my @perms = MT::Permission->load( { 'author_id' => $id } );
            my @blogs;
            my %perms;
            if (@perms) {
                foreach my $perm (@perms) {
                    my $blog = MT::Blog->load( $perm->blog_id, {cached_ok=>1} );
                    push @blogs, $blog;
                    $perms{$perm->blog_id} = $perm;
                }
            }
            #@blogs = sort { $_->name } @blogs;
            my @blog_loop;
            foreach my $blog (@blogs) {
                my $perm = $perms{$blog->id};
                if ($perm && $perm->role_mask) {
                    my @p_data;
                    for my $ref (@$all_perms) {
                        next if $ref->[1] =~ /comment/;
                        my $meth = 'can_' . $ref->[1];
                        push @p_data, { have_access => $perm->$meth(),
                                        prompt => $app->translate($ref->[2]),
                                        blog_id => $blog->id,
                                        author_id => $id,
                                        mask => $ref->[0] };
                    }
                    push @blog_loop, {
                        blog_id => $blog->id,
                        blog_name => $blog->name,
                        permission_loop => \@p_data,
                    };
                }
            }
            @blog_loop = sort { $a->{blog_name} cmp $b->{blog_name} } @blog_loop;
            $param{blog_loop} = \@blog_loop;
        } elsif ($type eq 'commenter') {
            $app->add_breadcrumb($app->translate("Authenticated Commenters"),
                $app->uri(mode => 'list_commenters',
                          args => { blog_id => $blog_id }));
            $app->add_breadcrumb($app->translate("Commenter Details"));
            my $tab = $q->param('tab') || 'commenter';
            # populate the comments / junk comments for this user
            $param{'mode_view_commenter'} = 1;
            if ($tab eq 'commenter') {
                # we need itemset actions for commenters
                my $plugin_actions = $app->plugin_itemset_actions('commenter');
                $param{plugin_itemset_action_loop} = $plugin_actions
                    if $plugin_actions;
                #my $core_actions = $app->core_itemset_actions('commenter');
                #$param{core_itemset_action_loop} = $core_actions
                #    if $core_actions;
                # no native actions for this screen.
                $param{has_itemset_actions} =
                    ($plugin_actions) ? 1 : 0;
                $param{is_email_hidden} = $obj->is_email_hidden;
                $param{status} = {PENDING => "pending",
                                  APPROVED => "approved",
                                  BANNED => "banned"}->{$obj->status($blog_id)};
                $param{commenter_approved} = $obj->status($blog_id) == APPROVED;
                $param{commenter_banned} = $obj->status($blog_id) == BANNED;
                $param{profile_page} = $app->config('IdentityURL');
                $param{profile_page} .= "/" unless $param{profile_page} =~ m|/$|;
                $param{profile_page} .= $obj->name();
            } else {
                my $list_pref = $app->list_pref('comment');
                %param = (%param, %$list_pref);
                my $limit = $list_pref->{rows};
                my $offset = $q->param('offset') || 0;
                my (%terms, %arg);
                $terms{commenter_id} = $id;
                if ($tab eq 'comments') {
                    $terms{junk_status} = [ 0, 1 ];
                    $arg{range_incl} = { junk_status => 1 };
                } elsif ($tab eq 'junk') {
                    $terms{junk_status} = -1;
                }
                $arg{offset} = $offset if $offset;
                require MT::Comment;
                my $iter = MT::Comment->load_iter(\%terms, \%arg);
                my $loop = $app->build_comment_table( iter => $iter,
                    param => \%param );
                if ($limit ne 'none') {
                    ## We tried to load $limit + 1 entries above; if we actually got
                    ## $limit + 1 back, we know we have another page of entries.
                    my $have_next = @$loop > $limit;
                    pop @$loop while @$loop > $limit;
                    if ($offset) {
                        $param{prev_offset} = 1;
                        $param{prev_offset_val} = $offset - $limit;
                        $param{prev_offset_val} = 0 if $param{prev_offset_val} < 0;
                    }
                    if ($have_next) {
                        $param{next_offset} = 1;
                        $param{next_offset_val} = $offset + $limit;
                    }
                }
                $param{limit} = $limit;
                $param{offset} = $offset;
                $param{object_type} = 'comment';
                $param{object_type_plural} = $app->translate('comments');
                $param{search_type} = $app->translate('Comments');
                $param{list_start} = $offset + 1;
                $param{list_end} = $offset + scalar @$loop;
                delete $arg{limit}; delete $arg{offset};
                $param{list_total} = MT::Comment->count(\%terms, \%arg);
                if ($param{list_total}) {
                    $param{next_max} = $param{list_total} - ($limit eq 'none' ? 0 : $limit);
                    $param{next_max} = 0 if ($param{next_max} || 0) < $offset + 1;
                }
                # These are stubs for the commenter-scoped itemset references
                $param{plugin_itemset_action_loop} = [];
                $param{core_itemset_action_loop} = [];
            }
            $param{"tab_$tab"} = 1;
        }
        $param{new_object} = 0;
    } else {                                        # object is new
        $param{new_object} = 1;
        for my $col (@$cols) {
            $param{$col} = $q->param($col);
        }
        if ($type eq 'entry') {
            $param{entry_edit} = 1;
            if ($blog_id) {
                $app->add_breadcrumb($app->translate('Entries'), 
                     $app->uri('mode' => 'list_entries', args => { blog_id => $blog_id }));
                $app->add_breadcrumb($app->translate('New Entry'));
                $param{nav_new_entry} = 1;
            }
            # (if there is no blog_id parameter, this is a
            # bookmarklet post and doesn't need breadcrumbs.)
            delete $param{'author_id'};
            delete $param{'pinged_urls'};
            my $blog_timezone = 0;
            if ($blog_id) {
                my $blog = MT::Blog->load($blog_id, {cached_ok=>1});
                $blog_timezone = $blog->server_offset();
                my $def_status = $q->param('status') ||
                                 $blog->status_default;
                if ($def_status) {
                    $param{"status_" . MT::Entry::status_text($def_status)}
                        = 1;
                }
                $param{'allow_comments_' . 
                       (defined $q->param('allow_comments')
                         ? $q->param('allow_comments')
                         : $blog->allow_comments_default)} = 1;
                $param{allow_comments} = $blog->allow_comments_default
                    unless defined $q->param('allow_comments');
                $param{allow_pings} = $blog->allow_pings_default
                    unless defined $q->param('allow_pings');
            }

            require POSIX;
            $param{created_on_formatted} = $q->param('created_on_manual')
                           || POSIX::strftime("%Y-%m-%d %H:%M:%S", 
                                       offset_time_list(time, $blog));
            if ($q->param('is_bm')) {
                $param{selected_text} = $param{text};
                $param{text} = sprintf qq(<a title="%s" href="%s">%s</a>\n\n%s),
                    scalar $q->param('link_title'),
                    scalar $q->param('link_href'),
                    scalar $q->param('link_title'),
                    $param{text};

                my $show = $q->param('bm_show') || '';
                if ($show =~ /\b(trackback|t)\b/) {
                    $param{show_trackback} = 1;
                    ## Now fetch original page and scan it for embedded
                    ## TrackBack RDF tags.
                    my $url = $q->param('link_href');
                    if (my $items = MT::Util::discover_tb($url, 1)) {
                        if (@$items == 1) {
                            $param{to_ping_urls} = $items->[0]->{ping_url};
                        } else {
                            $param{to_ping_url_loop} = $items;
                        }
                    }
                }

                # This is needed for the QuickPost entry screen.
                require MT::Permission;
                my $iter = MT::Permission->load_iter({ author_id =>
                    $app->user->id });
                my @data;
                while (my $perms = $iter->()) {
                    next unless $perms->can_post;
                    my $blog = MT::Blog->load($perms->blog_id, {cached_ok=>1});
                    next unless $blog;
                    push @data, { blog_id => $blog->id,
                                  blog_name => $blog->name,
                                  blog_convert_breaks => $blog->convert_paras,
                                  blog_status => $blog->status_default,
                                  blog_allow_comments =>
                                      $blog->allow_comments_default,
                                  blog_allow_pings =>
                                      $blog->allow_pings_default,
                                  blog_basename_limit => $blog->basename_limit || 30 };
                    # populate category
                    $param{avail_blogs}{$blog->id} = 1;
                }
                @data = sort { $a->{blog_name} cmp $b->{blog_name} } @data;
                $param{blog_loop} = \@data;
            }
        } elsif ($type eq 'author') {
            require MT::Permission;
            my @perms = MT::Permission->load({'author_id'=>$app->user->id });
            my @blogs;
            if (@perms) {
                foreach my $perm (@perms) {
                    next unless $perm->can_administer_blog;
                    my $blog = MT::Blog->load( $perm->blog_id, {cached_ok=>1} );
                    my $row = { blog_id => $blog->id, blog_name => $blog->name };
                    if ($param{checked_blog_ids} && $param{checked_blog_ids}{$blog->id}) {
                        $row->{is_checked} = 1;
                    }
                    push @blogs, $row;
                }
            }
            @blogs = sort { $a->{blog_name} cmp $b->{blog_name} } @blogs;
            $param{blog_loop} = \@blogs;
        } elsif ($type eq 'template') {
            my $template_type = $q->param('type')
                   || return $app->errtrans("Create template requires type");
            $param{nav_templates} = 1;
            my $tab;
            if ($template_type eq 'index') {
                $tab = 'index';
            } elsif ($template_type eq 'archive' || $template_type eq 'individual' || $template_type eq 'category') {
                $tab = 'archive';
            } elsif ($template_type eq 'custom') {
                $tab = 'module';
            } else {
                $tab = 'system';
            }
            $app->add_breadcrumb($app->translate('Templates'), $app->uri('mode' => 'list', args => { '_type' => 'template', blog_id => $blog->id,
                'tab' => $tab }));
            $app->add_breadcrumb($app->translate('New Template'));
            $param{has_name} = $template_type eq 'index' ||
                               $template_type eq 'custom' ||
                               $template_type eq 'archive' ||
                               $template_type eq 'category' ||
                               $template_type eq 'individual';
            $param{has_outfile} = $template_type eq 'index';
            $param{has_rebuild} = $template_type eq 'index';
            $param{custom_dynamic} = $blog->custom_dynamic_templates eq 'custom';
            $param{has_build_options} = 
                    $blog->custom_dynamic_templates eq 'custom'
                      || $param{has_rebuild};
            $param{is_special} = $param{type} ne 'index'
                                 && $param{type} ne 'archive'
                                 && $param{type} ne 'category'
                                 && $param{type} ne 'individual';
            $param{has_build_options} = $param{has_build_options}
                                         && $param{type} ne 'custom'
                                         && !$param{is_special};;

            $param{rebuild_me} = 1;
        } elsif ($type eq 'blog') {
            $app->add_breadcrumb($app->translate('New Weblog'));
            $param{server_offset_0} = 1;
        }
    }
    # Regardless of whether the obj is new, load data into $param
    if ($type eq 'entry') {
        ## Load categories and process into loop for category pull-down.
        require MT::Placement;
        my $cat_id = $param{category_id};
        my $depth = 0;
        my %places;

        if ($id) {
            my @places = MT::Placement->load({ entry_id => $id, is_primary => 0});
            %places = map { $_->category_id => 1 } @places;
        }
        $param{reedit} = 1 if $q->param('reedit');
        if (!$q->param('is_bm')) {
            my $data = $app->_build_category_list($blog_id, undef, 1);
            foreach (@$data) {
                next unless exists $_->{category_id};
                $_->{category_is_primary} = $cat_id && $cat_id == $_->{category_id};
                $param{selected_category} = $_->{category_id} if $_->{category_is_primary};
                if ($param{reedit}) {
                    $_->{category_is_selected} = $q->param('add_category_id_' . $_->{category_id}) || $_->{category_is_primary};;
                } else {
                    $_->{category_is_selected} = exists $places{$_->{category_id}} || $_->{category_is_primary};
                }
            }
            my $top = { category_id => '',
                        category_label => $app->translate('Select') };
            $top->{category_is_selected} = 1 unless $cat_id;
            $param{category_loop} = [ $top, @$data ];
            $param{have_multiple_categories} = scalar @$data > 1;
            $param{add_category_loop} = $data;
        }
        if ($blog) {
            $param{basename_limit} = $blog->basename_limit || 30; # FIXME
        }

        ## Now load user's preferences and customization for new/edit
        ## entry page.
        if ($perms) {
            my $prefs = $perms->entry_prefs || 'Advanced|Bottom';
            ($prefs, my($pos)) = split /\|/, $prefs;
            if ($prefs eq 'Basic') {
                $param{'disp_prefs_' . $prefs} = 1;
                $param{'disp_prefs_show_body'} = 1;
            } elsif ($prefs eq 'Advanced') {
                my @all = qw( category body extended excerpt convert_breaks
                              allow_comments authored_on allow_pings 
                              ping_urls basename );
                for my $p (@all) {
                    $param{'disp_prefs_show_' . $p} = 1;
                }
            } else {
                my @p = split /,/, $prefs;
                for my $p (@p) {
                    $param{'disp_prefs_show_' . $p} = 1;
                }
            }
            if ($pos eq 'Both') {
                $param{'position_buttons_top'} = 1;
                $param{'position_buttons_bottom'} = 1;
                $param{'position_buttons_both'} = 1;
            } else {
                $param{'position_buttons_' . $pos} = 1;
            }
            $param{disp_prefs_bar_colspan} = $param{new_object} ? 1 : 2;
        }

        ## Load text filters.
        my %entry_filters;
        if (defined(my $filter = $q->param('convert_breaks'))) {
            $entry_filters{$filter} = 1;
        } elsif ($obj) {
            %entry_filters = map { $_ => 1 }
                             @{ $obj->text_filters };
        } else {
            my $blog = MT::Blog->load($blog_id, {cached_ok=>1});
            my $cb = $blog->convert_paras;
            $cb = '__default__' if $cb eq '1';
            $entry_filters{$cb} = 1;
            $param{convert_breaks} = $cb;
        }
        my $filters = MT->all_text_filters;
        $param{text_filters} = [];
        for my $filter (keys %$filters) {
            push @{ $param{text_filters} }, {
                filter_key => $filter,
                filter_label => $filters->{$filter}{label},
                filter_selected => $entry_filters{$filter},
                filter_docs => $filters->{$filter}{docs},
            };
        }
        $param{text_filters} = [
            sort { $a->{filter_key} cmp $b->{filter_key} }
            @{ $param{text_filters} } ];
        unshift @{ $param{text_filters} }, {
            filter_key => '0',
            filter_label => $app->translate('None'),
            filter_selected => (!keys %entry_filters),
        };
        if ($blog) {
            my $ext = ($blog->file_extension || '');
            $ext = '.' . $ext if $ext ne '';
            $param{blog_file_extension} = $ext;
        }
    } elsif ($type eq 'template') {
        $param{"type_$param{type}"} = 1;
    } elsif ($type eq 'blog') {
        my $cwd = '';
        if ($ENV{MOD_PERL}) {
            ## If mod_perl, just use the document root.
            $cwd = $app->{apache}->document_root;
        } else {
            $cwd = $app->mt_dir;
        }
        $cwd =~ s!([\\/])cgi-bin([\\/].*)?$!$1!;
        $cwd =~ s!([\\/])mt[\\/]?$!$1!i; 
        if (!$param{site_path}) {
            $param{site_path} = $cwd;
        }
        #if (!$param{archive_path}) {
        #    $param{archive_path} = File::Spec->catdir($cwd, 'archives');
        #}
        if (!$param{site_url}) {
            $param{site_url} = $app->base . '/';
            $param{site_url} =~ s!/cgi-bin(/.*)?$!/!;
            $param{site_url} =~ s!/mt/?$!/!i;
        }
        #if (!$param{archive_url}) {
        #    $param{archive_url} = $param{site_url} . 'archives/';
        #}
    } elsif ($type eq 'author') {
        $app->add_breadcrumb($app->translate("Authors"),
                             $app->uri(mode => 'list_authors'));
        if ($obj) {
            $app->add_breadcrumb($obj->name);
        } else {
            $app->add_breadcrumb($app->translate("Create New Author"));
        }
        my $langs = $app->supported_languages;
        my @data;
        my $preferred = $obj && $obj->preferred_language ?
            $obj->preferred_language : 'en-us';
        $preferred = 'en-us' if (lc($preferred) eq 'en_us');
        for my $tag (keys %$langs) {
            my $row = { l_tag => $tag, l_name => $app->translate($langs->{$tag}) };
            $row->{l_selected} = 1 if $preferred eq $tag;
            push @data, $row;
        }
        $param{languages} = [ sort { $a->{l_name} cmp $b->{l_name} }
                              @data ];
        $param{'nav_authors'} = 1;
    }
    if (($q->param('msg')||"") eq 'nosuch') {
        $param{nosuch} = 1;
    }
    for my $p ($q->param) {
        $param{$p} = $q->param($p) if $p =~ /^saved/;
    }
    if ($type eq 'comment') {
        my $cmntr = MT::Author->load({ id => $obj->commenter_id(),
                                       type => MT::Author::COMMENTER });
        $param{email_hidden} = $cmntr && $cmntr->is_email_hidden();
        $param{email} = $cmntr ? $cmntr->email : $obj->email;
        $param{comments_script_uri} = $app->config('CommentScript');
        if ($cmntr) {
            $param{profile_page} = $app->config('IdentityURL');
            $param{profile_page} .= "/" unless $param{profile_page} =~ m|/$|;
            $param{profile_page} .= $cmntr->name();
        }
    }
    if ($type ne 'blog' && defined($MT::PluginActions{$type})) {
        $param{plugin_action_loop} = $MT::PluginActions{$type};
    }
    if ($q->param('is_bm')) {
        my $show = $q->param('bm_show') || '';
        my %opts = ('c' => 'category', 't' => 'trackback', 'ap' => 'allow_pings', 'ac' => 'allow_comments', 'cb' => 'convert_breaks', 'e' => 'excerpt', 'k' => 'keywords', 'm' => 'text_more', 'b' => 'basename');
        if ($show) {
            my @show = map "show_$_", split /,/, $show;
            @param{ @show } = (1) x @show;
            # map the shortened show options to the long names used in the
            # quick post template
            foreach (@show) {
                s/^show_//;
                $param{"show_" . $opts{$_}} = 1 if exists $opts{$_};
            }
        }
        if ($show =~ /\b(category|c)\b/) {
            my @c_data;
            my $blog_loop = $param{blog_loop};
            foreach my $blog (@$blog_loop) {
                my $blog_id = $blog->{blog_id};
                my $blog_cats = $app->_build_category_list($blog_id);
                my $i = 0;
                for my $row (@$blog_cats) {
                    $row->{category_blog_id} = $blog_id;
                    $row->{category_index} = $i++;
                    my $spacer = $row->{category_label_spacer} || '';
                    $spacer =~ s/\&nbsp;/\\u00A0/g;
                    $row->{category_label_js} = $spacer . encode_js($row->{category_label});
                }
                push @c_data, @$blog_cats;
                $blog->{add_category_loop} = $blog_cats;
            }
            $param{category_loop} = \@c_data;
        }
        return $app->build_page("bm_entry.tmpl", \%param);
    } elsif ($param{output}) {
        return $app->build_page($param{output}, \%param);
    } else {
        return $app->build_page("edit_${type}.tmpl", \%param);
    }
}

sub build_junk_table {
    my $app = shift;
    my (%args) = @_;

    my $param = $args{param};
    my $obj = $args{object};

    if (defined $obj->junk_score) {
        $param->{junk_score} = ($obj->junk_score > 0 ? '+' : '') . $obj->junk_score;
    }
    my $log = $obj->junk_log || '';
    my @log = split /[\r?\n]/, $log;
    my @junk;
    for (my $i = 0; $i < scalar(@log); $i++) {
        my $line = $log[$i];
        $line =~ s/(^\s+|\s+$)//g;
        next unless $line;
        last if $line =~ m/^--->/;
        my ($test, $score, $log);
        ($test) = $line =~ m/^([^:]+?):/;
        if (defined $test) {
            ($score) = $test =~ m/\(([+-]?\d+?(?:\.\d*?)?)\)/;
            $test =~ s/\(.+\)//;
        }
        if (defined $score) {
            $score =~ s/\+//;
            $score .= '.0' unless $score =~ m/\./;
            $score = ($score > 0 ? '+' : '') . $score;
        }
        $log = $line;
        $log =~ s/^[^:]+:\s*//;
        for (my $j = $i + 1; $j < scalar(@log); $j++) {
            my $line = $log[$j];
            if ($line =~ m/^\t+(.*)$/s) {
                $i = $j;
                $log .= "<br />" . $1;
            } else {
                last;
            }
        }
        push @junk, { test => $test, score => $score, log => $log };
    }
    $param->{junk_log_loop} = \@junk;
    \@junk;
}

sub CMSSaveFilter_author {
    my ($eh, $app) = @_;

    my $name = $app->param('name');
    if (defined $name) {
        $name =~ s/(^\s+|\s+$)//g;
        $app->param('name', $name);
    }
    return $eh->error($app->translate("Author requires username"))
        if ($name !~ /\w/);
    if (!$app->param('id')) {  # it's a new object
        return $eh->error($app->translate("Author requires password"))
            if ($app->param('pass') !~ /\w/);
        return $eh->error($app->translate("Author requires password hint"))
            if ($app->param('hint') !~ /\w/);
    }
    return $eh->error(MT->translate("Email Address is required for password recovery"))
        unless $app->param('email');
    1;
}

sub CMSSaveFilter_template {
    1;
}

sub CMSSaveFilter_notification {
    my $eh = shift;
    my ($app) = @_;
    my $email = lc $app->param('email');
    $email =~ s/(^\s+|\s+$)//gs;
    my $blog_id = $app->param('blog_id');
    if (!is_valid_email($email)) {
        return $eh->error($app->translate("The value you entered was not a valid email address"));
    }
    require MT::Notification;
    # duplicate check
    my $notification_iter = MT::Notification->load_iter({blog_id => $blog_id});
    while (my $obj = $notification_iter->()) {
        if (lc($obj->email) eq $email) {
            return $eh->error($app->translate("The e-mail address you entered is already on the Notification List for this weblog."));
        }
    }
    return 1;
}

sub CMSSaveFilter_banlist {
    my $eh = shift;
    my ($app) = @_;
    my $ip = $app->param('ip');
    $ip =~ s/(^\s+|\s+$)//g;
    return $eh->error(MT->translate("You did not enter an IP address to ban."))
        if ('' eq $ip);
    my $blog_id = $app->param('blog_id');
    require MT::IPBanList;
    my $existing = MT::IPBanList->load({ 'ip' => $ip, 'blog_id' => $blog_id});
    my $id = $app->param('id');
    if ($existing && (!$id || $existing->id != $id)) {
        return $eh->error($app->translate("The IP you entered is already banned for this weblog."));
    }   
    return 1;
}

sub CMSSaveFilter_blog {
    my $eh = shift;
    my ($app) = @_;
    my $name = $app->param('name');
    if (defined $name) {
        $name =~ s/(^\s+|\s+$)//g;
        $app->param('name', $name);
    }
    return $eh->error(MT->translate("You did not specify a weblog name."))
        if (!$app->param('cfg_screen') && $app->param('name') eq '');
    return $eh->error(MT->translate("Site URL must be an absolute URL."))
        if ($app->param('cfg_screen') eq 'cfg_archives'
            && $app->param('site_url') !~ m.^https?://.);
    require MT::Blog;
    return $eh->error(MT->translate("There is already a weblog by that name!"))
        if (grep { $_->id != $app->param('id')} MT::Blog->load({name => $name}));
    return 1;
}


sub CMSSaveFilter_category {
    my $eh = shift;
    my ($app) = @_;
    return $app->errtrans("The name '[_1]' is too long!", $app->param('label'))
        if (length($app->param('label')) > 100);
    return 1;
}

sub CMSPreSave_ping {
    my $eh = shift;
    my ($app, $obj) = @_;
    my $status = $app->param('status');
    if ($status eq 'publish') {
        $obj->approve;
    } elsif ($status eq 'moderate') {
        $obj->moderate;
        $obj->junk_status(0);
    } elsif ($status eq 'junk') {
        $obj->junk;
    }
    return 1;
}

sub CMSPreSave_comment {
    my $eh = shift;
    my ($app, $obj) = @_;
    my $status = $app->param('status');
    if ($status eq 'publish') {
        $obj->approve;
    } elsif ($status eq 'moderate') {
        $obj->moderate;
        $obj->junk_status(0);
    } elsif ($status eq 'junk') {
        $obj->junk;
    }
    return 1;
}

sub CMSPreSave_author {
    my $eh = shift;
    my ($app, $obj) = @_;
    # Authors should only be of type AUTHOR when created from
    # the CMS app; COMMENTERs are created from the Comments app.
    $obj->type(MT::Author::AUTHOR);

    my $pass = $app->param('pass');
    if ($pass) {
        $obj->set_password($pass);
    }
    ## If this is an author editing his/her profile, $id will be
    ## some defined value; if so we should update the author's
    ## cookie to reflect any changes made to username and password.
    ## Otherwise, this is a new user, and we shouldn't update the
    ## cookie.
    if ($obj->id) {
        $app->start_session;
    } else {
        $obj->created_by($app->user->id);
    }
    1;
}

sub CMSPreSave_template {
    my $eh = shift;
    my ($app, $obj) = @_;
    $obj->rebuild_me(0) unless $app->param('rebuild_me');
    # (this is to hack around browsers' unwillingness to send value
    # of a disabled checkbox.)

    require MT::Blog;
    my $blog = MT::Blog->load($obj->blog_id, {cached_ok=>1});
    if ($blog->custom_dynamic_templates eq 'custom') {
        $obj->build_dynamic(0) unless $app->param('build_dynamic');
    } elsif ($blog->custom_dynamic_templates eq 'archives') {
        $obj->build_dynamic($obj->type eq 'archive' ||
                            $obj->type eq 'category' ||
                            $obj->type eq 'individual' || 0);
    } else {
        $obj->build_dynamic(0) unless $obj->build_dynamic;
    }
    ## Strip linefeed characters.
    (my $text = $obj->text) =~ tr/\r//d;
    $obj->text($text);
    1;
}

sub init_blog {
    my ($obj, $preferred_lang) = @_;
    $obj->set_defaults();
    $obj->language($preferred_lang || 'en');
}

sub CMSPreSave_blog {
    my $eh = shift;
    my ($app, $obj) = @_;
    if (!$app->param('overlay') &&
        $app->param('cfg_screen') )
    {
        # checkbox options have to be blanked if they aren't
        # passed.
        my $screen = $app->param('cfg_screen');
        my @fields;
        if ($screen eq 'cfg_prefs') {
            @fields = qw( old_style_archive_links
                          ping_weblogs ping_blogs ping_technorati
                          autodiscover_links );
        } elsif ($screen eq 'cfg_entries') {
            @fields = qw( ping_blogs ping_weblogs ping_technorati
                          allow_comments_default allow_pings_default 
                          autodiscover_links internal_autodiscovery );
        } elsif ($screen eq 'cfg_archives') {
            @fields = qw(site_url site_path archive_type_preferred
                         file_extension);
        } elsif ($screen eq 'cfg_templatemaps') {
        } elsif ($screen eq 'cfg_feedback') {
            @fields = qw( allow_pings require_comment_emails
                          allow_comment_html autolink_urls moderate_pings );
        } elsif ($screen eq 'cfg_plugins') {
        }
        for my $cb (@fields) {
            $obj->$cb(0) if !defined $app->param($cb);
        }
        if ($screen eq 'cfg_feedback') {
            # value for comments:  1 == Accept from anyone
            #                      2 == Accept authenticated only
            #                      0 == No comments
            my $comments = $app->param('allow_comments');
            if ($comments == 1) {
                $obj->allow_unreg_comments(1);
                $obj->allow_reg_comments(1);
            } elsif ($comments == 2) {
                $obj->allow_unreg_comments(0);
                $obj->allow_reg_comments(1);
            } elsif ($comments == 0) {
                $obj->allow_unreg_comments(0);
                $obj->allow_reg_comments(0);
            }
            $obj->require_comment_emails($app->param('require_email_address'));
            $obj->moderate_unreg_comments($app->param('moderate_comments'));

            my $pings = $app->param('allow_pings');
            if ($pings) {
                $obj->moderate_pings($app->param('moderate_pings'));
            } else {
                $obj->moderate_pings(1);
                $obj->email_new_pings(1);
            }
            my $threshold = $app->param('junk_score_threshold');
            $threshold =~ s/\+//; $threshold ||= 0;
            $obj->junk_score_threshold($threshold);
            my $expiry = $app->param('junk_folder_expiry') || 0;
            $obj->junk_folder_expiry($expiry);
            my $tok = '';
            ($tok = $obj->remote_auth_token) =~ s/\s//g;
            $obj->remote_auth_token($tok);
            $obj->junk_folder_expiry(0) unless $app->param('auto_delete_junk');
        } elsif ($screen eq 'cfg_entries') {
            $obj->basename_limit(15) if $obj->basename_limit < 15; # 15 is the *minimum*
            $obj->basename_limit(250) if $obj->basename_limit > 250; # 15 is the *maximum*
        } elsif ($screen eq 'cfg_prefs') {
            if ($app->param('days_or_posts') eq 'days') {
                $obj->days_on_index($app->param('list_on_index'));
                $obj->entries_on_index(0);
            } else {
                $obj->entries_on_index($app->param('list_on_index'));
                $obj->days_on_index(0);
            }
        } elsif ($screen eq 'cfg_archives') {
            if (my $dcty = $app->param('dynamicity')) {
                $obj->custom_dynamic_templates($dcty);
            }
            if (!$app->param('enable_archive_paths')) {
                $obj->archive_url('');
                $obj->archive_path('');
            }
        }
    } else {
        #$obj->is_dynamic(0) unless defined $app->{query}->param('is_dynamic');
    }

    if (($obj->sanitize_spec || '') eq '1') {
        $obj->sanitize_spec(scalar $app->param('sanitize_spec_manual'));
    }

    ## If this is a new blog, set the preferences and archive
    ## settings to the defaults.
    if (!$obj->id) {
        init_blog($obj, $app->user->preferred_language);
    }
    1;
}

sub CMSPreSave_category {
    my $eh = shift;
    my ($app, $obj) = @_;
    $obj->category_parent(0) if !defined $app->param('category_parent');
    $obj->allow_pings(0) if !defined $app->param('allow_pings');
    if (defined(my $pass = $app->param('tb_passphrase'))) {
        $obj->{__tb_passphrase} = $pass;
    }
    my @siblings = MT::Category->load({ parent => $obj->parent,
                                        blog_id => $obj->blog_id });
    foreach (@siblings) {
        next if $_->id == $obj->id;
        return $app->errtrans("No categories with the same name can have the same parent")
            if $_->label eq $obj->label;
    }
    1;
}

sub CMSPreSave_entry {
    my $eh = shift;
    my ($app, $obj) = @_;
    $obj->discover_tb_from_entry();
    1;
}

sub CMSPostSave_blog {
    my $eh = shift;
    my ($app, $obj, $original) = @_;

    my $screen = $app->param('cfg_screen') || '';
    if ($screen eq 'cfg_archives') {
        if (my $dcty = $app->param('dynamicity')) {
            $app->update_dynamicity($obj);
        }
        $app->cfg_archives_save($obj);
    }

    if (!$original->id) {      # If the object is new, the "orignal" was blank
        ## If this is a new blog, we need to set up a permissions
        ## record for the existing user.
        require MT::Permission;
        my $perms = MT::Permission->new;
        $perms->author_id($app->user->id);
        $perms->blog_id($obj->id);
        $perms->set_full_permissions;
        $perms->save;

        ## Load default templates into new blog database.
        my $tmpl_list;
        eval { $tmpl_list = require 'MT/default-templates.pl' };
        warn $app->errtrans("Can't find default template list; where is " .
                              "'default-templates.pl'?"), return
            if $@ || !$tmpl_list || ref($tmpl_list) ne 'ARRAY' ||!@$tmpl_list;
        require MT::Template;
        my @arch_tmpl;
        for my $val (@$tmpl_list) {
            $val->{name} = $app->translate($val->{name});
            $val->{text} = $app->translate_templatized($val->{text});
            my $tmpl = MT::Template->new;
            $tmpl->set_values($val);
            $tmpl->build_dynamic(0) unless $tmpl->build_dynamic();
            $tmpl->blog_id($obj->id);
            $tmpl->save or return $app->errtrans(
                    "Populating blog with default templates failed: [_1]",
                    $tmpl->errstr);
            if ($val->{type} eq 'archive' || $val->{type} eq 'category' ||
                $val->{type} eq 'individual') {
                push @arch_tmpl, $tmpl;
            }
        }

        ## Set up mappings from new templates to archive types.
        for my $tmpl (@arch_tmpl) {
            my(@at);
            if ($tmpl->type eq 'archive') {
                @at = qw( Daily Weekly Monthly );
            } elsif ($tmpl->type eq 'category') {
                @at = qw( Category );
            } elsif ($tmpl->type eq 'individual') {
                @at = qw( Individual );
            }
            require MT::TemplateMap;
            for my $at (@at) {
                my $map = MT::TemplateMap->new;
                $map->archive_type($at);
                $map->is_preferred(1);
                $map->template_id($tmpl->id);
                $map->blog_id($tmpl->blog_id);
                $map->save
                    or return $app->errtrans("Setting up mappings failed: [_1]",
                                             $map->errstr);
            }
        }
        $app->log($app->translate("Weblog '[_1]' created by '[_2]' (user #[_3])",
                                  $obj->name, $app->user->name, $app->user->id));
    } else {
        # if you've changed the comment configuration
        if ((grep { $original->column($_) ne $obj->column($_) }
             qw(allow_unreg_comments allow_reg_comments remote_auth_token)))
        {
            if (RegistrationAffectsArchives($obj->id,'Individual'))
            {
                $app->add_return_arg(need_full_rebuild => 1);
            } else {
                $app->add_return_arg(need_index_rebuild => 1);
            }
        }
        # if other settings were changed that would affect published pages:
        if (grep { $original->column($_) ne $obj->column($_) }
            qw(allow_pings allow_comment_html)) {
            $app->add_return_arg(need_full_rebuild => 1);
        }
    }
    1;
}

sub RegistrationAffectsArchives {       # :-P
    my ($blog_id, $archive_type) = @_;
    require MT::TemplateMap;
    require MT::Template;
    my @tms = MT::TemplateMap->load({archive_type => $archive_type,
                                     blog_id => $blog_id});
    grep { $_->text =~ /MTIfRegistrationRequired|MTIfRegistrationNotRequired|MTIfRegistrationAllowed/ }
     map { MT::Template->load($_->template_id) } @tms;
}

sub CMSPostSave_author {
    my $eh = shift;
    my ($app, $obj, $original) = @_;

    if (!$original->id) {
        my $author_id = $obj->id;
        for my $blog_id ($app->param('add_to_blog')) {
            # FIXME: check for existing permission just in case
            my $pe = MT::Permission->new;
            $pe->blog_id($blog_id);
            $pe->author_id($author_id);
            # By default, a new author can post and comment
            $pe->can_post(1);
            $pe->can_comment(1);
            $pe->save;
        }
    } else {
        if ($app->user->id == $obj->id) {
            # re-save user cookie to avoid appearance of logging out
            $app->{author} = $obj;
            $app->start_session();
        }
    }
    1;
}

sub CMSPostSave_comment {
    my $eh = shift;
    my ($app, $obj, $original) = @_;
    if ($obj->visible || (($obj->visible || 0) != ($original->visible||0))) {
        $app->rebuild_entry(Entry => $obj->entry_id, BuildIndexes => 1);
    }
    1;
}

sub CMSPostSave_ping {
    my $eh = shift;
    my ($app, $obj, $original) = @_;
    require MT::Trackback;
    require MT::Entry;
    require MT::Category;
    if (my $tb = MT::Trackback->load($obj->tb_id, {cached_ok=>1})) {
        my ($entry, $cat); 
        if ($tb->entry_id && ($entry = MT::Entry->load($tb->entry_id, {cached_ok=>1}))) {
            if ($obj->visible || (($obj->visible || 0) != ($original->visible || 0))) {
                $app->rebuild_entry(Entry => $entry, BuildIndexes => 1);
            }
        } elsif ($tb->category_id && ($cat = MT::Category->load($tb->category_id, {cached_ok=>1}))) {
             # FIXME: rebuild single category
        }
    }
    1;
}

sub CMSPostSave_trackback {
    my $eh = shift;
    my ($app, $obj) = @_;
    $app->rebuild_entry(Entry => $obj->entry_id, BuildIndexes => 1);
    1;
}

sub CMSPostSave_template {
    my $eh = shift;
    my ($app, $obj, $original) = @_;
    if ($obj->build_dynamic && !$original->build_dynamic) {
        if ($obj->type eq 'index') {
            $app->rebuild_indexes(BlogID => $obj->blog_id,
                                  Template => $obj);            # XXXX
        } else {
            $app->rebuild(BlogID => $obj->blog_id,
                          TemplateID => $obj->id);
        }
    }
    1;
}

sub save_object {
    my $app = shift;
    my $q = $app->param;
    my $type = $q->param('_type');
    my $id = $q->param('id');

    $app->validate_magic() or return;
    my $author = $app->user;

    MT->_register_core_callbacks({
        CMSSavePermissionFilter_blog => sub {
            my ($eh, $app, $id) = @_;
            return  ($id && $app->{perms}->can_edit_config)
                || (!$id && $app->user->can_create_blog);
        },
        CMSSavePermissionFilter_template => sub {
            my ($eh, $app, $id) = @_;
            return $app->{perms}->can_edit_templates;
        },
        CMSSavePermissionFilter_category => sub {
            my ($eh, $app, $id) = @_;
            return $app->{perms}->can_edit_categories();
        },
        CMSSavePermissionFilter_notification => sub {
            my ($eh, $app, $id) = @_;
            return $app->{perms}->can_edit_notifications;
        },
        CMSSavePermissionFilter_author => sub {
            my ($eh, $app, $id) = @_;
            if (!$id) {
                return $author->is_superuser;
            } else {
                return $author->id == $id;
            }
        },
        CMSSavePermissionFilter_comment => sub {
            my ($eh, $app, $id) = @_;
            return 0 unless $id;  # Can't create new comments here
            return 1 if $app->{perms}->can_edit_all_posts;
            if ($app->{perms}->can_post) {
                my $c = MT::Comment->load($id, {cached_ok=>1});
                return ($c->entry->author_id == $app->user->id);
            } else {
                return 0;
            }
        },
        CMSSavePermissionFilter_ping => sub {
            my ($eh, $app, $id) = @_;
            return 0 unless $id;  # Can't create new pings here
            return 1 if $app->{perms}->can_edit_all_posts;
            my $p = MT::TBPing->load($id, {cached_ok=>1});
            my $tbitem = $p->parent;
            if ($tbitem->isa('MT::Entry')) { 
                return ($app->{perms}->can_post &&
                        ($tbitem->author_id == $app->user->id));
            } else {
                return $app->{perms}->can_edit_categories;
            }
        },
        CMSSavePermissionFilter_banlist => sub {
            my ($eh, $app, $id) = @_;
            $app->{perms}->can_edit_config;
        },
    }) || die MT->errstr;

    # Check permissions
    my $perms = $app->{perms};

    if (!$author->is_superuser) {
        if ($type ne 'author') {  # for authors, blog-ctx $perms is not relevant
            return $app->errtrans("No permissions")
                if !$perms && $id;
        } 
        
        MT->run_callbacks('CMSSavePermissionFilter_' . $type, $app, $id)
            || return $app->error($app->translate("Permission denied.")
                                  . MT->errstr());
    }

    MT->_register_core_callbacks({"CMSSaveFilter_" . $type =>
                                      \&{"CMSSaveFilter_" . $type}})
        if $app->can("CMSSaveFilter_" . $type);

    my $filter_result = MT->run_callbacks('CMSSaveFilter_' . $type, $app);
        
    if (!$filter_result) {
        my %param;
        $param{error} = MT->errstr;
        $param{return_args} = $app->param('return_args');
        if (($type eq 'notification') || ($type eq 'banlist')) {
            return $app->list_objects(\%param);
        } elsif ($app->param('cfg_screen') eq 'cfg_archives') {
            return $app->cfg_archives(\%param);
        } else {
            return $app->edit_object(\%param);
        }
    }

    if ($type eq 'author') {
        ## If we are saving an author profile, we need to do some
        ## password maintenance. First make sure that the two
        ## passwords match...
        my %param;
        if ($q->param('pass') ne $q->param('pass_verify')) {
            $param{error} = $app->translate('Passwords do not match.');
        } else {
            if ($q->param('pass') && $id) {
                my $auth = MT::Author->load($id, {cached_ok=>1});
                if (!$auth->is_valid_password($q->param('old_pass'))) {
                    $param{error} = $app->translate('Failed to verify current password.');
                }
            }
        }
        my $hint = $q->param('hint') || '';
        $hint =~ s!^\s+|\s+$!!gs;
        unless ($hint) {
            $param{error} = $app->translate('Password hint is required.');
        }
        if ($param{error}) {
            my $qual = $id ? '' : 'author_state_';
            for my $f (qw( name nickname email url )) {
                $param{$qual . $f} = $q->param($f);
            }
            $param{checked_blog_ids} = { map { $_ => 1 }
                                         $q->param('add_to_blog') };
            return $app->edit_object(\%param);
        }

        ## ... then check to make sure that the author isn't trying
        ## to change his/her username to one that already exists.
        my $name = $app->param('name');
        my $existing = MT::Author->load({ name => $name,
                                          type => MT::Author::AUTHOR});
        if ($existing && (!$q->param('id') ||
            $existing->id != $q->param('id'))) {
            my %param = (error => $app->translate('An author by that name already exists.'));
            my $qual = $id ? '' : 'author_state_';
            for my $f (qw( name email url )) {
                $param{$qual . $f} = $q->param($f);
            }
            $param{checked_blog_ids} = { map { $_ => 1 }
                                         $q->param('add_to_blog') };
            return $app->edit_object(\%param);
        }
    }

    my $class = $app->_load_driver_for($type) or return;
    my($obj);
    if ($id) {
        $obj = $class->load($id);
    } else {
        $obj = $class->new;
    }

    my $original = $obj->clone();
    my $names = $obj->column_names;
    my %values = map { $_ => (scalar $q->param($_)) } @$names;

    if ($type eq 'comment') {
        require MT::Entry;
        my $entry = MT::Entry->load($obj->entry_id, {cached_ok=>1});
        if (!($entry->author_id == $app->user->id
              || $perms->can_edit_all_posts)) {
            return $app->error($app->translate("Permission denied."));
        }
    }
        
    $obj->set_values(\%values);

    MT->_register_core_callbacks({"CMSPreSave_" . $type =>
                                      \&{"CMSPreSave_" . $type}})
        if $app->can("CMSPreSave_" . $type);
    MT->run_callbacks('CMSPreSave_' . $type, $app, $obj, $original)
        || return $app->error("Save failed: " . MT->errstr);

    # Done pre-processing the record-to-be-saved; now save it.

    $obj->touch() if ($type eq 'blog');

    $obj->save or
        return $app->error($app->translate(
            "Saving object failed: [_1]", $obj->errstr));

    MT->_register_core_callbacks({"CMSPostSave_" . $type =>
                                      \&{"CMSPostSave_" . $type}})
        if $app->can("CMSPostSave_" . $type);

    # Now post-process it.
    MT->run_callbacks('CMSPostSave_' . $type, $app, $obj, $original)
        or return $app->error(MT->errstr());

    # Finally, decide where to go next, depending on the object type.
    my $blog_id = $q->param('blog_id');
    if ($type eq 'blog') {
        $blog_id = $obj->id;
    }

    # TODO: convert this to use $app->call_return(); 
    # then templates can determine the page flow.
    if ($type eq 'author' && !$id) {
        return $app->redirect($app->uri('mode' => 'edit_permissions',
            args => { 'author_id' => $obj->id }));
    } elsif ($type eq 'notification') {
        return $app->redirect($app->uri('mode' => 'list',
            args => { '_type' => 'notification', blog_id => $blog_id,
                      saved => $obj->email }));
    } elsif ($type eq 'ping') {
        $app->add_return_arg('saved_ping' => 1);
        return $app->call_return;
    } elsif ($type eq 'comment') {
        $app->add_return_arg('saved_comment' => 1);
        return $app->call_return;
    } elsif (my $cfg_screen = $q->param('cfg_screen')) {
        if ($cfg_screen eq 'cfg_templatemaps') {  # TBD
            $cfg_screen = 'cfg_archives';
        }
        my $site_path = $obj->site_path;
        $app->add_return_arg( no_writedir => 1 )
            unless -d $site_path && -w $site_path;
        $app->add_return_arg( saved => 1 );
        return $app->call_return;
    } elsif ($type eq 'banlist') {
        return $app->redirect($app->uri('mode' => 'list',
            args => {'_type' => 'banlist', blog_id => $blog_id,
                     saved => $obj->ip}));
    } elsif ($type eq 'template' && $q->param('rebuild')) {
        $q->param('type', 'index-' . $obj->id);
        $q->param('tmpl_id', $obj->id);
        $q->param('single_template', 1);
        return $app->start_rebuild_pages();
    } else {
        return $app->redirect($app->uri('mode' => 'view',
            args => { '_type' => $type, id => $obj->id,
            blog_id => $blog_id, saved => 1}));
    }
}

sub list_objects {
    my $app = shift;
    my %param = $_[0] ? %{ $_[0] } : ();
    my $q = $app->param;
    my $type = $q->param('_type');
    my $perms = $app->{perms};
    return $app->error($app->translate("No permissions"))
        unless $type eq 'author' || $perms;
    if ($perms &&
        (($type eq 'blog' && !$perms->can_edit_config) ||
         ($type eq 'template' && !$perms->can_edit_templates) ||
         ($type eq 'notification' && !$perms->can_edit_notifications) ||
         ($type eq 'author' && !$perms->can_administer_blog))) {
        return $app->error($app->translate("Permission denied."));
    }
    my $id = $q->param('id');
    my $class = $app->_load_driver_for($type) or return;
    my $blog_id = $q->param('blog_id');
    my $list_pref = $app->list_pref($type);
    my (%terms, %args);
    %param = ( %param, %$list_pref );
    my $cols = $class->column_names;
    my $limit = $list_pref->{rows};
    my $offset = $limit eq 'none' ? 0 : ($app->param('offset') || 0);
    for my $name (@$cols) {
        $terms{blog_id} = $blog_id, last
            if $name eq 'blog_id';
    }
    if ($type eq 'author') {
        $terms{type} = AUTHOR;
    }
    if ($type eq 'notification') {
        $args{direction} = 'descend';
        $args{offset} = $offset;
        $args{limit} = $limit + 1 if $limit ne 'none';
    } elsif ($type eq 'banlist') {
        $limit = 0;
    }
    my $iter = $class->load_iter(\%terms, \%args);

    my(@data, @index_data, @custom_data, @archive_data, @system_data);
    my(%authors);
    require MT::Blog;
    my $blog = MT::Blog->load($blog_id, {cached_ok=>1});
    while (my $obj = $iter->()) {
        my $row = $obj->column_values;
        if (my $ts = $obj->created_on) {
            $row->{created_on_formatted} = format_ts("%Y.%m.%d", $ts);
            $row->{created_on_time_formatted} = format_ts("%Y.%m.%d %H:%M:%S", $ts);
            $row->{created_on_relative} = relative_date($ts, time, $blog);
        }
        if ($type eq 'author') {
            $authors{ $obj->id } = $obj->name;
            if ($obj->id == $app->user->id) {
                $row->{is_me} = 1;
            }
        }
        if ($type eq 'template') {
            $row->{name} = '' if !defined $row->{name};
            $row->{name} =~ s/^\s+|\s+$//g;
            $row->{name} = "(" . $app->translate("No Name") . ")"
                if $row->{name} eq '';
	    $row->{name} = $app->translate($row->{name});
            if ($obj->type eq 'index') {
                push @index_data, $row;
                $row->{rebuild_me} = defined $row->{rebuild_me} ?
                    $row->{rebuild_me} : 1;
            } elsif ($obj->type eq 'custom') {
                push @custom_data, $row;
            } elsif ($obj->type eq 'archive' || $obj->type eq 'category' ||
                     $obj->type eq 'individual') {
                push @archive_data, $row;
            } else {
                $row->{name} = $app->translate($row->{name});
                $row->{description} = $app->translate('_SYSTEM_TEMPLATE_' . uc($row->{type}));
                push @system_data, $row;
            }
            $param{search_type} = $app->translate('Templates');
        } else {
            if ($limit && $limit ne 'none' && (scalar @data == $limit)) {
                $param{next_offset} = 1;
                last;
            }
            push @data, $row;
        }
        if ($type eq 'ping') {
            return $app->list_pings();
            require MT::Trackback;
            require MT::Entry;
            my $tb_center = MT::Trackback->load($obj->tb_id, {cached_ok=>1});
            my $entry = MT::Entry->load($tb_center->entry_id, {cached_ok=>1});
            if (my $ts = $obj->created_on) {
                $row->{created_on_time_formatted}
                   = format_ts("%Y.%m.%d %H:%M:%S", $ts);
                $row->{has_edit_access} = $perms->can_edit_all_posts
                                      || $app->user->id == $entry->author_id;
            }
        }
    } # end loop over the set of objects;
    if ($type eq 'author') {
        $app->add_breadcrumb($app->translate('Authors'));
        my $this_author_id = $app->user->id;
        for my $row (@data) {
            $row->{added_by} = $authors{$row->{created_by}}
                if $row->{created_by};
            $row->{has_edit_access} = 1
                if ($row->{created_by} &&
                   $row->{created_by} == $this_author_id);
        }
        $param{object_type} = 'author';
        $param{object_type_plural} = $app->translate('authors');
    }
    # NOW transform the @data array
    if ($type eq 'notification') {
        $app->add_breadcrumb($app->translate('Notification List'));
        $param{nav_notifications} = 1;
        #@data = sort { $a->{email} cmp $b->{email} } @data;
        $param{object_type} = 'notification';
        $param{object_type_plural} = $app->translate('email addresses');
    }
    if ($type eq 'template') {
        my $blog = MT::Blog->load(scalar $q->param('blog_id'), {cached_ok=>1});
        $app->add_breadcrumb($app->translate('Templates'));
        $param{nav_templates} = 1;
        for my $ref (\@index_data, \@custom_data, \@archive_data) {
            @$ref = sort { $a->{name} cmp $b->{name} } @$ref;
        }
        my $tab = $app->param('tab') || 'index';
        $param{"tab_$tab"} = 1;
        $param{object_index_loop} = \@index_data;
        $param{object_custom_loop} = \@custom_data;
        $param{object_archive_loop} = \@archive_data;
        $param{object_system_loop} = \@system_data;
        $param{object_type} = 'template';
        $param{object_type_plural} = $app->translate('templates');
    } else {
        $param{object_loop} = \@data;
    }
    # add any breadcrumbs
    if ($type eq 'banlist') {
        my $blog = MT::Blog->load($blog_id, {cached_ok=>1});
        $app->add_breadcrumb($app->translate('IP Banning'));
        $param{nav_config} = 1;
        $param{object_type} = 'banlist';
        $param{show_ip_info} = 1;
        $param{object_type_plural} = $app->translate('IP addresses');
    } elsif ($type eq 'ping') {
        $app->add_breadcrumb($app->translate('TrackBacks'));
        $param{nav_trackbacks} = 1;
        $param{object_type} = 'ping';
        $param{object_type_plural} = $app->translate('TrackBacks');
    }
    $param{object_count} = scalar @data;

    if ($type ne 'template') {
        $param{offset} = $offset;
        $param{list_start} = $offset + 1;
        delete $args{limit};
        delete $args{offset};
        $param{list_total} = $class->count(\%terms, \%args);
        $param{list_end} = $offset + (scalar @data);
        $param{next_offset_val} = $offset + (scalar @data);
        #$param{next_offset} = $param{next_offset_val} < $param{list_total} ? 1 : 0;
        $param{next_max} = $param{list_total} - ($limit eq 'none' ? 0 : $limit);
        $param{next_max} = 0 if ($param{next_max} || 0) < $offset + 1;
        if ($offset > 0) {
            $param{prev_offset} = 1;
            $param{prev_offset_val} = $offset - ($limit eq 'none' ? 0 : $limit);
            $param{prev_offset_val} = 0 if $param{prev_offset_val} < 0;
        }
    }

    my $plugin_actions = $app->plugin_itemset_actions($type);
    $param{plugin_itemset_action_loop} = $plugin_actions
        if $plugin_actions;
    my $core_actions = $app->core_itemset_actions($type);
    $param{core_itemset_action_loop} = $core_actions
        if $core_actions;
    $param{has_itemset_actions} =
        ($plugin_actions || $core_actions) ? 1 : 0;

    $param{saved} = $q->param('saved');
    $param{saved_deleted} = $q->param('saved_deleted');
    if ($type ne 'blog' && defined($MT::PluginActions{'list_'.$type})) {
        $param{plugin_action_loop} = $MT::PluginActions{'list_'.$type};
    }
    $app->build_page("list_${type}.tmpl", \%param);
}

sub delete_confirm {
    my $app = shift;
    my %param = ( type => scalar $app->param('_type') );
    my @data;
    for my $id ($app->param('id')) {
        push @data, { id => $id };
    }
    $param{parent} = $app->param('parent');
    $param{id_loop} = \@data;
    $param{num} = scalar @data;
    $param{'type_' . $param{type}} = 1;
    $param{is_zero} = @data == 0;
    $param{is_one} = @data == 1;
    $param{is_many} = !$param{is_zero} && !$param{is_one};
    $param{thisthese} = $param{is_one} ? 'this' : 'these';
    $param{is_power_edit} = $app->param('is_power_edit') ? 1 : 0;
    $param{return_args} = $app->param('return_args');
    $app->build_page('delete_confirm.tmpl', \%param);
}

sub delete {
    my $app = shift;
    my $q = $app->param;
    my $type = $q->param('_type');
    my $parent = $q->param('parent');
    my $class = $app->_load_driver_for($type) or return;
    my $perms = $app->{perms};
    my $author = $app->user;

    return $app->error($app->translate("Can't delete that way"))
        if $app->request_method() ne 'POST';

    $app->validate_magic() or return $app->errtrans("Your login session has expired.");

    ## Construct a routine $auth_check to check if
    ## the user has permission to delete each object being deleted.
    my $auth_check = sub { };
    if ($type eq 'comment') {
        $auth_check = sub {
            my($obj) = @_;
            require MT::Entry;
            my $entry = MT::Entry->load($obj->entry_id, {cached_ok=>1});
            if (!$perms || $perms->blog_id != $entry->blog_id) {
                $perms ||= MT::Permission->load({
                    author_id => $author->id,
                    blog_id => $entry->blog_id,
                });
            }
            ($perms && $perms->can_edit_entry($entry, $author));
        };
    } elsif ($type eq 'ping') {
        $auth_check = sub {
            my($obj) = @_;
            require MT::Trackback;
            require MT::Entry;
            my $tb = MT::Trackback->load($obj->tb_id, {cached_ok=>1});
            my $entry = MT::Entry->load($tb->entry_id, {cached_ok=>1});
            if (!$perms || $perms->blog_id != $entry->blog_id) {
                $perms ||= MT::Permission->load({
                    author_id => $author->id,
                    blog_id => $entry->blog_id,
                });
            }
            ($perms && $perms->can_edit_entry($entry, $author));
        };
    } elsif ($type eq 'ping_cat') {
        $auth_check = sub { $perms->can_edit_categories };
    } elsif ($type eq 'entry') {
        $auth_check = sub {
            if (!$perms || $perms->blog_id != $_[0]->blog_id) {
                $perms ||= MT::Permission->load({
                    author_id => $author->id,
                    blog_id => $_[0]->blog_id,
                });
            }
            ($perms && $perms->can_edit_entry($_[0], $author));
        };
    } elsif ($type eq 'notification') {
        $auth_check = sub { $perms->can_edit_notifications };
    } elsif ($type eq 'template') {
        $auth_check = sub { $perms->can_edit_templates };
    } elsif ($type eq 'blog') {
        $auth_check = sub {
            require MT::Permission;
            my $perms = MT::Permission->load({
                author_id => $author->id,
                blog_id => $_[0]->id,
            });
            ($perms && $perms->can_administer_blog);
        };
    } elsif ($type eq 'author') {
        $auth_check = sub { ($_[0]->created_by
                             && $_[0]->created_by == $author->id) };
    } elsif ($type eq 'commenter') {
        $auth_check = sub { 1 };
    } elsif ($type eq 'category') {
        $auth_check = sub { $perms->can_edit_categories };
    } elsif ($type eq 'templatemap') {
        $auth_check = sub { $perms->can_edit_config };
    } elsif ($type eq 'banlist') {
        $auth_check = sub { $perms->can_edit_config };
    }

    my($entry_id, $cat_id, $author_id) = ("", "", "");
    my %rebuild_entries;
    my @rebuild_cats;
    for my $id ($q->param('id')) {
        my $obj = $class->load($id, {cached_ok=>1});
        next unless $obj;
        if (!$author->is_superuser()) {
            return $app->error($app->translate("Permission denied."))
                unless $auth_check->($obj);
        }

        if ($type eq 'comment') {
            $entry_id = $obj->entry_id;
            $rebuild_entries{$entry_id} = 1 if $obj->visible;
        } elsif ($type eq 'ping' || $type eq 'ping_cat') {
            require MT::Trackback;
            my $tb = MT::Trackback->load($obj->tb_id, {cached_ok=>1});
            if ($tb) {
                $entry_id = $tb->entry_id;
                $cat_id = $tb->category_id;
                if ($obj->visible) {
                    $rebuild_entries{$entry_id} = 1 if $entry_id;
                    push @rebuild_cats, $cat_id if $cat_id;
                }
            }
        } elsif ($type eq 'category') {
            my @kids = MT::Category->load({parent => $id});
            return $app->errtrans("You can't delete that category because it has sub-categories. Move or delete the sub-categories first if you want to delete this one.") if @kids;
        }
        $obj->remove;

        if ($type eq 'blog') {
            $app->log($app->translate("Weblog '[_1]' deleted by '[_2]' (user #[_3])", $obj->name, $author->name, $author->id));
        }
    }
    require MT::Entry;
    for my $entry_id (keys %rebuild_entries) {
        my $entry = MT::Entry->load($entry_id, {cached_ok=>1});
        $app->rebuild_entry( Entry => $entry, BuildDependencies => 1 );
    }
    my $blog_id = $q->param('blog_id'); 
    for my $cat_id (@rebuild_cats) {
        my $cat = MT::Category->load($cat_id, {cached_ok=>1});
        $app->rebuild( Category => $cat, BlogID => $blog_id,
                       ArchiveType => 'Category' );
    }
    $app->add_return_arg($type eq 'ping' ? (saved_deleted_ping => 1) 
                         : (saved_deleted => 1));
    if ($q->param('is_power_edit')) {
        $app->add_return_arg(is_power_edit => 1);
    }
    $app->call_return;
}

sub _load_driver_for {
    my $app = shift;
    my($type) = @_;
    my $class = $API{$type} or
        return $app->error($app->translate("Unknown object type [_1]",
            $type));
    eval "use $class;";
    return $app->error($app->translate(
        "Loading object driver [_1] failed: [_2]", $class, $@)) if $@;
    $class;
}


sub show_upload_html {
    my $app = shift;
    defined(my $text = $app->_process_post_upload) or return;
    $app->build_page('show_upload_html.tmpl',
        { upload_html => $text });
}

sub start_upload_entry {
    my $app = shift;
    my $q = $app->param;
    $q->param('_type', 'entry');
    defined(my $text = $app->_process_post_upload) or return;
    $q->param('text', $text);
    $app->edit_object;
}

sub _process_post_upload {
    my $app = shift;
    my $q = $app->param;
    my($url, $width, $height) = map $q->param($_), qw( url width height );
    my ($base_url, $fname) = $url =~ m|(.*)/([^/]*)|;
    my $encoded_fname = encode_url($fname);
    $url = $base_url . '/' . $encoded_fname;
    my $blog_id = $q->param('blog_id');
    require MT::Blog;
    my $blog = MT::Blog->load($blog_id, {cached_ok=>1});
    my($thumb, $thumb_width, $thumb_height);
    if ($thumb = $q->param('thumb')) {
        require MT::Image;
        my $base_path = $q->param('site_path') ?
            $blog->site_path : $blog->archive_path;
        my $file = $q->param('fname');
        if ($file =~ m!\.\.|\0|\|!) {
            return $app->error($app->translate("Invalid filename '[_1]'", $file));
        }
        my $i_file = File::Spec->catfile($base_path, $file);
        ## Untaint. We checked $file for security holes above.
        ($i_file) = $i_file =~ /(.+)/s;
        my $fmgr = $blog->file_mgr;
        my $data = $fmgr->get_data($i_file, 'upload')
            or return $app->error($app->translate(
                "Reading '[_1]' failed: [_2]", $i_file, $fmgr->errstr));
        my $img = MT::Image->new( Data => $data,
                                  Type => scalar $q->param('image_type') )
            or return $app->error($app->translate(
                "Thumbnail failed: [_1]", MT::Image->errstr));
        my($w, $h) = map $q->param($_), qw( thumb_width thumb_height );
        (my($blob), $thumb_width, $thumb_height) =
            $img->scale( Width => $w, Height => $h )
            or return $app->error($app->translate("Thumbnail failed: [_1]",
                $img->errstr));
        require File::Basename;
        my($base, $path, $ext) = File::Basename::fileparse($i_file, '\.[^.]*');
        my $t_file = $path . $base . '-thumb' . $ext;
        $fmgr->put_data($blob, $t_file, 'upload')
            or return $app->error($app->translate(
                "Error writing to '[_1]': [_2]", $t_file, $fmgr->errstr));
        $file =~ s/\Q$base$ext\E$//;
        my $url = $q->param('site_path') ? $blog->site_url : $blog->archive_url;
        $url .= '/' unless $url =~ m!/$!;
        $url .= $file;
        $thumb = $url . encode_url($base . '-thumb' . $ext);
    }
    if ($q->param('popup')) {
        require MT::Template;
        if (my $tmpl = MT::Template->load({ blog_id => $blog_id,
                                            type => 'popup_image' })) {
            (my $rel_path = $q->param('fname')) =~ s!\.[^.]*$!!;
            if ($rel_path =~ m!\.\.|\0|\|!) {
                return $app->error($app->translate(
                    "Invalid basename '[_1]'", $rel_path));
            }
            my $ext = $blog->file_extension || '';
            $ext = '.' . $ext if $ext ne '';
            require MT::Template::Context;
            my $ctx = MT::Template::Context->new;
            $ctx->stash('image_url', $url);
            $ctx->stash('image_width', $width);
            $ctx->stash('image_height', $height);
            my $popup = $tmpl->build($ctx);
            my $fmgr = $blog->file_mgr;
            my $root_path = $q->param('site_path') ?
                $blog->site_path : $blog->archive_path;
            my $abs_file_path = File::Spec->catfile($root_path, $rel_path . $ext);

            ## If the popup filename already exists, we don't want to overwrite
            ## it, because it could contain valuable data; so we'll just make
            ## sure to generate the name uniquely.
            my($i, $rel_path_ext) = (0, $rel_path . $ext);
            while ($fmgr->exists($abs_file_path)) {
                $rel_path_ext = $rel_path . ++$i . $ext;
                $abs_file_path = File::Spec->catfile($root_path, $rel_path_ext);
            }
            my ($vol, $dirs, $basename) = File::Spec->splitpath($rel_path_ext);
            my $rel_url_ext = File::Spec->catpath($vol, $dirs, encode_url($basename));
 
            ## Untaint. We have checked for security holes above, so we
            ## should be safe.
            ($abs_file_path) = $abs_file_path =~ /(.+)/s;
            $fmgr->put_data($popup, $abs_file_path, 'upload')
                or return $app->error($app->translate(
                   "Error writing to '[_1]': [_2]", $abs_file_path,
                                                     $fmgr->errstr));
            $url = $q->param('site_path') ?
                $blog->site_url : $blog->archive_url;
            $url .= '/' unless $url =~ m!/$!;
            $rel_url_ext =~ s!^/!!;
            $url .= $rel_url_ext;
        }
        my $link = $thumb ? qq(<img src="$thumb" width="$thumb_width" height="$thumb_height" alt="" />) : q{<MT_TRANS phrase="View image">};
        return $app->translate_templatized(<<HTML);
<a href="$url" onclick="window.open('$url','popup','width=$width,height=$height,scrollbars=no,resizable=no,toolbar=no,directories=no,location=no,menubar=no,status=no,left=0,top=0'); return false">$link</a>
HTML
    } elsif ($q->param('include')) {
        if ($thumb) {
            return <<HTML;
<a href="$url"><img alt="$fname" src="$thumb" width="$thumb_width" height="$thumb_height" /></a>
HTML
        } else {
            return <<HTML;
<img alt="$fname" src="$url" width="$width" height="$height" />
HTML
        }
    } elsif ($q->param('link')) {
        return $app->translate_templatized(<<HTML);
<a href="$url"><MT_TRANS phrase="Download file"></a>
HTML
    }
}

use constant NEW_PHASE => 1;

sub save_commenter_perm {
    my $app = shift;
    my ($params) = @_;
    my $q = $app->param;
    my $action = $q->param('action');

    $app->validate_magic() or return;

    my $acted_on;
    my %rebuild_set;
    my @ids = $params ? @$params : $app->param('commenter_id');
    my $blog_id = $q->param('blog_id');

    foreach my $id (@ids) {
        ($id, $blog_id) = @$id if ref $id eq 'ARRAY';

        my $cmntr = MT::Author->load({ id => $id,
                                       type => MT::Author::COMMENTER })
            or return $app->errtrans("No such commenter [_1].", $id);
        my $old_status =  $cmntr->status($blog_id);
        
        if ($action eq 'trust' && $cmntr->status($blog_id) != APPROVED) {
            $cmntr->approve($blog_id) or return $app->error($cmntr->errstr);
            $acted_on++;
        } elsif ($action eq 'ban' && $cmntr->status($blog_id) != BANNED) {
            $cmntr->ban($blog_id) or return $app->error($cmntr->errstr);
            $acted_on++;
        } elsif ($action eq 'unban' && $cmntr->status($blog_id) == BANNED)
        {
            $cmntr->pending($blog_id) or return $app->error($cmntr->errstr);
            $acted_on++;
        } elsif ($action eq 'untrust' && $cmntr->status($blog_id) == APPROVED)
        {
            $cmntr->pending($blog_id) or return $app->error($cmntr->errstr);
            $acted_on++;
        }
        
        require MT::Entry;
        require MT::Comment;
        my $iter = MT::Entry->load_iter(undef,
                                        { join =>
                                              [ 'MT::Comment', 'entry_id',
                                                {commenter_id => $cmntr->id}
                                              ]
                                        });
        my $e;
        while ($e = $iter->()) {
            $rebuild_set{$id} = $e;
        }
    }
    if ($acted_on) {
        my %msgs = (trust => 'trusted',
                    ban => 'banned',
                    unban => 'unbanned',
                    untrust => 'untrusted');
        $app->add_return_arg($msgs{$action} => 1);
    }
    $app->call_return;
}

sub map_comment_to_commenter {
    my ($comments) = @_;
    my %commenters;
    require MT::Comment;
    for my $id (@$comments) {
        my $cmt = MT::Comment->load($id, {cached_ok=>1});
        if ($cmt->commenter_id) {
            $commenters{$cmt->commenter_id . ':' . $cmt->blog_id} = [$cmt->commenter_id, $cmt->blog_id];
        }
    }
    return values %commenters;
}

sub trust_commenter_by_comment {
    my $app = shift;
    my @comments = $app->param('id');
    my @commenters = map_comment_to_commenter(\@comments);
    $app->param('action', 'trust');
    $app->save_commenter_perm(\@commenters);
}

sub untrust_commenter_by_comment {
    my $app = shift;
    my @comments = $app->param('id');
    my @commenters = map_comment_to_commenter(\@comments);
    $app->param('action', 'untrust');
    $app->save_commenter_perm(\@commenters);
}

sub ban_commenter_by_comment {
    my $app = shift;
    my @comments = $app->param('id');
    my @commenters = map_comment_to_commenter(\@comments);
    $app->param('action', 'ban');
    $app->save_commenter_perm(\@commenters);
}

sub unban_commenter_by_comment {
    my $app = shift;
    my @comments = $app->param('id');
    my @commenters = map_comment_to_commenter(\@comments);
    $app->param('action', 'unban');
    $app->save_commenter_perm(\@commenters);
}

sub trust_commenter {
    my $app = shift;
    my @commenters = $app->param('id');
    $app->param('action', 'trust');
    $app->save_commenter_perm(\@commenters);
}

sub ban_commenter {
    my $app = shift;
    my @commenters = $app->param('id');
    $app->param('action', 'ban');
    $app->save_commenter_perm(\@commenters);
}

sub unban_commenter {
    my $app = shift;
    my @commenters = $app->param('id');
    $app->param('action', 'unban');
    $app->save_commenter_perm(\@commenters);
}

sub untrust_commenter {
    my $app = shift;
    my @commenters = $app->param('id');
    $app->param('action', 'untrust');
    $app->save_commenter_perm(\@commenters);
}

sub rebuild_phase {
    my $app = shift;
    my $type = $app->param('_type') || 'entry';
    my @ids = $app->param('id');
    $app->{goback} = "window.location='". $app->return_uri . "'";
    if ($type eq 'entry') {
        require MT::Entry;
        foreach (@ids) {
            my $entry = MT::Entry->load($_, {cached_ok=>1});
            if ($entry->status == MT::Entry::RELEASE()) {
                $app->rebuild_entry(Entry => $entry, BuildDependencies => 1)
                    or return;
            }
        }
    } elsif ($type eq 'template') {
        require MT::Template;
        foreach (@ids) {
            my $template = MT::Template->load($_, {cached_ok=>1});
            $app->rebuild_indexes(Template => $template,
                                  Force => 1) or return;
        }
    }
    $app->call_return;
}

sub draft_entries {
    require MT::Entry;
    $_[0]->update_entry_status(MT::Entry::HOLD(), $_[0]->param('id'));
}

sub publish_entries {
    require MT::Entry;
    $_[0]->update_entry_status(MT::Entry::RELEASE(), $_[0]->param('id'));
}

sub update_entry_status {
    my $app = shift;
    my ($new_status, @ids) = @_;
    return $app->errtrans("Need a status to update entries") unless $new_status;
    return $app->errtrans("Need entries to update status") unless @ids;
    my @bad_ids;
    my @rebuild_list;
    require MT::Entry;
    foreach my $id (@ids) {
        my $entry = MT::Entry->load($id, {cached_ok=>1}) or return $app->errtrans("One of the entries ([_1]) did not actually exist", $id);
        push @rebuild_list, $entry if $entry->status != $new_status;
        $entry->status($new_status);
        $entry->save() or (push @bad_ids, $id);
    }
    return $app->errtrans("Some entries failed to save") if (@bad_ids); # FIXME: we don't really want this
    $app->rebuild_entry(Entry => $_, BuildDependencies => 1) 
        foreach @rebuild_list; # FIXME: optimize, phase out to another page.
    my $blog_id = $app->param('blog_id');
    $app->call_return;
}

sub approve_item {
    $_[0]->param('approve', 1);
    $_[0]->set_item_visible;
}

sub unapprove_item {
    $_[0]->param('unapprove', 1);
    $_[0]->set_item_visible;
}

sub set_item_visible {
    my $app = shift;
    my $perms = $app->{perms};
    my $author = $app->user;

    $app->validate_magic() or return;

    my $type = $app->param('_type');
    my $class = $app->_load_driver_for($type);

    my $new_visible;
    if ($app->param('approve')) {
        $new_visible = 1;
    } elsif ($app->param('unapprove')) {
        $new_visible = 0;
    }

    my %rebuild_set = ();
    my @obj_ids = $app->param('id');
    require MT::Entry;
    foreach my $id (@obj_ids) {
        my $obj = $class->load($id, {cached_ok=>1});
        my $old_visible = $obj->visible || 0;
        if ($old_visible != $new_visible) {
            if ($obj->isa('MT::TBPing')) {
                my $obj_parent = $obj->parent();
                if ($obj_parent->isa('MT::Category')) {
                    # TBD: Rebuild the category
                } else {
                    if (!$author->is_superuser) {
                        if (!$perms || $perms->blog_id != $obj->blog_id) {
                            $perms = MT::Permission->load({ author_id => $author->id,
                                blog_id => $obj->blog_id });
                        }
                        if (!$perms || (!$perms->can_edit_all_posts()
                            && $obj_parent->author_id != $author->id)) {
                            return $app->errtrans("You don't have permission to approve this TrackBack.");
                        }
                    }
                    $rebuild_set{$obj_parent->id} = $obj_parent;
                }
            } elsif ($obj->entry_id) {
                # TBD: Factor out permissions checking
                my $entry = MT::Entry->load($obj->entry_id, {cached_ok=>1}) 
                    || return $app->error("Comment on missing entry!");
                if (!$author->is_superuser) {
                    if (!$perms || $perms->blog_id != $obj->blog_id) {
                        $perms = MT::Permission->load({ author_id => $author->id,
                            blog_id => $obj->blog_id });
                    }
                    if (!$perms || (!$perms->can_edit_all_posts()
                        && $entry->author_id != $author->id)) {
                        return $app->errtrans("You don't have permission to approve this comment.");
                    }
                }
                $rebuild_set{$obj->entry_id} = $entry;
            }
            $obj->visible($new_visible);
            $obj->save();
        }
    }
    my $approved_flag = ($new_visible ? '' : 'un') . 'approved';
    $app->add_return_arg($approved_flag => 1);
    return $app->rebuild_these(\%rebuild_set, how => NEW_PHASE);
}

sub list_commenters {
    my $app = shift;
    unless ($app->{perms}->can_edit_config()) {
        return $app->error($app->translate("Permission denied."));
    }

    my $q = $app->param;
    my $list_pref = $app->list_pref('commenter');
    my $blog_id = $q->param('blog_id');
    my %param = %$list_pref;
    my %terms = (type => COMMENTER);
    my %terms2 = ();
    my $limit = $list_pref->{rows};
    my $offset = $q->param('offset') || 0;
    my %arg;
    require MT::Comment;
    $arg{'join'} = ['MT::Comment', 'commenter_id',
                    { ( $blog_id ? (blog_id => $blog_id) : () ) },
                    { 'sort' => 'created_on',
                      direction => 'descend', unique => 1 }];
    my ($filter_col, $val);
    $param{filter_args} = "";
    if (($filter_col = $q->param('filter'))
        && ($val = $q->param('filter_val')))
    {
        if (!exists ($terms{$filter_col})) {
            if ($filter_col eq 'status') {
                my ($role_mask) = 
                      ($val eq 'neutral' ? 0
                     : $val eq 'approved' ? 1
                     : $val eq 'banned' ? 2048 : 0);
                $arg{join} = 
                    ['MT::Permission', 'author_id', 
                     {role_mask => $role_mask, blog_id => $blog_id}];
            } else {
                $terms{$filter_col} = $val;
            }

            $param{filter} = $filter_col;
            $param{filter_val} = $val;
            my $url_val = encode_url($val);
            $param{filter_args} = "&filter=$filter_col&filter_val=$url_val";
        }
    }
    $arg{'offset'} = $offset if $offset;
    $arg{'limit'} = $limit + 1 if $limit ne 'none';
    my $terms = \%terms;
    my $arg = \%arg;
    my $iter = MT::Author->load_iter($terms, $arg);

    my $data = $app->build_commenter_table(iter => $iter, param => \%param);
    if ($limit ne 'none' && @$data > $limit) {
        pop @$data;
        $param{next_offset} = 1;
        $param{next_offset_val} = $offset + ($limit eq 'none' ? 0 : $limit);
    }
    if ($offset > 0) {
        $param{prev_offset} = 1;
        $param{prev_offset_val} = $offset - ($limit eq 'none' ? 0 : $limit);
        $param{prev_offset_val} = 0 if $param{prev_offset_val} < 0;
    }

    $param{object_type} = 'commenter';
    $param{object_type_plural} = $app->translate('commenters');
    $param{search_type} = $app->translate('Commenters');
    $param{list_start} = $offset + 1;
    $param{list_end} = $offset + scalar @$data;
    $param{offset} = $offset;
    $param{limit} = $limit;
    delete $arg->{limit}; delete $arg->{offset};
    $param{list_total} = MT::Author->count($terms, $arg);
    if ($param{list_total}) {
        $param{next_max} = $param{list_total} - ($limit eq 'none' ? 0 : $limit);
        $param{next_max} = 0 if ($param{next_max} || 0) < $offset + 1;
    }
    $app->add_breadcrumb($app->translate('Authenticated Commenters'));
    $param{nav_commenters} = 1;
    for my $msg (qw(trusted untrusted banned unbanned)) {
        $param{$msg} = 1 if $app->param($msg);
    }
    return $app->build_page('list_commenters.tmpl', \%param);
}

sub build_commenter_table {
    my $app = shift;
    my (%args) = @_;

    my $param = $args{param};
    my $iter;
    if ($args{load_args}) { 
        my $class = $app->_load_driver_for('commenter');
        $iter = $class->load_iter( @{ $args{load_args} } );
    } elsif ($args{iter}) {
        $iter = $args{iter};
    } elsif ($args{items}) {
        $iter = sub { pop @{ $args{items} } };
    }

    my $app_user = $app->user;
    my $user_perm = $app->{perms};
    require MT::Permission;
    my $blog_id = $app->param('blog_id');
    
    my @data;
    require MT::Blog;
    my $blog = MT::Blog->load($blog_id, {cached_ok=>1});
    while (my $cmtr = $iter->()) {
        require MT::Comment;
        my $cmt_count = MT::Comment->count({commenter_id => $cmtr->id,
                                         blog_id => $blog_id});
        my $most_recent = MT::Comment->load({commenter_id => $cmtr->id,
                                             blog_id => $blog_id},
                                            {'sort' => 'created_on',
                                             direction => 'descend'})
            if $cmt_count > 0;

        
        my $blog_connection = MT::Permission->load({author_id => $cmtr->id,
                                                    blog_id => $blog_id});
        # Tells us whether the commenter is associated with this
        # blog. the role flags are not important
        next if (!$cmt_count && !$blog_connection);

        my $row = {};
        $row->{author_id} = $cmtr->id();
        $row->{author} = $cmtr->name();
        $row->{author_display} = $cmtr->nickname();
        $row->{email} = $cmtr->email();
        $row->{url} = $cmtr->url();
        $row->{email_hidden} = $cmtr->is_email_hidden();
        $row->{comment_count} = $cmt_count;
        if ($most_recent) {
            if (my $ts = $most_recent->created_on) {
                $row->{most_recent_time_formatted} =
                    format_ts("%Y-%m-%d %H:%M:%S", $ts); 
                $row->{most_recent_formatted} =
                    format_ts("%Y.%m.%d", $ts); 
                $row->{most_recent_relative} =
                    relative_date($ts, time, $blog);
            }
        }
        $row->{status} = {PENDING => "neutral",
                          APPROVED => "approved",
                          BANNED => "banned"}->{$cmtr->status($blog_id)};
        $row->{commenter_approved} = $cmtr->status($blog_id) == APPROVED;
        $row->{commenter_banned} = $cmtr->status($blog_id) == BANNED;
        $row->{profile_page} = $app->config('IdentityURL');
        $row->{profile_page} .= "/" unless $row->{profile_page} =~ m|/$|;
        $row->{profile_page} .= $cmtr->name();
        $row->{has_edit_access} = $user_perm->can_edit_config();
        push @data, $row;
    }
    return [] unless @data;

    $param->{commenter_table}[0]{object_loop} = \@data if @data;
    my $plugin_actions = $app->plugin_itemset_actions('commenter');
    $param->{commenter_table}[0]{plugin_itemset_action_loop} = $plugin_actions
        if $plugin_actions;
    my $core_actions = $app->core_itemset_actions('commenter');
    $param->{commenter_table}[0]{core_itemset_action_loop} = $core_actions
        if $core_actions;
    $param->{commenter_table}[0]{has_itemset_actions} =
        ($plugin_actions || $core_actions) ? 1 : 0;
    $param->{commenter_table}[0]{plugin_action_loop} = $MT::PluginActions{'list_commenters'}
        if ref $MT::PluginActions{'list_commenters'};
    \@data;
}

sub core_itemset_actions {
    my $app = shift;
    $app->itemset_actions('CoreItemsetActions', @_);
}
sub plugin_itemset_actions {
    my $app = shift;
    $app->itemset_actions('PluginItemsetActions', @_);
}
sub itemset_actions {
    my $app = shift;
    my ($which, $set, @param) = @_;
    my $actions = $app->{$which}{$set} if $app->{$which}{$set};
    @$actions = grep { $_->{condition} ? $_->{condition}->(@param) : 1 } @$actions;
    return undef unless @$actions;
    # FIXME: bother caching these?
    $_->{label} = $app->translate($_->{orig_label}) foreach @$actions;
    $actions;
}

sub list_comments {
    my $app = shift;
    my $q = $app->param;
    my $perms = $app->{perms};

    if ($perms) {
        if (!$perms->can_edit_all_posts && !$perms->can_post) {
            return $app->error($app->translate("Permission denied."));
        }
    } # otherwise we simply filter the list of objects

    my $list_pref = $app->list_pref('comment');
    my $blog_id = $q->param('blog_id');
    require MT::Blog;
    my $blog;
    $blog = MT::Blog->load($blog_id, {cached_ok=>1}) if $blog_id;
    my %param = %$list_pref;
    my %terms;
    if ($blog_id) { $terms{blog_id} = $blog_id }
    elsif (!$app->user->is_superuser) {
        $terms{blog_id} = [map {$_->blog_id}
                           grep {$_->can_post || $_->can_edit_all_posts}
                           MT::Permission->load({author_id=>$app->user->id})];
    }
    my %terms2 = ();
    my $limit = $list_pref->{rows};
    my $offset = $limit eq 'none' ? 0 : ($app->param('offset') || 0);
    ## We load $limit + 1 records so that we can easily tell if we have a
    ## page of next entries to link to. Obviously we only display $limit
    ## entries.
    my %arg = (
            'sort' => 'created_on',
            direction => 'descend',
    );
    if (($app->param('tab') || '') eq 'junk') {
        $terms{'junk_status'} = -1;
    } else {
        $terms{'junk_status'} = [ 0, 1 ];
        $arg{'range_incl'} = {'junk_status' => 1};
    }

#     my $iter2 = sub { } ;
    my $cmtr_filter = undef;
    my @val = $q->param('filter_val');
    my $filter_col = $q->param('filter');
    if ($filter_col && (my ($val) = @val))
    {
        if (!exists $terms{$filter_col}) {
            if ($filter_col eq 'status') {
                $terms{visible} = $val eq 'approved' ? 1 : 0;
            } elsif ($filter_col eq 'commenter') {
                # authenticated, unauthenticated, trusted
                if ($val eq 'trusted') {
                    $cmtr_filter = sub { $_[0] && $_[0]->is_trusted($_[1]) };
                } elsif ($val eq 'authenticated') {
                    $cmtr_filter = sub { $_[0] && $_[0]->is_not_trusted($_[1]) };
                } elsif ($val eq 'unauthenticated') {
                    $cmtr_filter = sub { !$_[0] };
                }
            } else {
                if ($val[1]) {
                    $terms{$filter_col} = [ $val, $val[1] ];
                    $arg{'range_incl'} = { $filter_col => 1 };
                    $param{filter_val2} = $val[1];
                    $param{filter_range} = 1;
                } else {
                    $terms{$filter_col} = $val;
                }
            }
#             if ($filter_col eq 'email' && is_valid_email($val)) {
#                 %terms2 = %terms;
#                 $terms2{$filter_col} = perl_sha1_digest_hex('mailto:' . $val);
#                 $iter2 = MT::Comment->load_iter(\%terms2, \%arg);
#             }
            my $url_val = encode_url($val);
            $param{filter} = $q->param('filter');
            $param{filter_val} = $q->param('filter_val');;
            $param{filter_args} = "&filter=$filter_col&filter_val=$url_val";
            $param{filter_args} .= "&filter_val=" . encode_url($val[1]) if $val[1];
            $param{is_filtered} = 1;
        }
    }

    require MT::Comment;
    require MT::Entry;
    my($iter, $iter1);

    # FIXME this offset logic breaks if you filter the iterator as below.
    my $total = MT::Comment->count(\%terms, \%arg);
    $arg{limit} = $limit + 1 if $limit ne 'none';
    if ($offset > $total - 1) {
        $arg{offset} = $offset = $total - ($limit eq 'none' ? 1 : $limit);
    } elsif ($offset < 0) {
        $arg{offset} = $offset = 0;
    } elsif ($offset) {
        $arg{offset} = $offset;
    }

    $iter1 = MT::Comment->load_iter(\%terms, \%arg);

    if ($cmtr_filter) {
        $iter = sub {  # filter the iterator
            my $cmt;
            while ($cmt = $iter1->()) {
                my $cmtr = $cmt->commenter_id ? MT::Author->load($cmt->commenter_id, {cached_ok=>1}) : undef;
                return $cmt if $cmtr_filter->($cmtr, $cmt->blog_id);
            }
            $cmt;
        };
    } else {
        $iter = $iter1;
    }

    my $loop = $app->build_comment_table( iter => $iter, param => \%param );

    if ($limit ne 'none') {
        ## We tried to load $limit + 1 entries above; if we actually got
        ## $limit + 1 back, we know we have another page of entries.
        my $have_next_entry = @$loop > $limit;
        pop @$loop while @$loop > $limit;
        if ($offset) {
            $param{prev_offset} = 1;
            $param{prev_offset_val} = $offset - $limit;
            $param{prev_offset_val} = 0 if $param{prev_offset_val} < 0;
        }
        if ($have_next_entry) {
            $param{next_offset} = 1;
            $param{next_offset_val} = $offset + $limit;
        }
    }
    $param{is_ip_filter} = (($q->param('filter') || "") eq 'ip');
    $param{filter_val} = $q->param('filter_val');
    $param{filter_val} = substr($param{filter_val}, 0, 25) . '...'
        if $param{filter_val} && $param{filter_val} =~ m(\S{25,});
    $param{saved} = $q->param('saved');
    $param{approved} = $q->param('approved');
    $param{unapproved} = $app->param('unapproved');
    $param{junked} = $q->param('junked');
    $param{unjunked} = $q->param('unjunked');
    $param{saved_deleted} = $q->param('saved_deleted');
    $param{no_junk_found} = $q->param('no_junk_found');
    $param{limit} = $limit;
    $param{offset} = $offset;
    $param{object_type} = 'comment';
    $param{object_type_plural} = $app->translate('comments');
    $param{search_type} = $app->translate('Comments');
    $param{list_start} = $offset + 1;
    $param{list_end} = $offset + scalar @$loop;
    $param{list_total} = $total;
    if ($param{list_total}) {
        $param{next_max} = $param{list_total} - ($limit eq 'none' ? 0 : $limit);
        $param{next_max} = 0 if ($param{next_max} || 0) < $offset + 1;
    }
    $param{plugin_action_loop} = $MT::PluginActions{'list_comments'}
                      if ref $MT::PluginActions{'list_comments'};
    $param{nav_comments} = 1;
    $param{has_expanded_mode} = 1;
    $param{tab} = $app->param('tab');
    $param{"tab_" . ($app->param('tab') || 'comments')} = 1;
    $app->add_breadcrumb($app->translate('Comments'));
    $app->build_page("list_comment.tmpl", \%param);
}

sub build_template_table {
    my $app = shift;
    my (%args) = @_;

    my $perms = $app->{perms};
    my $list_pref = $app->list_pref('template');
    my $iter;
    if ($args{load_args}) {
        my $class = $app->_load_driver_for('template');
        $iter = $class->load_iter( @{ $args{load_args} } );
    } elsif ($args{iter}) {
        $iter = $args{iter};
    } elsif ($args{items}) {
        $iter = sub { pop @{ $args{items} } };
    }
    my $limit = $args{limit} || 'none';
    my $param = $args{param} || {};

    my @data;
    my $i;
    my %blogs;
    while (my $tmpl = $iter->()) {
        my $row = $tmpl->column_values;
        $row->{name} = '' if !defined $row->{name};
        $row->{name} =~ s/^\s+|\s+$//g;
        $row->{name} = "(" . $app->translate("No Name") . ")"
            if $row->{name} eq '';
        push @data, $row;
        $row->{can_delete} = 1 if $tmpl->type =~ m/(custom|index|archive|individual|category)/;
        my $blog = $blogs{$tmpl->blog_id} ||= MT::Blog->load($tmpl->blog_id);
        $row->{blog_name} = $blog->name;
        last if ($limit ne 'none') && (@data > $limit);
    }
    return [] unless @data;

    $param->{template_table}[0] = { %$list_pref };
    $param->{template_table}[0]{object_loop} = \@data;
    $param->{template_table}[0]{object_type} = 'template';
    $param->{template_table}[0]{object_type_plural} = 'templates';
    my $plugin_actions = $app->plugin_itemset_actions('template');
    $param->{template_table}[0]{plugin_itemset_action_loop} = $plugin_actions
        if $plugin_actions;
    my $core_actions = $app->core_itemset_actions('template');
    $param->{template_table}[0]{core_itemset_action_loop} = $core_actions
        if $core_actions;
    $param->{template_table}[0]{has_itemset_actions} =
        ($plugin_actions || $core_actions) ? 1 : 0;
    \@data;
}

sub build_comment_table {
    my $app = shift;
    my (%args) = @_;

    my $author = $app->user;
    my $list_pref = $app->list_pref('comment');
    my $iter;
    if ($args{load_args}) {
        my $class = $app->_load_driver_for('comment');
        $iter = $class->load_iter( @{ $args{load_args} } );
    } elsif ($args{iter}) {
        $iter = $args{iter};
    } elsif ($args{items}) {
        $iter = sub { pop @{ $args{items} } };
    }
    my $limit = $args{limit} || 'none';
    my $param = $args{param} || {};

    my @data;
    my $i;
    $i = 1;
    my (%blogs, %entries, %perms);
    my $trim_length = $app->config('ShowIPInformation') ? 45 : 90;
    while (my $obj = $iter->()) {
        my $row = $obj->column_values;
        $row->{author_display} = $row->{author};
        $row->{author_display} = substr($row->{author_display}, 0, 25) . '...'
            if $row->{author_display} && $row->{author_display} =~ m(\S{25,});
        $row->{comment_short} = (substr($obj->text(), 0, $trim_length) .
                                 (length($obj->text) > $trim_length ? "..." : ""));
        $row->{comment_short} =~ s/(\S{30})/$1 /g; # break up really long strings
        $row->{comment_long} = remove_html($obj->text);
        $row->{comment_long} =~ s/(\S{80})/$1 /g; # break up really long strings

        $row->{visible} = $obj->visible();
        $row->{entry_id} = $obj->entry_id();
        my $entry = $entries{$obj->entry_id} ||= MT::Entry->load($obj->entry_id, {cached_ok=>1});
        unless ($entry) {
            $entry = new MT::Entry;
            $entry->title('* ' . $app->translate('Orphaned comment') . ' *');
        }
        $row->{entry_title} = defined($entry->title) ? $entry->title 
                            : defined($entry->text) ? $entry->text : "";
        $row->{entry_title} = substr($row->{entry_title}, 0, 25) . '...'
            if $row->{entry_title} && $row->{entry_title} =~ m(\S{25,});
        $row->{commenter_id} = $obj->commenter_id() if $obj->commenter_id();
        my $cmntr = MT::Author->load({ id => $obj->commenter_id(),
                                       type => MT::Author::COMMENTER });
        if ($cmntr) {
            $row->{email_hidden} = $cmntr && $cmntr->is_email_hidden();
            require MT::Permission;

            my $status = $cmntr->status($obj->blog_id);
            $row->{commenter_approved} = ($cmntr->status($obj->blog_id)== APPROVED);
            $row->{commenter_banned} = ($cmntr->status($obj->blog_id) == BANNED);
        }
        if (my $ts = $obj->created_on) {
            $row->{created_on_time_formatted} =
                format_ts("%Y-%m-%d %H:%M:%S", $ts); 
            $row->{created_on_formatted} =
                format_ts("%Y.%m.%d", $ts); 

            $row->{created_on_relative} = relative_date($ts, time, $obj->blog);
        }
        if ($author->is_superuser()) {
            $row->{has_edit_access} = 1;
        } else {
            my $perms = $perms{$obj->blog_id} ||= MT::Permission->load({ author_id => $author->id, blog_id => $obj->blog_id }, { cached_ok => 1 });
            $row->{has_edit_access} = ($perms && $perms->can_edit_all_posts)
                                      || $author->id == $entry->author_id;
        }
        my $blog = $blogs{$obj->blog_id} ||= $obj->blog;
        $row->{weblog_id} = $blog->id;
        $row->{weblog_name} = $blog->name;
        push @data, $row;
        last if ($limit ne 'none') && (@data > $limit);
    }
    return [] unless @data;

    my $junk_tab = ($app->param('tab') || '') eq 'junk';
    $param->{comment_table}[0] = { %$list_pref };
    $param->{comment_table}[0]{object_loop} = \@data;
    $param->{comment_table}[0]{object_type} = 'comment';
    $param->{comment_table}[0]{object_type_plural} = $app->translate('comments');
    my $plugin_actions = $app->plugin_itemset_actions('comment', $junk_tab ? 'junk' : 'comments');
    $param->{comment_table}[0]{plugin_itemset_action_loop} = $plugin_actions||[];
    my $core_actions = $app->core_itemset_actions('comment', $junk_tab ? 'junk' : 'comments');
    $param->{comment_table}[0]{core_itemset_action_loop} = $core_actions
        if $core_actions;
    $param->{comment_table}[0]{has_itemset_actions} =
        ($plugin_actions || $core_actions) ? 1 : 0;
    \@data;
}

sub plugin_control {
    my $app = shift;

    $app->validate_magic or return;
    return unless $app->user->is_superuser();

    my $plugin_sig = $app->param('plugin_sig') || '';
    my $state = $app->param('state') || '';

    my $cfg = $app->config;
    if ($plugin_sig eq '*') {
        $cfg->UsePlugins($state eq 'on' ? 1 : 0, 1);
    } else {
        if (exists $MT::Plugins{$plugin_sig}) {
            $cfg->PluginSwitch($plugin_sig . '=' . ($state eq 'on' ? '1' : '0'), 1);
        }
    }
    $cfg->save_config;

    $app->add_return_arg('switched' => 1);
    $app->call_return;
}

sub list_plugins {
    my $app = shift;
    my %param;
    my $cfg = $app->config;
    my $data = [];

    $param{can_config} = $app->user->is_superuser();
    $param{use_plugins} = $cfg->UsePlugins;

    # we have to sort the plugin list in an odd fashion...
    #   PLUGINS
    #     (those at the top of the plugins directory and those
    #      that only have 1 .pl script in a plugin folder)
    #   PLUGIN SET
    #     (plugins folders with multiple .pl files)
    my %list;
    my %folder_counts;
    for my $sig (keys %MT::Plugins) {
        my $sub = $sig =~ m!/! ? 1 : 0;
        my $obj = $MT::Plugins{$sig}{object} ? 0 : 1;
        my $err = $MT::Plugins{$sig}{error} ? 0 : 1;
        my $on = $MT::Plugins{$sig}{enabled} ? 0 : 1;
        my ($fld, $plg);
        ($fld, $plg) = $sig =~ m!(.*)/(.*)!;
        $fld = '' unless $fld;
        $folder_counts{$fld}++ if $fld;
        $plg ||= $sig;
        $list{$sub.sprintf("%-100s",$fld).$obj.$plg} = $sig;
    }
    my @keys = keys %list;
    foreach my $key (@keys) {
        my $fld = substr($key, 1, 100);
        $fld =~ s/\s+$//;
        next unless $fld;
        if ($folder_counts{$fld} == 1) {
            my $sig = $list{$key};
            delete $list{$key};
            $list{'0'.(' 'x100) . substr($key, 102)} = $sig;
        }
    }

    my $last_fld = '*';
    my $next_is_first;
    my $id = 0;
    (my $cgi_path = $cfg->AdminCGIPath || $cfg->CGIPath) =~ s|/$||;
    for my $list_key (sort keys %list) {
        $id++;
        my $plugin_sig = $list{$list_key};
        my $profile = $MT::Plugins{$plugin_sig};
        my ($plg);
        ($plg) = $plugin_sig =~ m!(?:.*)/(.*)!;
        my $fld = substr($list_key, 1, 100);
        $fld =~ s/\s+$//;
        my $folder = $fld ? $app->translate("Plugin Set: [_1]", $fld) : $app->translate("Plugins");
        my $row;
        if ($last_fld ne $fld) {
            $row = {
                plugin_sig => $plugin_sig,
                plugin_folder => $folder,
                plugin_set => $fld ? $folder_counts{$fld} > 1 : 0,
                plugin_error => $profile->{error},
            };
            push @$data, $row;
            $last_fld = $fld;
            $next_is_first = 1;
        }
        my $icon = $app->static_path . 'images/plugin.gif';
        if (my $plugin = $profile->{object}) {
            my $plugin_name = remove_html($plugin->name());
            $plugin->{description} = $plugin->{description};
            my $plugin_page = ($cgi_path . '/' 
                               . $plugin->envelope . '/' .     $plugin->config_link())
                if $plugin->{config_link};

            my ($config_html);
            my %plugin_param;
            my $settings = $plugin->get_config_obj('system');
            $plugin->load_config(\%plugin_param, 'system'); 
            if (my $snip_tmpl = $plugin->config_template(\%plugin_param, 'system')) {
                my $tmpl;
                if (ref $snip_tmpl ne 'HTML::Template') {
                    require HTML::Template;
                    $tmpl = HTML::Template->new(scalarref => ref $snip_tmpl ? $snip_tmpl : \$snip_tmpl,
                                                die_on_bad_params => 0,
                                                loop_context_vars => 1);
                } else {
                    $tmpl = $snip_tmpl;
                }
                $config_html = $app->build_page_in_mem($tmpl, \%plugin_param);
            }

            my $row = {
                first => $next_is_first,
                plugin_name => $plugin_name,
                plugin_page => $plugin_page,
                plugin_major => 1,
                plugin_icon => $icon,
                plugin_desc => $plugin->description(),
                plugin_version => $plugin->version(),
                plugin_author_name => $plugin->author_name(),
                plugin_author_link => $plugin->author_link(),
                plugin_plugin_link => $plugin->plugin_link(),
                plugin_full_path => $plugin->{full_path},
                plugin_doc_link => $plugin->doc_link(),
                plugin_sig => $plugin_sig,
                plugin_key => $plugin->key(),
                plugin_config_link => $plugin->config_link(),
                plugin_config_html => $config_html,
                plugin_settings_id => $settings->id,
                plugin_id => $id,
            };
            $row->{plugin_tags} = listify($profile->{tags}) if $profile->{tags};
            $row->{plugin_attributes} = listify($profile->{attributes})
                if $profile->{attributes};
            $row->{plugin_junk_filters} = listify($profile->{junk_filters})
                if $profile->{junk_filters};
            $row->{plugin_text_filters} = listify($profile->{text_filters})
                if $profile->{text_filters};
            if ($profile->{text_filters} || $profile->{junk_filters}
                || $profile->{tags} || $profile->{attributes}) {
                $row->{plugin_resources} = 1;
            }
            push @$data, $row;
        } else {
            # no registered plugin objects--
            # are there any tags/attributes/filters to expose?
            $row = {
                first => $next_is_first,
                plugin_major => $fld ? 0 : 1,
                plugin_icon => $icon,
                plugin_name => $plugin_sig,
                plugin_sig => $plugin_sig,
                plugin_error => $profile->{error},
                plugin_disabled => $profile->{enabled} ? 0 : 1,
                plugin_id => $id,
            };
            $row->{plugin_tags} = listify($profile->{tags}) if $profile->{tags};
            $row->{plugin_attributes} = listify($profile->{attributes})
                if $profile->{attributes};
            $row->{plugin_junk_filters} = listify($profile->{junk_filters})
                if $profile->{junk_filters};
            $row->{plugin_text_filters} = listify($profile->{text_filters})
                if $profile->{text_filters};
            if ($profile->{text_filters} || $profile->{junk_filters}
                || $profile->{tags} || $profile->{attributes}) {
                $row->{plugin_resources} = 1;
            }
            push @$data, $row;
        }
        $next_is_first = 0;
    }
    $param{plugin_loop} = $data;
    $param{nav_plugins} = 1;
    $param{switched} = 1 if $app->param('switched');
    $param{'reset'} = 1 if $app->param('reset');
    $param{saved} = 1 if $app->param('saved');
    $param{mod_perl} = 1 if $ENV{MOD_PERL};
    $app->add_breadcrumb($app->translate("Plugins"));
    $param{nav_plugins} = 1;
    $app->build_page('list_plugin.tmpl', \%param);
}

sub listify {
    my ($arr) = @_;
    my @ret;
    foreach (@$arr) {
        push @ret, { name => $_ };
    }
    \@ret;
}

sub list_pings {
    my $app = shift;
    my $q = $app->param;
    my $perms = $app->{perms};

    if ($perms) {
        if (!$perms->can_edit_all_posts && !$perms->can_post) {
            return $app->error($app->translate("Permission denied."));
        }
    } # otherwise we simply filter the list of objects

    my $list_pref = $app->list_pref('ping');
    my $class = $app->_load_driver_for("ping") or return;
    my $blog_id = $q->param('blog_id');
    my $blog;
    if ($blog_id) {
        require MT::Blog;
        $blog = MT::Blog->load($blog_id, {cached_ok=>1});
    }
    my %param = %$list_pref;
    my %terms;
    if ($blog_id) { $terms{blog_id} = $blog_id; }
    elsif (!$app->user->is_superuser) {
        $terms{blog_id} = [ map { $_->blog_id }
                           grep { $_->can_post || $_->can_edit_all_posts }
                                MT::Permission->load({author_id =>
                                                          $app->user->id})];
    }
    my $cols = $class->column_names;
    my $limit = $list_pref->{rows};
    my $offset = $limit eq 'none' ? 0 : ($app->param('offset') || 0);
    my $sort_direction = $q->param('sortasc') ? 'ascend' : 'descend';

    ## We load $limit + 1 records so that we can easily tell if we have a
    ## page of next entries to link to. Obviously we only display $limit
    ## entries.
    my %arg;
    if (($app->param('tab') || '') eq 'junk') {
        $terms{'junk_status'} = -1;
    } else {
        $terms{'junk_status'} = [ 0, 1 ];
        $arg{'range_incl'} = {'junk_status' => 1};
    }

    my @val = $q->param('filter_val');
    my $filter_col = $q->param('filter');
    if ($filter_col && (my $val = $q->param('filter_val'))) {
        if ($filter_col eq 'status') {
            $terms{visible} = $val eq 'approved' ? 1 : 0;
        } elsif ($filter_col eq 'category_id' ||
            $filter_col eq 'entry_id') {
            require MT::Trackback;
            my $tb = MT::Trackback->load({ $blog_id ? ( blog_id => $blog_id ) : (), $filter_col => $val });
            if ($tb) {
                $filter_col = 'tb_id';
                $val = $tb->id;
            }
        } else {
            if ($val[1]) {
                $terms{$filter_col} = [ $val[0], $val[1] ];
                $arg{'range_incl'} = { $filter_col => 1 };
                $param{filter_val2} = $val[1];
                $param{filter_range} = 1;
            } else {
                $terms{$filter_col} = $val;
            }
        }
        (my $url_val = $val) =~
            s!([^a-zA-Z0-9_.-])!uc sprintf "%%%02x", ord($1)!eg;
        $param{filter_args} = "&filter=$filter_col&filter_val=$url_val";
        $param{filter} ||= $filter_col;
        $param{filter_val} ||= $val;
        $param{is_filtered} = 1;
        $param{is_ip_filter} = $filter_col eq "ip";
    }

    my $total = MT::TBPing->count(\%terms, \%arg);
    my @rows = MT::TBPing->load(\%terms, \%arg);
    $arg{'sort'} = 'created_on';
    $arg{direction} = $sort_direction;
    $arg{limit} = $limit + 1 if $limit ne 'none';
    if ($offset > $total - 1) {
        $arg{offset} = $offset = $total - ($limit eq 'none' ? 1 : $limit);
    } elsif ($offset < 0) {
        $arg{offset} = $offset = 0;
    } elsif ($offset) {
        $arg{offset} = $offset;
    }

    my $iter = $class->load_iter(\%terms, \%arg);
    my $data = $app->build_ping_table( iter => $iter, param => \%param );

    if ($limit ne 'none') {
        ## We tried to load $limit + 1 entries above; if we actually got
        ## $limit + 1 back, we know we have another page of entries.
        my $have_next_entry = @$data > $limit;
        pop @$data while @$data > $limit;
        if ($offset) {
            $param{prev_offset} = 1;
            $param{prev_offset_val} = $offset - $limit;
            $param{prev_offset_val} = 0 if $param{prev_offset_val} < 0;
        }
        if ($have_next_entry) {
            $param{next_offset} = 1;
            $param{next_offset_val} = $offset + $limit;
        }
    }

    $param{ping_count} = scalar @$data;
    $param{limit} = $limit;
    $param{offset} = $offset;
    $param{saved} = $q->param('saved');
    $param{junked} = $q->param('junked');
    $param{unjunked} = $q->param('unjunked');
    $param{approved} = $q->param('approved');
    $param{unapproved} = $q->param('unapproved');
    $param{saved_deleted_ping} = $q->param('saved_deleted')
                              || $q->param('saved_deleted_ping');
    $param{object_type} = 'ping';
    $param{object_type_plural} = $app->translate('TrackBacks');
    $param{search_type} = $app->translate('TrackBacks');
    $param{list_start} = $offset + 1;
    $param{list_end} = $offset + scalar @$data;
    $param{list_total} = $total;
    $param{next_max} = $param{list_total} - ($limit eq 'none' ? 0 : $limit) if $param{list_total};
    $param{next_max} = 0 if ($param{next_max} || 0) < $offset + 1;
    $param{plugin_action_loop} = $MT::PluginActions{'list_pings'} || $MT::PluginActions{'list_ping'} || [];
    $param{nav_trackbacks} = 1;
    $param{has_expanded_mode} = 1;
    $param{tab} = $app->param('tab') || 'pings';
    $param{"tab_" . ($app->param('tab') || 'pings')} = 1;
    unless ($blog_id) {
        $param{system_overview_nav} = 1;
        $param{nav_pings} = 1;
    }
    $app->add_breadcrumb($app->translate('TrackBacks'));
    $app->build_page("list_ping.tmpl", \%param);
}

# takes param and one of load_args, iter, or items
sub build_ping_table {
    my $app = shift;
    my (%args) = @_;

    require MT::Entry;
    require MT::Trackback;
    require MT::Category;

    my $author = $app->user;
    my $list_pref = $app->list_pref('ping');
    my $iter;
    if ($args{load_args}) {
        my $class = $app->_load_driver_for('ping');
        $iter = $class->load_iter( @{ $args{load_args} } );
    } elsif ($args{iter}) {
        $iter = $args{iter};
    } elsif ($args{items}) {
        $iter = sub { pop @{ $args{items} } };
    }
    my $limit = $args{limit} || 'none';
    my $param = $args{param};

    my @data;
    my (%blogs, %entries, %cats, %perms);
    while (my $obj = $iter->()) {
        my $row = $obj->column_values;
        $row->{excerpt} = '[' . $app->translate("No Excerpt") . ']'
            unless ($row->{excerpt} || '') ne '';
        if (($row->{title} || '') eq ($row->{source_url} || '')) {
            $row->{title} = '[' . $app->translate("No Title") . ']';
        }
        if (!defined($row->{title})) {
            $row->{title} = substr($row->{excerpt}||"", 0, 25) . '...';
        }
        $row->{excerpt} ||= '';
        $row->{title} =~ s/(\S{30})/$1 /g; # break up really long strings
        $row->{excerpt} =~ s/(\S{30})/$1 /g; # break up really long strings
        $row->{blog_name} =~ s/(\S{30})/$1 /g; # break up really long strings
        push @data, $row;

        my $tb_center = MT::Trackback->load($obj->tb_id);
        my $entry; my $cat;
        if ($tb_center->entry_id) {
            $entry = $entries{$tb_center->entry_id} ||= MT::Entry->load($tb_center->entry_id);
            if ($entry) {
                $row->{target_title} = $entry->title;
                $row->{target_link} = $app->uri('mode' => 'view', args => { '_type' => 'entry', id => $entry->id, blog_id => $entry->blog_id, tab => 'pings' });
            } else {
                $row->{target_title} = ('* ' . $app->translate('Orphaned TrackBack') . ' *');
            }
            $row->{target_type} = $app->translate('entry');
        } elsif ($tb_center->category_id) {
            $cat = $cats{$tb_center->category_id} ||= MT::Category->load($tb_center->category_id);
            if ($cat) {
                $row->{target_title} = ('* ' . $app->translate('Orphaned TrackBack') . ' *');
                $row->{target_title} = $cat->label;
                $row->{target_link} = $app->uri('mode' => 'view', args => { '_type' => 'category', id => $cat->id, blog_id => $cat->blog_id});
            }
            $row->{target_type} = $app->translate('category');
        }
        if (my $ts = $obj->created_on) {
            $row->{created_on_time_formatted} = format_ts("%Y.%m.%d %H:%M:%S", $ts);
            $row->{created_on_formatted} = format_ts("%Y.%m.%d", $ts);
            $row->{created_on_relative} = relative_date($ts, time, $obj->blog);
        }
        if (my $blog = $blogs{$obj->blog_id} ||= $obj->blog) {
            $row->{weblog_id} = $blog->id;
            $row->{weblog_name} = $blog->name;
        }
        if ($author->is_superuser()) {
            $row->{has_edit_access} = 1;
        } else {
            my $perms = $perms{$obj->blog_id} ||= MT::Permission->load({ author_id => $author->id, blog_id => $obj->blog_id }, { cached_ok => 1 });
            $row->{has_edit_access} = (
                    ($perms && (($entry && $perms->can_edit_all_posts)
                                || ($cat && $perms->can_edit_categories)))
                    || ($cat && $author->id == $cat->author_id)
                    || ($entry && $author->id == $entry->author_id)
            );
        }
    }
    return [] unless @data;

    my $junk_tab = ($app->param('tab') || '') eq 'junk';
    $param->{ping_table}[0] = { %$list_pref };
    $param->{ping_table}[0]{object_loop} = \@data;
    $param->{ping_table}[0]{object_type} = 'ping';
    $param->{ping_table}[0]{object_type_plural} = $app->translate('TrackBacks');
    my $plugin_actions = $app->plugin_itemset_actions('ping', $junk_tab ? 'junk' : 'pings');
    $param->{ping_table}[0]{plugin_itemset_action_loop} = $plugin_actions || [];
    my $core_actions = $app->core_itemset_actions('ping', $junk_tab ? 'junk' : 'pings');
    $param->{ping_table}[0]{core_itemset_action_loop} = $core_actions
        if $core_actions;
    $param->{ping_table}[0]{has_itemset_actions} =
        ($plugin_actions || $core_actions) ? 1 : 0;
    \@data;
}

sub list_entries {
    my $app = shift;
    my $q = $app->param;
    my $perms = $app->{perms};
    #    or return $app->error($app->translate("No permissions"));
    if ($perms && (!$perms->can_edit_all_posts && !$perms->can_post)) {
        return $app->error($app->translate("Permission denied."));
    }

    require MT::Entry;

    my $list_pref = $app->list_pref('entry');
    my %param = %$list_pref;
    my $blog_id = $q->param('blog_id');
    my %terms;
    $terms{blog_id} = $blog_id if $blog_id;
    my $limit = $list_pref->{rows};
    my $offset = $limit eq 'none' ? 0 : ($app->param('offset') || 0);

    if (!$blog_id && !$app->user->is_superuser) {
        require MT::Permission;
        $terms{blog_id} = [ map {$_->blog_id}
                           grep {$_->can_post || $_->can_edit_all_posts}
                                MT::Permission->load({author_id =>
                                                          $app->user->id})];
    }

    my %arg;
    my $filter_col = $q->param('filter') || '';
    my $filter_val = $q->param('filter_val');
    if ($filter_col && $filter_val) {
	if (!exists ($terms{$filter_col})) {
	    if ($filter_col eq 'category_id') {
		$arg{'join'} = ['MT::Placement', 'entry_id',
				{ category_id => $filter_val }, { unique => 1 }];
	    } else {
		$terms{$filter_col} = $filter_val;
	    }
	    (my $url_val = $filter_val) =~
		s!([^a-zA-Z0-9_.-])!uc sprintf "%%%02x", ord($1)!eg;
	    $param{filter_args} = "&filter=$filter_col&filter_val=$url_val";
            
            my ($filter_name, $filter_value);  # human-readable versions
            if ($filter_col eq 'category_id') {
                $filter_name = $app->translate('Category');
                require MT::Category;
                my $cat = MT::Category->load($filter_val);
                return $app->errtrans("Load failed: [_1]",
                                      MT::Category->errstr) unless $cat;
                $filter_value = $cat->label;
            } elsif ($filter_col eq 'author_id') {
                $filter_name = $app->translate('Author');
                my $author = MT::Author->load($filter_val);
                return $app->errtrans("Load failed: [_1]", MT::Author->errstr)
                    unless $author;
                $filter_value = $author->name;
            } elsif ($filter_col eq 'status') {
                $filter_name = $app->translate('Post Status');
                $filter_value = $app->translate(MT::Entry::status_text($filter_val));
            }
            if ($filter_name && $filter_value) {
                $param{filter} = $filter_col;
                $param{'filter_col_' . $filter_col} = 1;
                $param{filter_val} = $filter_val;
            }
	}
        $param{filter_unpub} = $filter_col eq 'status';
    }
    require MT::Category;
    require MT::Placement;

    my $total = MT::Entry->count(\%terms, \%arg);
    $arg{'sort'} = 'created_on';
    $arg{direction} = 'descend';
    $arg{limit} = $limit + 1 if $limit ne 'none';
    if ($offset > $total - 1) {
        $arg{offset} = $offset = $total - ($limit eq 'none' ? 1 : $limit);
    } elsif ($offset < 0) {
        $arg{offset} = $offset = 0;
    } else {
        $arg{offset} = $offset if $offset;
    }
    
    my $iter = MT::Entry->load_iter(\%terms, \%arg);

    my $is_power_edit = $q->param('is_power_edit');
    if ($is_power_edit) {
        $param{has_expanded_mode} = 0;
        delete $param{view_expanded};
    } else {
        $param{has_expanded_mode} = 1;
    }
    my $data = $app->build_entry_table( iter => $iter,
        is_power_edit => $is_power_edit, param => \%param );
    delete $param{entry_table} unless @$data;
    if ($limit ne 'none') {
        ## We tried to load $limit + 1 entries above; if we actually got
        ## $limit + 1 back, we know we have another page of entries.
        my $have_next_entry = @$data > $limit;
        pop @$data while @$data > $limit;
        if ($offset) {
            $param{prev_offset} = 1;
            $param{prev_offset_val} = $offset - $limit;
            $param{prev_offset_val} = 0 if $param{prev_offset_val} < 0;
        }
        if ($have_next_entry) {
            $param{next_offset} = 1;
            $param{next_offset_val} = $offset + $limit;
        }
    }

    $iter = MT::Author->load_iter({type => MT::Author::AUTHOR},
                                  {join => ['MT::Permission', 'author_id',
                                            {$blog_id ? (blog_id => $blog_id)
                                                 : ()}],
                                   'sort' => 'name'});
    my %seen;
    while (my $au = $iter->()) {
        next if $seen{$au->id};
        $seen{$au->id} = 1;
        my $row = {author_name => $au->name,
                     author_id => $au->id };
        push @{$param{entry_author_loop}}, $row;
    }

    $param{plugin_action_loop} = $MT::PluginActions{'list_entries'} || [];
    $param{is_power_edit} = $is_power_edit;
    $param{saved_deleted} = $q->param('saved_deleted');
    $param{saved} = $q->param('saved');
    $param{limit} = $limit;
    $param{offset} = $offset;
    $param{object_type} = 'entry';
    $param{object_type_plural} = $app->translate('entries');
    $param{search_type} = $app->translate('Entries');
    $param{list_start} = $offset + 1;
    $param{list_end} = $offset + scalar @$data;
    $param{list_total} = $total;
    $param{next_max} = $param{list_total} - ($limit eq 'none' ? 0 : $limit);
    $param{next_max} = 0 if ($param{next_max} || 0) < $offset + 1;
    $param{nav_entries} = 1;
    $app->add_breadcrumb($app->translate('Entries'));
    unless ($blog_id) {
        $param{system_overview_nav} = 1;
    }
    $app->build_page("list_entry.tmpl", \%param);
}

sub build_entry_table {
    my $app = shift;
    my (%args) = @_;

    my $app_author = $app->user;
    my $perms = $app->{perms};

    my $list_pref = $app->list_pref('entry');
    if ($args{is_power_edit}) {
        delete $list_pref->{view_expanded};
    }
    my $iter;
    if ($args{load_args}) {
        my $class = $app->_load_driver_for('entry');
        $iter = $class->load_iter( @{ $args{load_args} } );
    } elsif ($args{iter}) {
        $iter = $args{iter};
    } elsif ($args{items}) {
        $iter = sub { shift @{ $args{items} } };
    }
    my $limit = $args{limit} || 'none';
    my $is_power_edit = $args{is_power_edit} || 0;
    my $param = $args{param} || {};

    ## Load list of categories for display in filter pulldown (and selection
    ## pulldown on power edit page).
    my($c_data, %cats);
    my $blog_id = $app->param('blog_id');
    if ($blog_id) {
        $c_data = $app->_build_category_list($blog_id);
        my $i = 0;
        for my $row (@$c_data) {
            $row->{category_index} = $i++;
            my $spacer = $row->{category_label_spacer} || '';
            $spacer =~ s/\&nbsp;/\\u00A0/g;
            $row->{category_label_js} = $spacer . encode_js($row->{category_label});
            $cats{ $row->{category_id} } = $row;
        }
        $param->{category_loop} = $c_data;
    }
    
    ## Load list of authors for display in filter pulldown (and selection
    ## pulldown on power edit page).
    my(@a_data, %authors);
    my $auth_iter = MT::Author->load_iter({type => AUTHOR}, {
        'join' => [ 'MT::Permission', 'author_id',
                    { blog_id => $blog_id } ] });
    while (my $author = $auth_iter->()) {
        $authors{ $author->id } = $author->name;
        push @a_data, { author_id => $author->id,
                        author_name => encode_js($author->name) };
    }
    @a_data = sort { $a->{author_name} cmp $b->{author_name} } @a_data;
    my $i = 0;
    for my $row (@a_data) {
        $row->{author_index} = $i++;
    }
    $param->{author_loop} = \@a_data;

    my(@cat_list, @auth_list);
    if ($is_power_edit) {
        @cat_list = sort { $cats{$a}->{category_index} <=> $cats{$b}->{category_index} } keys %cats;
        @auth_list = sort { $authors{$a} cmp $authors{$b} } keys %authors;
    }

    my @data;
    $i = 1;
    my %blogs;
    require MT::Blog;
    while (my $obj = $iter->()) {
        my $row = $obj->column_values;
        $row->{text} ||= '';
        if (my $ts = $obj->created_on) {
            $row->{created_on_formatted} = format_ts("%Y.%m.%d", $ts);
            $row->{created_on_time_formatted} =
                format_ts("%Y-%m-%d %H:%M:%S", $ts);
            $row->{created_on_relative} = 
                relative_date($ts, time, $obj->blog);
        }
        my $author = $obj->author;
        $row->{author_name} = $author ? $author->name : '(author deleted)';
        $row->{category_name} = $obj->category ? $obj->category->label : '';
        $row->{title_short} = $obj->title;
        if (!defined($row->{title_short}) || $row->{title_short} eq '') {
            my $title = remove_html($obj->text);
            $row->{title_short} = substr(defined($title) ? $title : "", 0, 22) . '...';
        } else {
            $row->{title_short} = substr($row->{title_short}, 0, 22) . '...'
                if $row->{title_short} =~ m(\S{25,});
        }
        $row->{title_short} = encode_html($row->{title_short}, 1);
        if ($row->{excerpt}) {
            $row->{excerpt} = remove_html($row->{excerpt});
        }
        if (!$row->{excerpt}) {
            my $text = remove_html($row->{text}) || '';
            $row->{excerpt} = first_n_words($text, 50);
            if (length($text) > length($row->{excerpt})) {
                $row->{excerpt} .= ' ...';
            }
        }
        $row->{text} =~ s/(\S{30})/$1 /g if $row->{text}; # break up really long strings
        $row->{title_long} = remove_html($obj->title);
        $row->{status_text} =
            $app->translate(MT::Entry::status_text($obj->status));
        $row->{"status_" . MT::Entry::status_text($obj->status)} = 1;
        $row->{entry_odd} = $i++ % 2 ? 1 : 0;
        $row->{has_edit_access} = $app_author->is_superuser ||
            ($perms && ($perms->can_edit_all_posts) ||
            $obj->author_id == $app_author->id);
        if ($is_power_edit) {
            $row->{is_editable} = $row->{has_edit_access};

            ## This is annoying. In order to generate and pre-select the
            ## category, author, and status pull down menus, we need to
            ## have a separate *copy* of the list of categories and
            ## authors for every entry listed, so that each row in the list
            ## can "know" whether it is selected for this entry or not.
            my @this_c_data;
            my $this_category_id = $obj->category ? $obj->category->id : undef;
            for my $c_id (@cat_list) {
                push @this_c_data, { %{$cats{$c_id}} };
                $this_c_data[-1]{category_is_selected} = $this_category_id &&
                    $this_category_id == $c_id ? 1 : 0;
            }
            $row->{row_category_loop} = \@this_c_data;

            my @this_a_data;
            my $this_author_id = $obj->author_id;
            for my $a_id (@auth_list) {
                push @this_a_data, { author_name => $authors{$a_id},
                                     author_id => $a_id };
                $this_a_data[-1]{author_is_selected} = $this_author_id &&
                    $this_author_id == $a_id ? 1 : 0;
            }
            $row->{row_author_loop} = \@this_a_data;
        }
        if (my $blog = $blogs{$obj->blog_id} ||= MT::Blog->load($obj->blog_id)) {
            $row->{weblog_id} = $blog->id;
            $row->{weblog_name} = $blog->name;
        }
        push @data, $row;
    }
    return [] unless @data;

    $param->{entry_table}[0] = { %$list_pref };
    $param->{entry_table}[0]{object_loop} = \@data;
    my $plugin_actions = $app->plugin_itemset_actions('entry');
    $param->{entry_table}[0]{plugin_itemset_action_loop} = $plugin_actions
        if $plugin_actions;
    my $core_actions = $app->core_itemset_actions('entry');
    $param->{entry_table}[0]{core_itemset_action_loop} = $core_actions
        if $core_actions;
    $param->{entry_table}[0]{has_itemset_actions} =
        ($plugin_actions || $core_actions) ? 1 : 0;
    \@data;
}

sub save_entries {
    my $app = shift;
    my $perms = $app->{perms}
        or return $app->error($app->translate("No permissions"));
    return $app->error($app->translate("Permission denied."))
        unless $perms->can_post || $perms->can_edit_all_posts;
    
    $app->validate_magic() or return;

    my $q = $app->param;
    my @p = $q->param;
    require MT::Entry;
    require MT::Placement;
    my $blog_id = $q->param('blog_id');
    my $this_author = $app->user;
    my $this_author_id = $this_author->id;
    for my $p (@p) {
        next unless $p =~ /^category_id_(\d+)/;
        my $id = $1;
        my $entry = MT::Entry->load($id);
        return $app->error($app->translate("Permission denied."))
            unless $perms->can_edit_entry($entry, $this_author);
        my $author_id = $q->param('author_id_' . $id);
        $entry->author_id($author_id ? $author_id : 0);
        $entry->status(scalar $q->param('status_' . $id));
        $entry->title(scalar $q->param('title_' . $id));
        my $co = $q->param('created_on_' . $id);
        unless ($co =~
            m!(\d{4})-(\d{2})-(\d{2})\s+(\d{2}):(\d{2})(?::(\d{2}))?!) {
            return $app->error($app->translate(
                "Invalid date '[_1]'; authored on dates must be in the format YYYY-MM-DD HH:MM:SS.", $co));
        }
        my $s = $6 || 0;
        my $ts = sprintf "%04d%02d%02d%02d%02d%02d", $1, $2, $3, $4, $5, $s;
        $entry->created_on($ts);
        $entry->save
            or return $app->error($app->translate(
                "Saving entry '[_1]' failed: [_2]", $entry->title,
                $entry->errstr));
        my $cat_id = $q->param($p);
        my $place = MT::Placement->load({ entry_id => $id,
                                          is_primary => 1 });
        if ($place && !$cat_id) {
            $place->remove
                or return $app->error($app->translate(
                    "Removing placement failed: [_1]", $place->errstr));
        }
        elsif ($cat_id) {
            unless ($place) {
                $place = MT::Placement->new;
                $place->entry_id($id);
                $place->blog_id($blog_id);
                $place->is_primary(1);
            }
            $place->category_id(scalar $q->param($p));
            $place->save
                or return $app->error($app->translate(
                    "Saving placement failed: [_1]", $place->errstr));
        }
        MT->run_callbacks('CMSPostEntrySave', $app, $entry);
    }
    $app->add_return_arg('saved' => 1, is_power_edit => 1);
    $app->call_return;
}

sub save_entry {
    my $app = shift;
    my $q = $app->param;
    my $author = $app->user;
    if ($q->param('preview_entry')) {
        return $app->preview_entry;
    } elsif ($q->param('reedit')) {
        $q->param('_type', 'entry');
        return $app->edit_object;
    } elsif ($q->param('cancel')) {
        return $app->redirect($app->uri('mode' => 'list_entries',
                                  args => { blog_id => $app->param('blog_id')}));
    }
    my $perms = $app->{perms}
        or return $app->error($app->translate("No permissions"));
    my $id = $q->param('id');
    if (!$id) {
        return $app->error($app->translate("Permission denied."))
            unless $perms->can_post;
    }

    $app->validate_magic() or return;

    my $blog_id = $q->param('blog_id');

    require MT::Entry;
    my($obj, $orig_obj);
    if ($id) {
        $obj = MT::Entry->load($id)
            || return $app->error($app->translate("No such entry."));
        return $app->error($app->translate("Permission denied."))
            unless $perms->can_edit_entry($obj, $author);
        $orig_obj = $obj->clone;
    } else {
        $obj = MT::Entry->new;
    }
    my $status_old = $id ? $obj->status : 0;
    my $names = $obj->column_names;
    ## Get rid of category_id param, because we don't want to just set it
    ## in the Entry record; save it for later when we will set the Placement.
    my $cat_id = $q->param('category_id');
    $app->delete_param('category_id');
    if ($id) {
        ## Delete the author_id param (if present), because we don't want to
        ## change the existing author.
        $app->delete_param('author_id');
    }
    my @add_cat;
    my @param = $q->param();
    foreach (@param) {
        if (m/^add_category_id_(\d+)$/) {
            push @add_cat, $1;
        }
    }
    my %values = map { $_ => scalar $q->param($_) } @$names;
    ## Strip linefeed characters.
    for my $col (qw( text excerpt text_more keywords )) {
        $values{$col} =~ tr/\r//d if $values{$col};
    }
    $values{allow_comments} = 0 if !defined($values{allow_comments});
    $obj->set_values(\%values);
    $obj->allow_pings(0)
        if !defined $q->param('allow_pings') ||
           $q->param('allow_pings') eq '';
    my $co = $q->param('created_on_manual');

    if (!$id) {
        #  basename check for this new entry...
        if (my $basename = $q->param('basename') &&
            !$q->param('basename_manual')) {
            my $cnt = MT::Entry->count({ blog_id => $blog_id, basename => $basename });
            if ($cnt) {
                $obj->basename(MT::Util::make_unique_basename($obj));
            }
        }
    }

    require MT::Blog;
    my $blog = MT::Blog->load($obj->blog_id);

    # check to make sure blog has site url and path defined.
    # otherwise, we can't publish a released entry
    if (($obj->status || 0) != MT::Entry::HOLD()) {
        if (!$blog->site_path || !$blog->site_url) {
            return $app->error($app->translate(
                "Your weblog has not been configured with a site path and URL. You cannot publish entries until these are defined."
            ));
        }
    }

    my ($previous_old, $next_old);
    if ($co && ($co ne $q->param('created_on_old') || !$obj->id)) {
        unless ($co =~
            m!(\d{4})-(\d{2})-(\d{2})\s+(\d{2}):(\d{2})(?::(\d{2}))?!) {
            return $app->error($app->translate(
                "Invalid date '[_1]'; authored on dates must be in the format YYYY-MM-DD HH:MM:SS.", $co));
        }
        my $s = $6 || 0;
	return $app->error($app->translate(
		"Invalid date '[_1]'; authored on dates should be real dates.", $co))
	    if ($s > 59 || $s < 0  || $5 > 59 || $5 < 0 || $4 > 23 || $4 < 0
		|| $2 > 12 || $2 < 1 || $3 < 1
		|| (MT::Util::days_in($2, $1) < $3 && !MT::Util::leap_day($0, $1, $2)));
        $previous_old = $obj->previous(1);
        $next_old = $obj->next(1);
        my $ts = sprintf "%04d%02d%02d%02d%02d%02d", $1, $2, $3, $4, $5, $s;
        $obj->created_on($ts);
    }
    my $is_new = $obj->id ? 0 : 1;

    my $original = $obj; # this should be a clone from earlier

    MT->_register_core_callbacks({"CMSPreSave_entry" =>
                                      \&CMSPreSave_entry});
    MT->run_callbacks('CMSPreSave_entry', $app, $obj, $original) 
        || return $app->error("PreSave failed " . MT->errstr);

    $obj->save or
        return $app->error($app->translate(
            "Saving entry failed: [_1]", $obj->errstr));
    $app->log($app->translate("'[_1]' (user #[_2]) added entry #[_3]", $author->name, $author->id, $obj->id))
        if $is_new;

    my $error_string = MT::callback_errstr();

    ## Now that the object is saved, we can be certain that it has an
    ## ID. So we can now add/update/remove the primary placement.
    require MT::Placement;
    my $place = MT::Placement->load({ entry_id => $obj->id, is_primary => 1 });
    if ($cat_id) {
        unless ($place) {
            $place = MT::Placement->new;
            $place->entry_id($obj->id);
            $place->blog_id($obj->blog_id);
            $place->is_primary(1);
        }
        $place->category_id($cat_id);
        $place->save;
    } else {
        if ($place) {
            $place->remove;
        }
    }

    # save secondary placements...
    my @place = MT::Placement->load({ entry_id => $obj->id,
                                      is_primary => 0 });
    for my $place (@place) {
        $place->remove;
    }       
    for my $cat_id (@add_cat) {
        ## Check for the stupid dummy option we have to add in order to
        ## get rid of the jumping select box on Mac IE.
        next if $cat_id == -1;

        # blog_id check for quickpost since it's possible to select
        # additional categories across weblogs...
        my $cat = MT::Category->load($cat_id, { cached_ok => 1 });
        next if $cat->blog_id != $obj->blog_id;

        my $place = MT::Placement->new;
        $place->entry_id($obj->id);
        $place->blog_id($obj->blog_id);
        $place->is_primary(0);
        $place->category_id($cat_id);
        $place->save
            or return $app->error($app->translate(
                "Saving placement failed: [_1]", $place->errstr));
    }

    MT->run_callbacks('CMSPostEntrySave', $app, $obj);

    ## If the saved status is RELEASE, or if the *previous* status was
    ## RELEASE, then rebuild entry archives, indexes, and send the
    ## XML-RPC ping(s). Otherwise the status was and is HOLD, and we
    ## don't have to do anything.
    if (($obj->status || 0) == MT::Entry::RELEASE() ||
        $status_old eq MT::Entry::RELEASE()) {

        $app->publisher->make_commenter_icon($blog);

        # If there are no static pages, just rebuild indexes.
        if ($blog->count_static_templates('Individual') == 0
            || MT::Util->launch_background_tasks()) {
            $app->rebuild_entry(Entry => $obj, BuildDependencies => 1,
                                OldEntry => $orig_obj,
                                OldPrevious => ($previous_old)
                                                   ? $previous_old->id : undef,
                                OldNext => ($next_old) ? $next_old->id : undef)
                or return;
            return $app->ping_continuation($obj, $blog, OldStatus => $status_old,
                                           IsNew => $is_new,
                                           IsBM => $q->param('is_bm')||0);
        } else {
            return $app->redirect($app->uri('mode' => 'start_rebuild', args => {
                      blog_id => $obj->blog_id, 'next' => 0, type => 'entry-' . $obj->id,
                      entry_id => $obj->id, is_bm => ($q->param('is_bm') || 0),
                      is_new => $is_new, old_status => $status_old,
                      ($previous_old ? (old_previous => $previous_old->id) : ()),
                      ($next_old ? (old_next => $next_old->id) : ())}));
        }
    }
    $app->_finish_rebuild_ping($obj, !$id);
}

sub ping_continuation {
    my $app = shift;
    my ($entry, $blog, %options) = @_;
    my $list = $app->needs_ping( Entry => $entry, Blog => $blog,
                                 OldStatus => $options{OldStatus} );
    require MT::Entry;
    if ($entry->status == MT::Entry::RELEASE() && $list) {
        my @urls = map { { url => $_ } } @$list;
        $app->build_page('pinging.tmpl', { blog_id => $blog->id,
                         entry_id => $entry->id,
                         old_status => $options{OldStatus},
                         is_new => $options{IsNew},
                         url_list => \@urls,
                         is_bm => $options{IsBM} } );
    } else {
        $app->_finish_rebuild_ping($entry, $options{IsNew});
    }
}

sub _finish_rebuild_ping {
    my $app = shift;
    my($entry, $is_new, $ping_errors) = @_;
    if ($app->param('is_bm')) {
        require MT::Blog;
        require MT::Entry;
        my $blog = MT::Blog->load($entry->blog_id);
        my %param = ( blog_id => $blog->id,
                      blog_name => $blog->name,
                      blog_url => $blog->site_url,
                      entry_id => $entry->id,
                      status_released =>
                          $entry->status == MT::Entry::RELEASE() );
        $app->build_page("bm_posted.tmpl", \%param);
    } else {
        $app->redirect($app->uri( 'mode' => 'view', args => { '_type' => 'entry', blog_id => $entry->blog_id, id => $entry->id,
                       ($is_new ? (saved_added => 1) : (saved_changes => 1)),
                       ($ping_errors ? (ping_errors => 1) : ())}));
    }
}

sub edit_placements {
    my $app = shift;
    my $perms = $app->{perms}
        or return $app->error($app->translate("No permissions"));
    my $q = $app->param;
    my $entry_id = $q->param('entry_id');
    require MT::Entry;
    my $entry = MT::Entry->load($entry_id);
    return $app->error($app->translate("Permission denied."))
        unless $perms->can_edit_entry($entry, $app->user);
    my %param;
    require MT::Category;
    my %cats;
    my $blog_id = $q->param('blog_id');
    my $iter = MT::Category->load_iter({ blog_id => $blog_id });
    my $i = 0;
    while (my $cat = $iter->()) {
        $cats{ $cat->id } = $cat->label;
    }
    require MT::Placement;
    $iter = MT::Placement->load_iter({ entry_id => $entry_id,
                                       is_primary => 0 });
    my $prim_category_id = $entry->category ? $entry->category->id : undef;
    my(@p_data, %place);
    while (my $place = $iter->()) {
        $place{$place->category_id} = 1;
        push @p_data, { place_category_id => $place->category_id,
                        place_category_label => $cats{$place->category_id} };
    }
    $param{placement_loop} = \@p_data;
    my @c_data;
    for my $id (keys %cats) {
        if (!exists $place{$id} && (!$prim_category_id || $prim_category_id
            != $id)) {
            push @c_data, { category_id => $id,
                            category_label => $cats{ $id } };
        }
    }
    @c_data = sort { $a->{category_label} cmp $b->{category_label} } @c_data;
    $param{category_loop} = \@c_data;
    $param{entry_id} = $entry_id;
    $param{saved} = $q->param('saved') ? 1 : 0;
    $app->add_breadcrumb($app->translate('Edit Categories'));
    $app->build_page('edit_placements.tmpl', \%param);
}

sub save_placements {
    my $app = shift;
    my $q = $app->param;
    my $perms = $app->{perms}
        or return $app->error($app->translate("No permissions"));
    
    $app->validate_magic() or return;

    my $entry_id = $q->param('entry_id');
    my $blog_id = $q->param('blog_id');
    require MT::Entry;
    my $entry = MT::Entry->load($entry_id);
    return $app->error($app->translate("Permission denied."))
        unless $perms->can_edit_entry($entry, $app->user);
    my @cat_ids = $q->param('category_id');
    require MT::Placement;
    my @place = MT::Placement->load({ entry_id => $entry_id,
                                      is_primary => 0 });
    for my $place (@place) {
        $place->remove;
    }
    for my $cat_id (@cat_ids) {
        ## Check for the stupid dummy option we have to add in order to
        ## get rid of the jumping select box on Mac IE.
        next if $cat_id == -1;

        my $place = MT::Placement->new;
        $place->entry_id($entry_id);
        $place->blog_id($blog_id);
        $place->is_primary(0);
        $place->category_id($cat_id);
        $place->save
            or return $app->error($app->translate(
                "Saving placement failed: [_1]", $place->errstr));
    }
    $app->redirect($app->uri('mode' => 'edit_placements', args => { entry_id => $entry_id, blog_id => $blog_id, saved => 1}));
}

sub _build_category_list {
    my ($app, $blog_id, $new_cat_id, $include_markers) = @_;
  
    my @data;
    my %authors;
  
    require MT::Category;
    require MT::Placement;
    require MT::Trackback;
    require MT::TBPing;
  
    my %expanded;
  
    if ($new_cat_id) {
      my $new_cat = MT::Category->load ($new_cat_id);
      my @parents = $new_cat->parent_categories;
      %expanded = map { $_->id => 1 } @parents;
    }
  
    my @cats = MT::Category->_flattened_category_hierarchy ($blog_id);
    my $cols = MT::Category->column_names;
    my $depth = 0;
    my $i = 1;
    my $top_cat = 1;
    while (my $obj = shift @cats) {
        my $row = { };
        if (!ref ($obj)) {
            if ($obj eq 'BEGIN_SUBCATS') {
                $depth++;
                $top_cat = 1;
            } elsif ($obj eq 'END_SUBCATS') {
                $depth--;
            }
            push @data, { $obj => 1 } if $include_markers;
            next;
        }
        for my $col (@$cols) {
            $row->{'category_' . $col} = $obj->$col();
        }
        $row->{category_label} = encode_html($row->{category_label}, 1);
        $row->{category_label_spacer} = '&nbsp; ' x $depth;
        $row->{category_entrycount} = MT::Placement->count({
            category_id => $obj->id });
        if (my $tb = MT::Trackback->load({ category_id => $obj->id })) {
            $row->{has_tb} = 1;
            $row->{tb_id} = $tb->id;
            $row->{category_tbcount} = MT::TBPing->count({
                tb_id => $tb->id,
                visible => 1 });
        }
        my $aid = $obj->author_id || "";
        $authors{$aid} ||= MT::Author->load({ id => $aid, 
            type => MT::Author::AUTHOR} );
        $row->{category_author} = $authors{$aid} ? $authors{$aid}->name : '';
        $row->{category_is_expanded} = 1 if ($expanded{$obj->id} || $depth < 3);
        $row->{category_pixel_depth} = 10 * $depth;
        $row->{top_cat} = $top_cat; $top_cat = 0;
        $row->{is_object} = 1;
        push @data, $row;
    }
    \@data;
}

sub list_categories {
    my $app = shift;
    my $q = $app->param;
    my $perms = $app->{perms}
        or return $app->error($app->translate("No permissions"));
    return $app->error($app->translate("Permission denied."))
        unless $perms->can_edit_categories;
    require MT::Category;
    require MT::Placement;
    require MT::Trackback;
    require MT::TBPing;
    my %param;
    my %authors;
    my $data = $app->_build_category_list($q->param ('blog_id'), 
        $q->param ('new_cat_id'));
    $param{category_loop} = $data;
    $param{saved} = $q->param('saved');
    $param{saved_deleted} = $q->param('saved_deleted');
    my $plugin_actions = $app->plugin_itemset_actions('category');
    $param{plugin_itemset_action_loop} = $plugin_actions
        if $plugin_actions;
    my $core_actions = $app->core_itemset_actions('category');
    $param{core_itemset_action_loop} = $core_actions
        if $core_actions;
    $param{has_itemset_actions} =
        ($plugin_actions || $core_actions) ? 1 : 0;
    $param{nav_categories} = 1;
    $app->add_breadcrumb($app->translate('Categories'));
    $app->build_page('edit_categories.tmpl', \%param);
}

sub move_category {
    my $app = shift;
    my $cat = MT::Category->load ($app->param('move_cat_id'));
    my $new_parent = $app->param('move-radio');

    $app->validate_magic() or return;

    return 1 if ($new_parent == $cat->parent);

    $cat->parent ($new_parent);

    my @siblings = MT::Category->load({ parent => $cat->parent,
                                        blog_id => $cat->blog_id });
    foreach (@siblings) {
        return $app->errtrans("No categories with the same name can have the same parent")
            if $_->label eq $cat->label;
    }
    
    $cat->save or
      return $app->error ($app->translate (
	    "Saving category failed: [_1]", $cat->errstr));
}

sub save_category {
    my $app = shift;
    my $q = $app->param;
    my $perms = $app->{perms} or
        return $app->error ($app->translate ("No permissions"));
    return $app->error ($app->translate ("Permission denied."))
        unless $perms->can_edit_categories;
  
    $app->validate_magic() or return;
  
    require MT::Category;
    my $blog_id = $q->param ('blog_id');
    my $cat;
    if (my $moved_cat_id = $q->param ('move_cat_id')) {
        $cat = MT::Category->load($q->param('move_cat_id'));
        $app->move_category() or return;
    } else {
        for my $p ($q->param) {
            my ($parent) = $p =~ /^category-new-parent-(\d+)$/;
            next unless (defined $parent);

            my $label = $q->param ($p);
            $label =~ s/(^\s+|\s+$)//g;
            next unless ($label ne '');

            return $app->errtrans("The name '[_1]' is too long!", $label) 
                if length($label) > 100;

            $cat = MT::Category->new;
            $cat->blog_id($blog_id);
            $cat->label($label);
            $cat->author_id($app->user->id);
            $cat->parent($parent);

            my @siblings = MT::Category->load({ parent => $cat->parent,
                                                blog_id => $cat->blog_id });
            foreach (@siblings) {
                return $app->errtrans("No categories with the same name can have the same parent")
                    if $_->label eq $cat->label;
            }

            $cat->save or
                return $app->error($app->translate(
                    "Saving category failed: [_1]", $cat->errstr));
        }
    }

    return $app->errtrans("The category must be given a name!") 
        if !$cat;

    $app->redirect($app->uri('mode' => 'list_cat', args => { blog_id => $blog_id,
                   saved => 1, new_cat_id => $cat->id}));
}

sub cfg_prefs {
    my $q = $_[0]->{query};
    $q->param('_type', 'blog');
    $q->param('id', scalar $q->param('blog_id'));
    $_[0]->edit_object({ output => 'cfg_prefs.tmpl' });
}

sub cfg_entries {
    my $q = $_[0]->{query};
    $q->param('_type', 'blog');
    $q->param('id', scalar $q->param('blog_id'));
    $_[0]->edit_object({ output => 'cfg_entries.tmpl' });
}

sub cfg_plugins {
    my $q = $_[0]->{query};
    $q->param('_type', 'blog');
    $q->param('id', scalar $q->param('blog_id'));
    $_[0]->edit_object({ output => 'list_plugin.tmpl' });
}

sub cfg_feedback {
    my $q = $_[0]->{query};
    $q->param('_type', 'blog');
    $q->param('id', scalar $q->param('blog_id'));
    $_[0]->edit_object({ output => 'cfg_feedback.tmpl' });
}

sub cfg_archives {
    my $app = shift;
    my %param;
    %param = %{$_[0]} if $_[0];
    my $q = $app->param;
    #my $perms = $app->{perms}
    #    or return $app->error($app->translate("No permissions"));
    #return $app->error($app->translate(
    #    "You do not have permission to configure the blog"))
    #    unless $perms->can_edit_config;
    require MT::Blog;
    require MT::TemplateMap;
    require MT::Template;
    my $blog_id = $q->param('blog_id');
    my $blog = MT::Blog->load($blog_id);
    my %at = map { $_ => 1 } split /\s*,\s*/, $blog->archive_type;
    my $iter = MT::Template->load_iter({ blog_id => $blog_id });
    my(%tmpl_name);
    while (my $tmpl = $iter->()) {
        my $type = $tmpl->type;
        next unless $type eq 'archive' || $type eq 'category' ||
                    $type eq 'individual';
        $tmpl_name{$tmpl->id} = $tmpl->name;
    }
    my %map;
    my $total_rows = 2;
    $iter = MT::TemplateMap->load_iter({ blog_id => $blog_id });
    while (my $map = $iter->()) {
        push @{ $map{ $map->archive_type } }, {
            map_id => $map->id,
            archive_type => $map->archive_type,
            map_template_id => $map->template_id,
            map_file_template => encode_html($map->file_template, 1),
            map_is_preferred => $map->is_preferred,
            map_template_name => $app->translate($tmpl_name{ $map->template_id }),
        };
        $total_rows++;
    }
    my @data;
    $param{archive_types} = \@data;
    my $index = $app->config('IndexBasename');
    my $ext = $blog->file_extension || '';
    $ext = '.' . $ext if $ext ne '';
    for my $at (qw( Individual Daily Weekly Monthly Category )) {
        $map{$at} = [] unless $map{$at};
        my @map = sort { $a->{map_template_name} cmp $b->{map_template_name} }
                  @{ $map{$at} };
        my $tmpl_loop;
        foreach my $map (@map) {
            if ($at eq 'Individual') {
                $tmpl_loop = [
                    { name => $app->translate('yyyy/mm/entry_basename') . $ext, value => '%y/%m/%f', default => 1 },
                    { name => $app->translate('yyyy/mm/entry_basename/') . $index . $ext, value => '%y/%m/%b/%i' },
                    { name => $app->translate('yyyy/mm/dd/entry_basename') . $ext, value => '%y/%m/%d/%f' },
                    { name => $app->translate('yyyy/mm/dd/entry_basename/') . $index . $ext, value => '%y/%m/%d/%b/%i' },
                    { name => $app->translate('category/sub_category/entry_basename') . $ext, value => '%c/%f' },
                    { name => $app->translate('category/sub_category/entry_basename/') . $index . $ext, value => '%c/%b/%i' },
                    { name => $app->translate('category/sub-category/entry_basename') . $ext, value => '%-c/%f' },
                    { name => $app->translate('category/sub-category/entry_basename/') . $index . $ext, value => '%-c/%b/%i' },
                    { name => $app->translate('primary_category/entry_basename') . $ext, value => '%C/%f' },
                    { name => $app->translate('primary_category/entry_basename/') . $index . $ext, value => '%C/%b/%i' },
                    { name => $app->translate('primary-category/entry_basename') . $ext, value => '%-C/%f' },
                    { name => $app->translate('primary-category/entry_basename/') . $index . $ext, value => '%-C/%b/%i' },
                ];
                if ( $map->{map_file_template} eq '%e%x' ) {
                    push @$tmpl_loop,
                        { name => '000123' . $ext, value => '%e%x' };
                }
            } elsif ($at eq 'Monthly') {
                $tmpl_loop = [
                    { name => $app->translate('yyyy/mm/') . $index . $ext, value => '%y/%m/%i', default => 1 },
                ];
                if ( $map->{map_file_template} eq '%y_%m%x' ) {
                    push @$tmpl_loop,
                        { name => $app->translate('yyyy_mm') . $ext, value => '%y_%m%x' };
                }
            } elsif ($at eq 'Daily') {
                $tmpl_loop = [
                    { name => $app->translate('yyyy/mm/dd/') . $index . $ext, value => '%y/%m/%d/%i', default => 1 },
                ];
                if ( $map->{map_file_template} eq '%y_%m_%d%x' ) {
                    push @$tmpl_loop,
                        { name => $app->translate('yyyy_mm_dd') . $ext, value => '%y_%m_%d%x' };
                }
            } elsif ($at eq 'Weekly') {
                $tmpl_loop = [
                    { name => $app->translate('yyyy/mm/dd-week/') . $index . $ext, value => '%y/%m/%d-week/%i', default => 1 },
                ];
                if ( $map->{map_file_template} eq 'week_%y_%m_%d%x' ) {
                    push @$tmpl_loop,
                        { name => $app->translate('week_yyyy_mm_dd') . $ext, value => 'week_%y_%m_%d%x' };
                }
            } elsif ($at eq 'Category') {
                $tmpl_loop = [
                    { name => $app->translate('category/sub_category/') . $index . $ext, value => '%c/%i', default => 1 },
                    { name => $app->translate('category/sub-category/') . $index . $ext, value => '%-c/%i' },
                ];
                if ( $map->{map_file_template} eq 'cat_%C%x' ) {
                    push @$tmpl_loop,
                        { name => $app->translate('cat_category') . $ext, value => 'cat_%C%x' };
                }
            }
            my $custom = 1;
            foreach (@$tmpl_loop) {
                if ((!$map->{map_file_template} && $_->{default}) ||
                    ($map->{map_file_template} eq $_->{value})) {
                    $_->{selected} = 1;
                    $custom = 0;
                    $map->{map_file_template} = $_->{value} if !$map->{map_file_template};
                }
            }
            if ($custom) {
                unshift @$tmpl_loop, {
                    name => $map->{map_file_template},
                    value => $map->{map_file_template},
                    selected => 1,
                };
            }
            $map->{archive_tmpl_loop} = $tmpl_loop;
        }
        push @data, {
            archive_type_translated => $app->translate(uc($at)."_ADV"),
            archive_type => $at,
            template_map => \@map,
            map_count => (scalar @map) + 2,
            is_selected => $at{$at},
        };
        if (scalar @map > 1) {
            $_->{multiple_archives} = 1 foreach @map;
            $param{has_multiple_archives} = 1;
        }
    }
    $param{saved} = 1 if $q->param('saved');
    $param{saved_deleted} = 1 if $q->param('saved_deleted');
    $param{saved_added} = 1 if $q->param('saved_added');
    $param{archives_changed} = 1 if $q->param('archives_changed');
    $param{no_writedir} = $q->param('no_writedir');
    $param{no_cachedir} = $q->param('no_cachedir');
    $param{no_writecache} = $q->param('no_writecache');
    $blog = MT::Blog->load(scalar $q->param('blog_id'));
    $param{dynamic_none} = $blog->custom_dynamic_templates eq 'none';
    $param{dynamic_archives} = 
        $blog->custom_dynamic_templates eq 'archives';
    $param{dynamic_custom} = $blog->custom_dynamic_templates eq 'custom';
    $param{show_build_options} = $app->config('ObjectDriver') =~ m/^DBI::(postgres|sqlite|mysql)/;
    $iter = MT::Template->load_iter({ blog_id => $blog->id });
    my(@tmpl);
    while (my $tmpl = $iter->()) {
        my $type = $tmpl->type;
        next unless $type eq 'archive' || $type eq 'category' ||
                    $type eq 'individual';
        push @tmpl, { template_id => $tmpl->id, template_name => $tmpl->name };
    }
    @tmpl = sort { $a->{template_name} cmp $b->{template_name} } @tmpl;
    $param{templates} = \@tmpl;
    $param{output} = 'cfg_archives.tmpl';
    $q->param('_type', 'blog');
    $q->param('id', $blog_id);
    $app->edit_object(\%param);
}

sub cfg_archives_save {
    my $app = shift;
    my ($blog) = @_;

    my $q = $app->param;
    require MT::TemplateMap;
    my $old_types = $blog->archive_type || '';
    my @types = $q->param('archive_type');
    if (!@types) {
        $blog->archive_type_preferred('');
        $blog->archive_type('None');
    } else {
        $blog->archive_type(join ',', @types);
        if (!$blog->archive_type_preferred) {
            $blog->archive_type_preferred($types[0]);
        }
    }
 
    $blog->touch;
    $blog->save
        or return $app->error($app->translate(
            "Saving blog failed: [_1]", $blog->errstr));
    my @p = $q->param;
    for my $p (@p) {
        if ($p =~ /^archive_tmpl_preferred_(\w+)$/) {
            my $at = $1;
            my $map_id = $q->param($p);
            my @all = MT::TemplateMap->load({ blog_id => $blog->id,
                                              archive_type => $at });
            for my $map (@all) {
                next if $map->id eq $map_id;
                $map->is_preferred(0);
                $map->save;
            }

            my $map = MT::TemplateMap->load($map_id);
            $map->is_preferred(1);
            $map->save;
        }
        elsif ($p =~ /^archive_file_tmpl_(\d+)$/) {
            my $map_id = $1;
            my $map = MT::TemplateMap->load($map_id);
            $map->file_template($q->param($p));
            $map->save;
        }
    }
    if ($old_types ne $blog->archive_type) {
        $app->add_return_arg(archives_changed => 1);
    }
}

sub cfg_archives_do_add {
    my $app = shift;
    my $q = $app->param;
    my $perms = $app->{perms}
        or return $app->error($app->translate("No permissions"));
    return $app->error($app->translate(
        "You do not have permission to configure the blog"))
        unless $perms->can_edit_config;
    
    $app->validate_magic() or return;

    require MT::TemplateMap;
    my $blog_id = $q->param('blog_id');
    my $at = $q->param('new_archive_type');
    my $count = MT::TemplateMap->count({ blog_id => $blog_id,
                                         archive_type => $at });
    my $map = MT::TemplateMap->new;
    $map->is_preferred($count ? 0 : 1);
    $map->template_id(scalar $q->param('template_id'));
    $map->blog_id($blog_id);
    $map->archive_type($at);
    $map->save
        or return $app->error($app->translate(
            "Saving map failed: [_1]", $map->errstr));
    $app->redirect($app->uri('mode' => 'cfg_archives', args => {
        blog_id => $blog_id, saved_added => 1}));
}

sub cfg_system_feedback {
    my $app = shift;
    my %param;
    return $app->errtrans("Permission denied.")
        unless $app->user->is_superuser();
    my $cfg = $app->config;
    $param{nav_config} = 1;
    $app->add_breadcrumb($app->translate('Settings'));
    $param{nav_settings} = 1;
    $param{comment_disable} = $cfg->AllowComments ? 0 : 1;
    $param{ping_disable} = $cfg->AllowPings ? 0 : 1;
    my $send = $cfg->OutboundTrackbackLimit || 'any';
    if ($send =~ m/^(any|off|selected|local)$/) {
        $param{"trackback_send_" . $cfg->OutboundTrackbackLimit} = 1;
        if ($send eq 'selected') {
            my @domains = $cfg->OutboundTrackbackDomains;
            my $domains = join "\n", @domains;
            $param{trackback_send_domains} = $domains;
        }
    } else {
        $param{"trackback_send_any"} = 1;
    }
    $param{saved} = $app->param('saved');
    $app->build_page('cfg_system_feedback.tmpl', \%param);
}

sub save_cfg_system_feedback {
    my $app = shift;
    $app->validate_magic or return;
    my $cfg = $app->config;
    $cfg->AllowComments(($app->param('comment_disable') ? 0 : 1), 1);
    $cfg->AllowPings(($app->param('ping_disable') ? 0 : 1), 1);
    my $send = $app->param('trackback_send') || 'any';
    if ($send =~ m/^(any|off|selected|local)$/) {
        $cfg->OutboundTrackbackLimit($send, 1);
        if ($send eq 'selected') {
            my $domains = $app->param('trackback_send_domains') || '';
            $domains =~ s/[\r\n]+/ /gs;
            $domains =~ s/\s{2,}/ /gs;
            my @domains = split /\s/, $domains;
            $cfg->OutboundTrackbackDomains(\@domains, 1);
        }
    }
    $cfg->save_config();
    $app->redirect($app->uri('mode' => 'cfg_system_feedback',
                             args => { saved => 1 }));
}

sub reset_plugin_config {
    my $app = shift;

    my $q = $app->param;
    my $plugin_sig = $q->param('plugin_sig');
    my $profile = $MT::Plugins{$plugin_sig};
    my $blog_id = $q->param('blog_id');
    my %param;
    if ($profile && $profile->{object}) {
        $profile->{object}->reset_config($blog_id ? 'blog:' . $blog_id : 'system');
    }
    $app->add_return_arg('reset' => 1);
    $app->call_return;
}

sub save_plugin_config {
    my $app = shift;

    my $q = $app->param;
    my $plugin_sig = $q->param('plugin_sig');
    my $profile = $MT::Plugins{$plugin_sig};
    my $blog_id = $q->param('blog_id');
    my %param;
    my @params = $q->param;
    foreach (@params) {
        next if $_ =~ m/^(__mode|return_args|plugin_sig|magic_token|blog_id)$/;
        $param{$_} = $q->param($_);
    }
    if ($profile && $profile->{object}) {
        $profile->{object}->save_config(\%param, $blog_id ? 'blog:' . $blog_id : 'system');
    }

    $app->add_return_arg(saved => 1);
    $app->call_return;
}

sub preview_entry {
    my $app = shift;
    my $q = $app->param;
    require MT::Entry;
    require MT::Builder;
    require MT::Template::Context;
    require MT::Blog;
    my $blog_id = $q->param('blog_id');
    my $blog = MT::Blog->load($blog_id);
    my $id = $q->param('id');
    my $entry = MT::Entry->new;
    $entry->title($q->param('title'));
    ## Strip linefeed characters.
    for my $col (qw( text text_more )) {
        (my $val = $q->param($col) || '') =~  tr/\r//d;
        $entry->$col($val);
    }
    $entry->convert_breaks(scalar $q->param('convert_breaks'));
    my $ctx = MT::Template::Context->new;
    $ctx->stash('entry', $entry);
    $ctx->stash('blog', $blog);
    my $build = MT::Builder->new;
    my $preview_code = <<'HTML';
<p><b><$MTEntryTitle$></b></p>
<$MTEntryBody$>
<$MTEntryMore$>
HTML
    my $tokens = $build->compile($ctx, $preview_code)
        or return $app->error($app->translate(
            "Parse error: [_1]", $build->errstr));
    defined(my $html = $build->build($ctx, $tokens))
        or return $app->error($app->translate(
            "Build error: [_1]", $build->errstr));
    my %param = ( preview_body => $html );
    $param{id} = $id if $id;
    $param{new_object} = $param{id} ? 0 : 1;
    my $cols = MT::Entry->column_names;
    my @data = ({ data_name => 'author_id', data_value => $app->user->id });
    for my $col (@$cols) {
        next if $col eq 'created_on' || $col eq 'created_by' ||
                $col eq 'modified_on' || $col eq 'modified_by' ||
                $col eq 'author_id';
        push @data, { data_name => $col,
            data_value => scalar $q->param($col) };
    }
    for my $data (qw( created_on_old created_on_manual basename_manual basename_old )) {
        push @data, { data_name => $data,
                      data_value => scalar $q->param($data) };
    }
    foreach my $qparam ($q->param) {
        next unless $qparam =~ m/^add_category_id_\d+$/;
        push @data, { data_name => $qparam,
            data_value => 1 };
    }
    $param{entry_loop} = \@data;
    if ($id) {
        $app->add_breadcrumb($app->translate('Entries'),
                             $app->uri( 'mode' => 'list_entries',
                                 args => { blog_id => $blog_id }));
        $app->add_breadcrumb($entry->title || $app->translate('(untitled)'));
    } else {
        $app->add_breadcrumb($app->translate('Entries'),
             $app->uri('mode' => 'list_entries', args => { blog_id => $blog_id }));
        $app->add_breadcrumb($app->translate('New Entry'));
        $param{nav_new_entry} = 1;
    }
    $app->build_page('preview_entry.tmpl', \%param);
}

my @RebuildOptions = ();

sub add_rebuild_option {
    my $class = shift;
    my ($args) = @_;
    return $class->error("Rebuild-option name must not contain special characters")
        if $args->{Name} =~ /[\"\']/; #/[^A-Za-z0-9.:\[\]\(\)\+=!@\#\$\%\^\&\*-]/;
    my $rec = {};
    $rec->{Code} = $args->{Code};
    $rec->{Name} = $args->{Name};
    $rec->{Key} = dirify($rec->{Name});
    push @RebuildOptions, $rec;
}

sub rebuild_confirm {
    my $app = shift;
    my $blog_id = $app->param('blog_id');
    require MT::Blog;
    my $blog = MT::Blog->load($blog_id);
    my $at = $blog->archive_type || '';
    my(@at, @data);
    if ($at && $at ne 'None') {
        @at = split /,/, $at;
        @data = map { {
                   archive_type => $_,
                   archive_type_label => $app->translate($_),
                } } @at;
    }
    my $order = join ',', @at, 'index';
    require MT::Entry;
    my $total = MT::Entry->count({ blog_id => $blog_id });
    my %param = ( archive_type_loop => \@data,
                  build_order => $order,
                  build_next => 0,
                  total_entries => $total );
    $param{index_selected} = ($app->param('prompt')||"") eq 'index';
    if (my $tmpl_id = $app->param('tmpl_id')) {
        require MT::Template;
        my $tmpl = MT::Template->load($tmpl_id);
        $param{index_tmpl_id} = $tmpl->id;
        $param{index_tmpl_name} = $tmpl->name;
    }
    $param{rebuild_option_loop} = \@RebuildOptions;
    $app->add_breadcrumb($app->translate('Rebuild Site'));
    $app->build_page('rebuild_confirm.tmpl', \%param);
}

my %Limit_Multipliers = (
    Individual => 1,
    Daily => 2,
    Weekly => 5,
    Monthly => 10,
    Dynamic => 5,
);

sub start_rebuild_pages {
    my $app = shift;
    my $q = $app->param;
    my $type = $q->param('type');
    my $next = $q->param('next') || 0;
    my @order = split /,/, $type;
    my $type_name = $order[$next];
    my $total_entries = $q->param('total_entries');
    my %param = ( build_type => $type,
                  build_next => $next,
                  total_entries => $total_entries,
                  build_type_name => $app->translate($type_name) );
    my $static_count;
    my $entries_per_rebuild = $app->config('EntriesPerRebuild');
    if (my $mult = $Limit_Multipliers{$type_name}) {
        $param{offset} = 0;
        $static_count = MT::Blog->load($q->param('blog_id'))->count_static_templates($type_name) || 0;
        if (!$static_count) {
            $param{limit} = $entries_per_rebuild * $mult * $Limit_Multipliers{'Dynamic'};
            $param{dynamic} = 1;
        } else {
            $param{limit} = $entries_per_rebuild * $mult / $static_count;
            $param{is_individual} = 1;
            $param{limit} = $entries_per_rebuild * $mult;
            $param{indiv_range} = "1 - " .
                ($param{limit} > $total_entries ? $total_entries : $param{limit});
        }
    } elsif ($type_name =~ /^index-(\d+)$/) {
        my $tmpl_id = $1;
        require MT::Template;
        my $tmpl = MT::Template->load($tmpl_id);
        $param{build_type_name} = $app->translate("index template '") . $tmpl->name . "'";
        $param{is_one_index} = 1;
    } elsif ($type_name =~ /^entry-(\d+)$/) {
        my $entry_id = $1;
        require MT::Entry;
        my $entry = MT::Entry->load($entry_id);
        $param{build_type_name} = $app->translate("entry '") . $entry->title . "'";
        $param{is_entry} = 1;
        $param{entry_id} = $entry_id;
        for my $col (qw( is_bm is_new old_status old_next old_previous )) {
            $param{$col} = $q->param($col);
        }
    }
    $param{is_full_screen} = ($param{is_entry} && !$param{is_bm}) 
        || $q->param('single_template');
    $param{page_titles} = [{bc_name => 'Rebuilding'}];
    $app->build_page('rebuilding.tmpl', \%param);
}

sub object_edit_uri {
    my $app = shift;
    my ($type, $id) = @_;
    die "no such object $type" unless $API{$type};
    eval "require " . $API{$type};
    my $obj = $API{$type}->load($id) 
        or die "object_edit_uri could not find $type object $id";
    $app->uri('mode' => 'view', args => { '_type' => $type, blog_id => $obj->blog_id, id => $_[1]});
}

sub rebuild_pages {
    my $app = shift;
    my $perms = $app->{perms}
        or return $app->error($app->translate("No permissions"));
    require MT::Entry;
    require MT::Blog;
    my $q = $app->param;
    my $blog_id = $q->param('blog_id');
    my $blog = MT::Blog->load($blog_id);
    my $order = $q->param('type');
    my @order = split /,/, $order;
    my $next = $q->param('next');
    my $done = 0;
    my $type = $order[$next];
    $next++;
    $done++ if $next >= @order;
    my($offset);
    my ($limit) = $q->param('limit');

    my $total_entries = $q->param('total_entries');

    ## Tells MT::_rebuild_entry_archive_type to cache loaded templates so
    ## that each template is only loaded once.
    $app->{cache_templates} = 1;

    my($tmpl_saved);

    # Make sure errors go to a sensible place when in fs mode
    # TBD: create contin. earlier, pass it thru
    if ($app->param('fs')) {
        my ($type, $obj_id) = $app->param('type') =~ m/(entry|index)-(\d+)/;
        if ($type && $obj_id) {
            $type = 'template' if $type eq 'index';
            $app->{goback} = "window.location='" . 
                $app->object_edit_uri($type, $obj_id) . "'";
        }
    }

    # FIXME: Wrap the entire rebuild operation with begin/end callbacks
    if ($type eq 'all') {
        return $app->error($app->translate("Permission denied."))
            unless $perms->can_rebuild;
        $app->rebuild( BlogID => $blog_id )
            or return;
    } elsif ($type eq 'index') {
        return $app->error($app->translate("Permission denied."))
            unless $perms->can_rebuild;
        $app->rebuild_indexes( BlogID => $blog_id ) or return;
    } elsif ($type =~ /^index-(\d+)$/) {
        return $app->error($app->translate("Permission denied."))
            unless $perms->can_rebuild;
        my $tmpl_id = $1;
        require MT::Template;
        $tmpl_saved = MT::Template->load($tmpl_id);
        $app->rebuild_indexes( BlogID => $blog_id, Template => $tmpl_saved,
                               Force => 1 )
            or return;
        $order = $app->translate("index template '") . $tmpl_saved->name . "'";
    } elsif ($type =~ /^entry-(\d+)$/) {
        my $entry_id = $1;
        require MT::Entry;
        my $entry = MT::Entry->load($entry_id);
        return $app->error("Permission denied.")
            unless $perms->can_edit_entry($entry, $app->user);
        $app->rebuild_entry( Entry => $entry, BuildDependencies => 1,
                             OldPrevious => $q->param('old_previous'), 
                             OldNext => $q->param('old_next') )
            or return;
        $order = "entry '" . $entry->title . "'";
    } elsif ($Limit_Multipliers{$type} && $limit ne '*') {
        return $app->error($app->translate("Permission denied."))
            unless $perms->can_rebuild;
        $offset = $q->param('offset') || 0;
        if ($offset < $total_entries) {
            $app->rebuild( BlogID => $blog_id,
                           ArchiveType => $type,
                           NoIndexes => 1,
                           Offset => $offset,
                           Limit => $limit)
                or return;
            $offset += $limit;
        }
        if ($offset < $total_entries) {
            $done-- if $done;
            $next--;
        } else {
            $offset = 0;
        }
    } elsif ($type) {
        my $special = 0;
        for my $optn (@RebuildOptions) {
            if ($optn->{Key} eq $type) {
                $optn->{Code}->();
                $special = 1;
            }
        }
        if (!$special) {
            return $app->error($app->translate("Permission denied."))
                unless $perms->can_rebuild;
            $app->rebuild( BlogID => $blog_id,
                           ArchiveType => $type,
                           NoIndexes => 1 )
                or return;
        }
    }
    
    # Rebuild done--now form the continuation.
    unless ($done) {
        my $dynamic = 0;
        my $type_name = $order[$next];
        
        ## If we're moving on to the next rebuild step, recalculate the
        ## limit.
        my $mult = $Limit_Multipliers{$type_name} || 1;
        my $entries_per_rebuild = $app->config('EntriesPerRebuild');
        if (defined($offset) && $offset == 0) {
            my $static_count = $blog->count_static_templates($type_name) || 0;
            if (!$static_count) {
                $limit = $entries_per_rebuild * $mult * $Limit_Multipliers{'Dynamic'};
                $dynamic = 1;
            } else {
                if ($mult) {
                    $limit = $entries_per_rebuild * $mult / $static_count;
                }
                $dynamic = 0;
            }
        }
        my %param = ( build_type => $order, build_next => $next,
                      build_type_name => $app->translate($type_name),
                      total_entries => $total_entries,
                      offset => $offset, limit => $limit,
                      is_bm => scalar $q->param('is_bm'),
                      entry_id => scalar $q->param('entry_id'),
                      dynamic => $dynamic,
                      is_new => scalar $q->param('is_new'),
                      old_status => scalar $q->param('old_status') );
        if ($Limit_Multipliers{$type_name}) {
            if ($limit && !$dynamic) {
                $param{is_individual} = 1;
                $param{indiv_range} = sprintf "%d - %d", $offset+1,
                    $offset + $limit > $total_entries ? $total_entries :
                    $offset + $limit;
            }
        }
        $app->build_page('rebuilding.tmpl', \%param);
    } else {
        if ($q->param('entry_id')) {
            require MT::Entry;
            my $entry = MT::Entry->load(scalar $q->param('entry_id'));
            require MT::Blog;
            my $blog = MT::Blog->load($entry->blog_id);
            $app->ping_continuation($entry, $blog, 
                                    OldStatus => scalar $q->param('old_status'),
                                    IsNew => scalar $q->param('is_new'),
                                    IsBM => scalar $q->param('is_bm'));
        } else {
            my $all = $order =~ /,/;
            my $type = $order;
            my $is_one_index = $order =~ /index template/;
            my $is_entry = $order =~ /entry/;
            my $built_type;
            if ($is_entry || $is_one_index) {
                ($built_type = $type) =~ s/^(entry|index template)/$app->translate($1)/e;
            } else {
                $built_type = $app->translate($type);
            }
            my %param = ( all => $all, type => $built_type,
                          is_one_index => $is_one_index,
                          is_entry => $is_entry );
            if ($is_one_index) {
                $param{tmpl_url} = $blog->site_url;
                $param{tmpl_url} .= '/' if $param{tmpl_url} !~ m!/$!;
                $param{tmpl_url} .= $tmpl_saved->outfile;
            }
            if ($q->param('fs')) {        # full screen--go to a useful app page
                my $type = $q->param('type');
                $type =~ /index-(\d+)/;
                my $tmpl_id = $1;
                return $app->redirect($app->uri('mode' => 'view', args => {'_type' => 'template', id => $tmpl_id, blog_id => $blog->id}));
            } else {                     # popup--just go to cnfrmn. page
                return $app->build_page('rebuilt.tmpl', \%param);
            }
        }
    }
}

sub send_pings {
    my $app = shift;
    my $q = $app->param;
    $app->validate_magic() or return;
    require MT::Entry;
    require MT::Blog;
    my $blog = MT::Blog->load(scalar $q->param('blog_id'));
    my $entry = MT::Entry->load(scalar $q->param('entry_id'));
    ## MT::ping_and_save pings each of the necessary URLs, then processes
    ## the return value from MT::ping to update the list of URLs pinged
    ## and not successfully pinged. It returns the return value from
    ## MT::ping for further processing. If a fatal error occurs, it returns
    ## undef.
    my $results = $app->ping_and_save(Blog => $blog, Entry => $entry,
        OldStatus => scalar $q->param('old_status'))
        or return;
    my $has_errors = 0;
    for my $res (@$results) {
        $has_errors++, $app->log($app->translate("Ping '[_1]' failed: [_2]", $res->{url}, $res->{error}))
            unless $res->{good};
    }
    $app->_finish_rebuild_ping($entry, scalar $q->param('is_new'), $has_errors);
}

sub edit_permissions {
    my $app = shift;
    my %param = $_[0] ? %{ $_[0] } : ();
    my $q = $app->param;
    my $author = $app->user;
    my $author_id = $q->param('author_id');
    $param{edit_author_id} = $author_id;

    require MT::Blog;
    require MT::Permission;
    ## @accessible is a list of things that identify the blogs the
    ## active user has some access to. These things can be Blog records
    ## or Permission records.
    my @accessible = $author->is_superuser
                       ? MT::Blog->load()
                       : MT::Permission->load({ author_id => $author->id });

    if ($author->id == $author_id) {
        return $app->error("You cannot modify your own permissions.");
    }
    my $this_author = MT::Author->load($author_id);
    return $app->error("Invalid author_id")
        if !$this_author || $this_author->type != AUTHOR || !$author_id;
    if (!$author->is_superuser) {
        my $has_edit_access = $author->can_administer($this_author);
        if (!$has_edit_access && (!$this_author->created_by ||
                                  ($this_author->created_by != $author->id))) {
            return $app->error("You are not allowed to edit the permissions of this author.");
        }
    }
    $param{toplevel_edit_access} = $author->is_superuser;
    $param{selected_author_name} = $this_author->name;
    if ($param{toplevel_edit_access}) {
        $param{perm_superuser} = $this_author->is_superuser;
        $param{perm_can_view_log} = $this_author->can_view_log;
        $param{perm_can_create_blog} = $this_author->can_create_blog;
    }
    $param{email} = $this_author->email;

    my $all_perm_flags = MT::Permission->perms;

    my(@data, @o_data);
    my $has_permission = 0;
    for my $accessible (@accessible) {
        if ($accessible->isa('MT::Permission')) {
            next unless $accessible->can_administer_blog;
        }
        $has_permission++;
        my $blog = $accessible->isa('MT::Blog') ? $accessible
                      : MT::Blog->load($accessible->blog_id);
        my $row = { blog_name => $blog->name, blog_id => $blog->id,
                    author_id => $author_id };
        if ($param{checked_blog_ids} && $param{checked_blog_ids}{$blog->id}) {
            $row->{is_checked} = 1;
        }
        my $p = MT::Permission->load({ blog_id => $blog->id,
                                       author_id => $author_id });

        my @p_data;
        for my $ref (@$all_perm_flags) {
            next if $ref->[1] =~ /comment/;
            push @p_data, { have_access => $p && $p->has($ref->[1]),
                            flag_name => $ref->[1],
                            prompt => $app->translate($ref->[2]),
                            blog_id => $blog->id,
                            author_id => $author_id,
                            mask => $ref->[0] };
        }
        my $break = @p_data % 3 ? int(@p_data / 3) + 1 : @p_data / 3;
        my $set = 0;
        $row->{'perm_loops'} = [];
        while (@p_data) {
            $set++;
            my $last = $#p_data;
            $last = $break - 1 if $break - 1 < $last;
            push @{$row->{"perm_loops"}}, { perm_loop => [ @p_data[0..$last] ] };
            @p_data = $last == $#p_data ? () : @p_data[$last+1..$#p_data];
        }
        if ($p && ($p->role_mask > 0)) {
            push @data, $row;
        } else {
            push @o_data, $row;
        }
    }
    return $app->error($app->translate("Permission denied."))
        unless $has_permission;
    $param{blog_loop} = \@data;
    $param{blog_no_access_loop} = \@o_data;
    @o_data = sort { $a->{blog_name} cmp $b->{blog_name} } @o_data;
    @data = sort { $a->{blog_name} cmp $b->{blog_name} } @data;
    $param{saved_add_to_blog} = $q->param('saved_add_to_blog');
    $param{saved} = $q->param('saved');
    $param{nav_authors} = 1;
    $app->add_breadcrumb($app->translate('Authors'),
                         $app->uri(mode => 'list_authors'));
    $app->add_breadcrumb($app->translate('Edit Permissions'));
    $app->build_page('edit_permissions.tmpl', \%param);
}

sub save_permissions {
    my $app = shift;
    my $q = $app->param;
    my $admin_auth = $app->user;
    my $admin_auth_id = $admin_auth->id;
    my $author_id = $q->param('author_id');
    my $author = MT::Author->load($author_id, {cached_ok=>1});

    $app->validate_magic() or return;

    if ($admin_auth->is_superuser()) {
        $author->can_create_blog($q->param('can_create_blog') || 0);
        $author->is_superuser($q->param('is_superuser') || 0);
        $author->can_view_log($q->param('can_view_log') || 0);
        if (my $new_email = $q->param('email')) {
            $author->email($new_email);
        }
        $author->save;
    }
    
    require MT::Permission;
    for my $p ($q->param) {
        if ($p =~ /^role_mask-(\d+)$/) {
            my($blog_id) = ($1);
            if (!$admin_auth->is_superuser) {
                my $admin_perms = MT::Permission->load({author_id => $admin_auth_id,
                                                        blog_id => $blog_id},
                                                       {cached_ok => 1});
                return $app->error($app->translate("Permission denied."))
                    unless ($admin_perms && $admin_perms->can_administer_blog);
            }

            my $pe = MT::Permission->load({ author_id => $author_id,
                                            blog_id => $blog_id },
                                          {cached_ok => 1});
            my $mask = 0;
            for my $val ($q->param($p)) {
                $mask += $val;
            }

            if (!$pe) {
                next if $mask == 0;    # Don't create a new record if it's empty
                $pe = MT::Permission->new;
                $pe->blog_id($blog_id);
                $pe->author_id($author_id);
            }
            $pe->role_mask($mask);
            $pe->save;
        }
    }
    my $url = $app->uri('mode' => 'edit_permissions', 
                        args => { author_id => $author_id, saved => 1});
    #if (my $blog_id = $q->param('add_role_mask')) {
    #    my $pe = MT::Permission->load({ author_id => $author_id,
    #                                    blog_id => $blog_id });
    #    if (!$pe) {
    #        $pe = MT::Permission->new;
    #        $pe->blog_id($blog_id);
    #        $pe->author_id($author_id);
    #    }
    #    $pe->can_post(1);
    #    $pe->can_comment(1);
    #    $pe->save;
    #    require MT::Blog;
    #    my $blog = MT::Blog->load($blog_id);
    #    $url .= '&saved_add_to_blog=' . $blog->name;
    #}
    $app->redirect($url);
}

sub send_notify {
    my $app = shift;
    $app->validate_magic() or return;
    my $q = $app->param;
    my $entry_id = $q->param('entry_id') or
        return $app->error($app->translate("No entry ID provided"));
    require MT::Entry;
    require MT::Blog;
    my $entry = MT::Entry->load($entry_id, {cached_ok=>1}) or
        return $app->error($app->translate("No such entry '[_1]'", $entry_id));
    my $blog = MT::Blog->load($entry->blog_id, {cached_ok=>1});
    my $author = $entry->author;
    return $app->error($app->translate(
        "No email address for author '[_1]'", $author->name))
        unless $author->email;
    my $body = '';
    my $cols = 72;
    my $name = $app->translate("[_1] Update: [_2]", $blog->name, $entry->title);
    my $fill_len = $cols - length($name) - 2;
    $fill_len++ if $fill_len % 2;
    $name = ('(' x ($fill_len/2)) . ' ' . $name . ' ' . (')' x ($fill_len/2));
    $body .= $name . "\n\n";
    my @ts = offset_time_list(time, $blog);
    my $ts = sprintf "%04d%02d%02d%02d%02d%02d",
        $ts[5]+1900, $ts[4]+1, @ts[3,2,1,0];
    my $date = format_ts('%Y.%m.%d %H:%M:%S', $ts, $blog);
    my $fill_left = ' ' x int(($cols - length($date)) / 2);
    $body .= "$fill_left$date\n\n\n";
    $body .= ('-' x $cols) . "\n\n";
    require Text::Wrap;
    $Text::Wrap::columns = $cols;
    if ($q->param('send_excerpt')) {
        local $Text::Wrap::columns = $cols - 4;
        $body .= Text::Wrap::wrap("    ", "    ", $entry->get_excerpt) . "\n\n";
        $body .= ('-' x $cols) . "\n\n";
    }
    $body .= $entry->permalink . "\n\n";
    $body .= Text::Wrap::wrap('', '', $q->param('message')) . "\n\n";
    if ($q->param('send_body')) {
        $body .= ('-' x $cols) . "\n\n";
        $body .= Text::Wrap::wrap('', '', $entry->text) . "\n";
    }
    my $subj = $app->translate("[_1] Update: [_2]", $blog->name, $entry->title);
    $subj =~ s![\x80-\xFF]!!g;
    my %head = ( To => $author->email, From => $author->email,
                 Subject => $subj,
                 'Content-Transfer-Encoding' => '8bit' );
    my $charset = $app->config('PublishCharset') || 'iso-8859-1';
    $head{'Content-Type'} = qq(text/plain; charset="$charset");
    require MT::Notification;
    my $iter = MT::Notification->load_iter({ blog_id => $blog->id });
    my $i = 1;
    require MT::Mail;
    MT::Mail->send(\%head, $body)
        or return $app->error($app->translate(
            "Error sending mail ([_1]); try another MailTransfer setting?",
            MT::Mail->errstr));
    delete $head{To};
    while (my $note = $iter->()) {
        next unless $note->email;
        push @{ $head{Bcc} }, $note->email;
        if ($i++ % 20 == 0) {
            MT::Mail->send(\%head, $body) or
                return $app->error($app->translate(
                 "Error sending mail ([_1]); try another MailTransfer setting?",
                 MT::Mail->errstr));
            @{ $head{Bcc} } = ();
        }
    }
    if ($head{Bcc} && @{ $head{Bcc} }) {
        MT::Mail->send(\%head, $body)
            or return $app->error($app->translate(
             "Error sending mail ([_1]); try another MailTransfer setting?",
             MT::Mail->errstr));
    }
    $app->redirect($app->uri('mode' => 'view', args => { '_type' => 'entry' , blog_id => $entry->blog_id, id => $entry->id, saved_notify => 1}));
}

sub start_upload {
    my $app = shift;
    my $perms = $app->{perms}
        or return $app->error($app->translate("No permissions"));
    return $app->error($app->translate("Permission denied."))
        unless $perms->can_upload;
    my $blog_id = $app->param('blog_id');
    require MT::Blog;
    my $blog = MT::Blog->load($blog_id, {cached_ok=>1});
    $app->add_breadcrumb('Upload File');
    my %param;
    $param{enable_archive_paths} = $blog->column('archive_path');
    $param{local_site_path} = encode_js($blog->site_path);
    $param{local_archive_path} = encode_js($blog->archive_path);
    $app->build_page('upload.tmpl', \%param);
}

sub upload_file {
    my $app = shift;
    my $perms = $app->{perms}
        or return $app->error($app->translate("No permissions"));
    return $app->error($app->translate("Permission denied."))
        unless $perms->can_upload;
    $app->validate_magic() or return;

    my $q = $app->param;
    my($fh, $no_upload);
    if ($ENV{MOD_PERL}) {
        my $up = $q->upload('file');
        $no_upload = !$up || !$up->size;
        $fh = $up->fh if $up;
    } else {
        ## Older versions of CGI.pm didn't have an 'upload' method.
        eval { $fh = $q->upload('file') };
        if ($@ && $@ =~ /^Undefined subroutine/) {
            $fh = $q->param('file');
        }
        $no_upload = !$fh;
    }
    my $has_overwrite = $q->param('overwrite_yes') || $q->param('overwrite_no');
    return $app->error($app->translate("You did not choose a file to upload."))
        if $no_upload && !$has_overwrite;
    my $basename = $q->param('file') || $q->param('fname');
    $basename =~ s!\\!/!g;   ## Change backslashes to forward slashes
    $basename =~ s!^.*/!!;   ## Get rid of full directory paths
    if ($basename =~ m!\.\.|\0|\|!) {
        return $app->error($app->translate("Invalid filename '[_1]'", $basename));
    }
    my $blog_id = $q->param('blog_id');
    require MT::Blog;
    my $blog = MT::Blog->load($blog_id, {cached_ok=>1});
    my $fmgr = $blog->file_mgr;

    ## Set up the full path to the local file; this path could start
    ## at either the Local Site Path or Local Archive Path, and could
    ## include an extra directory or two in the middle.
    my($root_path, $relative_path);
    if ($q->param('site_path')) {
        $root_path = $blog->site_path;
        $relative_path = $q->param('extra_path_site');
    } else {
        $root_path = $blog->archive_path;
        $relative_path = $q->param('extra_path_archive');
    }
    my $relative_path_save = $relative_path;
    my $path = $root_path;
    if ($relative_path) {
        if ($relative_path =~ m!\.\.|\0|\|!) {
            return $app->error($app->translate(
                "Invalid extra path '[_1]'", $relative_path));
        }
        $path = File::Spec->catdir($path, $relative_path);
        ## Untaint. We already checked for security holes in $relative_path.
        ($path) = $path =~ /(.+)/s;
        ## Build out the directory structure if it doesn't exist. DirUmask
        ## determines the permissions of the new directories.
        unless ($fmgr->exists($path)) {
            $fmgr->mkpath($path)
                or return $app->error($app->translate(
                    "Can't make path '[_1]': [_2]", $path, $fmgr->errstr));
        }
    }
    $relative_path = File::Spec->catfile($relative_path, $basename);
    my $local_file = File::Spec->catfile($path, $basename);

    ## Untaint. We have already tested $basename and $relative_path for security
    ## issues above, and we have to assume that we can trust the user's
    ## Local Archive Path setting. So we should be safe.
    ($local_file) = $local_file =~ /(.+)/s;

    ## If $local_file already exists, we try to write the upload to a
    ## tempfile, then ask for confirmation of the upload.
    if ($fmgr->exists($local_file)) {
        if ($has_overwrite) {
            my $tmp = $q->param('temp');
            if ($tmp =~ m!([^/]+)$!) {
                $tmp = $1;
            } else {
                return $app->error($app->translate(
                    "Invalid temp file name '[_1]'", $tmp));
            }
            my $tmp_dir = $app->config('TempDir');
            my $tmp_file = File::Spec->catfile($tmp_dir, $tmp);
            if ($q->param('overwrite_yes')) {
                $fh = gensym();
                open $fh, $tmp_file
                    or return $app->error($app->translate(
                        "Error opening '[_1]': [_2]", $tmp_file, "$!"));
            } else {
                if (-e $tmp_file) {
                    unlink($tmp_file)
                        or return $app->error($app->translate(
                            "Error deleting '[_1]': [_2]", $tmp_file, "$!"));
                }
                return $app->start_upload;
            }
        } else {
            eval { require File::Temp };
            if ($@) {
                return $app->error($app->translate(
                    "File with name '[_1]' already exists. (Install " .
                    "File::Temp if you'd like to be able to overwrite " .
                    "existing uploaded files.)", $basename));
            }
            my $tmp_dir = $app->config('TempDir');
            my($tmp_fh, $tmp_file);
            eval {
                ($tmp_fh, $tmp_file) =
                    File::Temp::tempfile(DIR => $tmp_dir);
            };
            if ($@) { #!$tmp_fh) {
                return $app->errtrans(
                    "Error creating temporary file; please check your TempDir ".
                    "setting in mt.cfg (currently '[_1]') " .
                    "this location should be writable.",
                    ($tmp_dir ? $tmp_dir : '['.$app->translate('unassigned').']'));
            }
            defined(_write_upload($fh, $tmp_fh))
                or return $app->error($app->translate(
                    "File with name '[_1]' already exists; Tried to write " .
                    "to tempfile, but open failed: [_2]", $basename, "$!"));
            my($vol, $path, $tmp) = File::Spec->splitpath($tmp_file);
            return $app->build_page('upload_confirm.tmpl', {
                temp => $tmp, extra_path => $relative_path_save,
                site_path => scalar $q->param('site_path'),
                fname => $basename });
        }
    }

    ## File does not exist, or else we have confirmed that we can overwrite.
    my $umask = oct $app->config('UploadUmask');
    my $old = umask($umask);
    defined(my $bytes = $fmgr->put($fh, $local_file, 'upload'))
        or return $app->error($app->translate(
            "Error writing upload to '[_1]': [_2]", $local_file,
            $fmgr->errstr));
    umask($old);

    ## Use Image::Size to check if the uploaded file is an image, and if so,
    ## record additional image info (width, height). We first rewind the
    ## filehandle $fh, then pass it in to imgsize.
    seek $fh, 0, 0;
    eval { require Image::Size; };
    return $app->error($app->translate(
        "Perl module Image::Size is required to determine " .
        "width and height of uploaded images.")) if $@;
    my($w, $h, $id) = Image::Size::imgsize($fh);

    ## Close up the filehandle.
    close $fh;

    ## If we are overwriting the file, that means we still have a temp file
    ## lying around. Delete it.
    if ($q->param('overwrite_yes')) {
        my $tmp = $q->param('temp');
        if ($tmp =~ m!([^/]+)$!) {
            $tmp = $1;
        } else {
            return $app->error($app->translate(
                "Invalid temp file name '[_1]'", $tmp));
        }
        my $tmp_file = File::Spec->catfile($app->config('TempDir'), $tmp);
        unlink($tmp_file)
            or return $app->error($app->translate(
                "Error deleting '[_1]': [_2]", $tmp_file, "$!"));
    }

    ## We are going to use $relative_path as the filename and as the url passed
    ## in to the templates. So, we want to replace all of the '\' characters
    ## with '/' characters so that it won't look like backslashed characters.
    ## Also, get rid of a slash at the front, if present.
    $relative_path =~ s!\\!/!g;
    $relative_path =~ s!^/!!;
    my %param = ( width => $w, height => $h, bytes => $bytes,
                  image_type => $id, fname => $relative_path,
                  site_path => scalar $q->param('site_path') );
    my $url = $q->param('site_path') ? $blog->site_url : $blog->archive_url;
    $url .= '/' unless $url =~ m!/$!;
    $relative_path =~ s!^/!!;
    $url .= $relative_path;
    $param{url} = $url;
    $param{is_image} = defined($w) && defined($h);
    if ($param{is_image}) {
        eval { require MT::Image; MT::Image->new or die; };
        $param{do_thumb} = !$@ ? 1 : 0;
    }
    $app->build_page('upload_complete.tmpl', \%param);
}

sub _write_upload {
    my($upload_fh, $dest_fh) = @_;
    my $fh = gensym();
    if (ref($dest_fh) eq 'GLOB') {
        $fh = $dest_fh;
    } else {
        open $fh, ">$dest_fh" or return;
    }
    binmode $fh;
    binmode $upload_fh;
    my($bytes, $data) = (0);
    while (my $len = read $upload_fh, $data, 8192) {
        print $fh $data;
        $bytes += $len;
    }
    close $fh;
    $bytes;
}

sub search_replace {
    my $app = shift;
    my $q = $app->param;
    my $blog_id = $q->param('blog_id');
    my $author = $app->user;
    my @perms;
    if (!$blog_id) {
        if (!$author->is_superuser()) {
            require MT::Permission;
            @perms = MT::Permission->load({author_id => $author->id});
        }
    } else {
        @perms = $app->{perms}
            or return $app->error($app->translate("No permissions"));
    }

    my $search_api = {
        'entry' => {
            'perm_check' => sub {
                grep { $_->can_edit_entry($_[0], $author) } @perms
            },
            'search_cols' => [ qw(title text text_more keywords excerpt basename) ],
            'replace_cols' => [ qw(title text text_more keywords excerpt) ],
            'can_replace' => 1,
            'can_search_by_date' => 1,
        },
        'ping' => {
            'perm_check' => sub { 
                my $ping = shift;
                my $tb = MT::Trackback->load($ping->tb_id, {cached_ok=>1});
                if ($tb->entry_id) {
                    require MT::Entry;
                    my $entry = MT::Entry->load($tb->entry_id, {cached_ok=>1});
                    return grep {
                            $_->can_edit_entry($entry, $author) 
                        } @perms;
                } elsif ($tb->category_id) {
                    return grep { $_->can_edit_categories } @perms;
                }
            },
            'search_cols' => [ qw(title excerpt source_url blog_name ip) ],
            'replace_cols' => [ qw(title excerpt) ],
            'can_replace' => 1,
            'can_search_by_date' => 1,
        },
        'comment' => {
            'perm_check' => sub {
                require MT::Entry;
                my $entry = MT::Entry->load($_[0]->entry_id, {cached_ok=>1});
                grep { $_->can_edit_entry($entry, $author) } @perms;
            },
            'search_cols' => [ qw(text url email ip author) ],
            'replace_cols' => [ qw(text) ],
            'can_replace' => 1,
            'can_search_by_date' => 1,
        },
        'template' => {
            'perm_check' => sub { 
                my ($obj) = @_;
                # are there any perms that match this object and 
                # allow template editing?
                my @check = grep { $_->blog_id == $obj->blog_id
                                          && $_->can_edit_templates } @perms;
                return @check;
                
            },
            'search_cols' => [ qw(name text linked_file outfile) ],
            'replace_cols' => [ qw(name text linked_file outfile) ],
            'can_replace' => 1,
            'can_search_by_date' => 0,
        },
        'commenter' => {
            'perm_check' => sub { 
                1;
            },
            'search_cols' => [ qw(nickname email url) ],
            'can_replace' => 0,
            'can_search_by_date' => 1,
        },
        'log' => {
            'perm_check' => sub {
                my ($obj) = @_;
                return 1 if $author->can_view_log;
                my $perm = MT::Permission->load({author_id => $author->id,
                                                 blog_id => $obj->blog_id});
                return $perm->can_view_blog_log;
            },
            'search_cols' => [ qw(ip message) ],
            'can_replace' => 0,
            'can_search_by_date' => 1,
        },
    };

    my($search, $replace, $do_replace, $case, $is_regex, $is_limited, $type, $is_junk, $is_dateranged, $ids, $datefrom_year, $datefrom_month, $datefrom_day, $dateto_year, $dateto_month, $dateto_day, $from, $to, $show_all, $do_search, $orig_search) =
        map scalar $q->param($_), qw( search replace do_replace case is_regex is_limited _type is_junk is_dateranged replace_ids datefrom_year datefrom_month datefrom_day dateto_year dateto_month dateto_day from to show_all do_search orig_search );
    $replace && ($app->validate_magic() or return);
    $search = $orig_search if $replace;  # for safety's sake

    $type ||= 'entry';
    if ($type eq 'commenter') {
        if (!$author->is_superuser && (!$app->{perms} || !$app->{perms}->can_edit_config())) {
            return $app->error($app->translate("No permissions"));
        }
    }
    my $list_pref = $app->list_pref($type);
    # force action bars to top and bottom
    $list_pref->{"bar"} = 'both';
    $list_pref->{"position_actions_both"} = 1;
    $list_pref->{"position_actions_top"} = 1;
    $list_pref->{"position_actions_bottom"} = 1;
    $list_pref->{"view"} = 'compact';
    $list_pref->{"view_compact"} = 1;
    my (@cols, $datefrom, $dateto);
    $do_replace = 0 unless $search_api->{$type}{can_replace};
    $is_dateranged = 0 unless $search_api->{$type}{can_search_by_date};
    my @ids;
    if ($ids) {
        @ids = split /,/, $ids;
    }
    if ($is_limited) {
        @cols = $q->param('search_cols');
        if (@cols && ($cols[0] =~ /,/)) {
            @cols = split /,/, $cols[0];
        }
    } else {
        @cols = @{$search_api->{$type}->{search_cols}};
    }
    foreach ($datefrom_year, $datefrom_month, $datefrom_day, $dateto_year, $dateto_month, $dateto_day) {
        s!\D!!g if $_; 
    }
    if ($is_dateranged) {
        $datefrom = sprintf("%04d%02d%02d", $datefrom_year, $datefrom_month, $datefrom_day);
        $dateto = sprintf("%04d%02d%02d", $dateto_year, $dateto_month, $dateto_day);
        if (($datefrom eq '00000000') && ($dateto eq '00000000')) {
            $is_dateranged = 0;
        } else {
            if (!is_valid_date($datefrom . '000000') || !is_valid_date($dateto . '000000')) {
                return $app->error("Invalid date(s) specified for date range.");
            }
        }
    } elsif ($from && $to) {
        $is_dateranged = 1;
        s!\D!!g foreach ($from, $to);
        $datefrom = $from; $dateto = $to;
    }
    my $tab = $q->param('tab') || 'entry';
    ## Sometimes we need to pass in the search columns like 'title,text', so
    ## we look for a comma (not a valid character in a column name) and split
    ## on it if it's there.
    if ($search) {
        $search = quotemeta($search) unless $is_regex;
        $search = '(?i)' . $search unless $case;
    }
    my (@to_save, @data);
    my %param = %$list_pref;
    my $limit = $q->param('limit') || 125;     # FIXME: mt.cfg setting?
    my $matches;
    if (($do_search && $search) || $show_all || $do_replace) {
        my $api = $search_api->{$type};
        my $class = $app->_load_driver_for($type);
        my %terms;
        my %args;
        if ($type ne 'commenter') {
            %terms = $blog_id ? ( blog_id => $blog_id ) : ();
            if ($type ne 'template') {
                %args = ( 'sort' => 'created_on', direction => 'descend' );
            }
        } else {
            $terms{'type'} = MT::Author::COMMENTER();
            $args{'join'} = [ 'MT::Permission', 'author_id', { blog_id => $blog_id } ];
        }
        if (($type eq 'ping') || ($type eq 'comment'))  {
            if ($is_junk) {
                $terms{junk_status} = -1;
            } else {
                $terms{junk_status} = [ 0, 1 ];
                $args{range_incl}{junk_status} = 1;
            }
        }
        if ($is_dateranged) {
            $args{range_incl}{created_on} = 1;
            if ($datefrom gt $dateto) {
                $terms{created_on} = [ $dateto . '000000', $datefrom . '235959' ];
            } else {
                $terms{created_on} = [ $datefrom . '000000', $dateto . '235959' ];
            }
        }
        my $iter;
        if ($do_replace) {
            $iter = sub {
                if (my $id = pop @ids) {
                    $class->load($id);
                }
            };
        } elsif ($blog_id) {
            $iter = $class->load_iter(\%terms, \%args) or die $class->errstr;
        } elsif ($type eq 'log') {
            $iter = $class->load_iter(\%terms, \%args);
        } else {
            # Get an iter for each accessible blog
            my @streams;
            if (@perms) {
                @streams = map { { iter =>
                                   $class->load_iter({ blog_id => $_->blog_id,
                                                       %terms },
                                                       \%args) } } @perms;
            } elsif ($author->is_superuser) {
                #my @blogs = MT::Blog->load();
                @streams = ({iter =>
                                   $class->load_iter(\%terms, \%args) });
            }

            # Pull out the head of each iterator
            # Next: effectively mergesort the various iterators
            # To call the iterator n times takes time in O(bn)
            #   with 'b' the number of blogs
            # we expect to hit the iterator l/p times where 'p' is the 
            #   prob. of the search term appearing and 'l' is $limit
            $_->{head} = $_->{iter}->() foreach @streams;
            if ($type ne 'template') {
                $iter = sub { 
                    # find the head with greatest created_on
                    my $which = \$streams[0];
                    foreach my $iter (@streams) {
                        next if !exists $iter->{head} || !$which || !${$which}->{head} || !defined($iter->{head});
                        if ($iter->{head}->created_on > ${$which}->{head}->created_on) {
                            $which = \$iter;
                        }
                    }
                    # Advance the chosen one
                    my $result = ${$which}->{head};
                    ${$which}->{head} = ${$which}->{iter}->() if $result;
                    $result;
                };
            } else {
                $iter = sub { 
                    return undef unless @streams;
                    # find the head with greatest created_on
                    my $which = \$streams[0];
                    while (@streams && (!defined ${$which}->{head})) {
                        shift @streams;
                        last unless @streams;
                        $which = \$streams[0];
                    }
                    my $result = ${$which}->{head};
                    ${$which}->{head} = ${$which}->{iter}->();
                    $result;
                };
            }
        }
        my $i = 1;
        my %replace_cols;
        if ($do_replace) {
            %replace_cols = map { $_ => 1 } @{$api->{replace_cols}};
        }
        while (my $obj = $iter->()) {
            next unless $author->is_superuser || $api->{perm_check}->($obj);
            my $match = 0;
            unless ($show_all) {
                for my $col (@cols) {
                    next if $do_replace && !$replace_cols{$col};
                    my $text = $obj->$col();
                    $text = '' unless defined $text;
                    if ($do_replace) {
                        if ($text =~ s!$search!$replace!go) {
                            $match++;
                            $obj->$col($text);
                        }
                    } else {
                        $match = $text =~ m!$search!o;
                        last if $match;
                    }
                }
            }
            if ($match || $show_all) {
                push @to_save, $obj if $do_replace && !$show_all;
                push @data, $obj;
            }
            last if ($limit ne 'all') && @data > $limit;
        }
        if (@data) {
            $param{have_results} = 1;
            # We got one extra to see if there were more
            if (($limit ne 'all') && @data > $limit) {
                $param{have_more} = 1;
                pop @data;
            }
            $matches = @data;
        } else {
            $matches = 0;
        }
    }
    my $replace_count = 0;
    for my $obj (@to_save) {
        $replace_count++;
        $obj->save
            or return $app->error($app->translate(
                "Saving object failed: [_2]", $obj->errstr));
    }
    if (@data) {
        my $meth = 'build_' . $type . '_table';
        $app->$meth( items => \@data, param => \%param );
    }
    if ($is_dateranged) {
        ($datefrom_year, $datefrom_month, $datefrom_day) 
            = $datefrom =~ m/^(\d\d\d\d)(\d\d)(\d\d)/;
        ($dateto_year, $dateto_month, $dateto_day)
            = $dateto =~ m/^(\d\d\d\d)(\d\d)(\d\d)/;
    }
    my %res = (
        limit => $limit,
        limit_all => $limit eq 'all',
        count_matches => $matches, 
        replace_count => $replace_count,
        "search_$type" => 1,
        search_type => $type,
        search => $do_replace ? $q->param('orig_search') 
                  : scalar $q->param('search'),
        searched => ($do_replace ? $q->param('orig_search')
                    : ($do_search && scalar $q->param('search'))) || $show_all,
        replace => $replace,
        do_replace => $do_replace,
        case => $case,
        datefrom_year => $datefrom_year,
        datefrom_month => $datefrom_month,
        datefrom_day => $datefrom_day,
        dateto_year => $dateto_year,
        dateto_month => $dateto_month,
        dateto_day => $dateto_day,
        is_regex => $is_regex,
        is_limited => $is_limited,
        is_dateranged => $is_dateranged,
        is_junk => $is_junk,
        can_search_junk => ($type eq 'comment' || $type eq 'ping'),
        can_replace => $search_api->{$type}{can_replace},
        can_search_by_date => $search_api->{$type}{can_search_by_date},
        quick_search => 0,
        "tab_$tab" => 1,
        %param
    );
    $res{'tab_junk'} = 1 if $is_junk;
    $res{'search_cols_' . $_} = 1 foreach @cols;
    $res{nav_search} = 1;
    $app->add_breadcrumb($app->translate('Search & Replace'), '');
    $app->build_page('search_replace.tmpl', \%res);
}

sub export {
    my $app = shift;
    $app->{no_print_body} = 1;
    local $| = 1;
    my $charset = MT::ConfigMgr->instance->PublishCharset;
    require MT::Blog;
    my $blog_id = $app->param('blog_id')
        or return $app->error($app->translate("No blog ID"));
    my $blog = MT::Blog->load($blog_id, {cached_ok=>1})
        or return $app->error($app->translate(
            "Load of blog '[_1]' failed: [_2]", $blog_id, MT::Blog->errstr));
    my $perms = $app->{perms};
    return $app->error($app->translate("You do not have export permissions"))
        unless $perms && $perms->can_edit_config;
    $app->validate_magic() or return;
    my $file = dirify($blog->name) . ".txt";
    $app->set_header("Content-Disposition" => "attachment; filename=$file");
    $app->send_http_header($charset ? "text/plain; charset=$charset" 
                                    : 'text/plain');
    require MT::ImportExport;
    MT::ImportExport->export($blog, sub { $app->print(@_) })
        or return $app->error(MT::ImportExport->errstr);
    1;
}

sub do_import {
    my $app = shift;

    my $q = $app->param;
    require MT::Blog;
    my $blog_id = $q->param('blog_id')
        or return $app->error($app->translate("No blog ID"));
    my $blog = MT::Blog->load($blog_id, {cached_ok=>1})
        or return $app->error($app->translate(
            "Load of blog '[_1]' failed: [_2]", $blog_id, MT::Blog->errstr));

    my $import_as_me = $q->param('import_as_me');

    ## Determine the author as whom we will import the entries.
    my $author = $app->user;
    my $author_id = $author->id;
    if (!$author->is_superuser) {
        my $perms = MT::Permission->load({ author_id => $author_id,
                                           blog_id => $blog_id });
        return $app->error($app->translate("You do not have import permissions"))
            unless $perms && $perms->can_edit_config;
        if (!$import_as_me) {
            return $app->error($app->translate("You do not have permission to create authors"))
                unless $perms->can_administer_blog;
        }
    }

    my($pass);
    if (!$import_as_me) {
        $pass = $q->param('password')
            or return $app->error($app->translate(
                "You need to provide a password if you are going to\n" .
                "create new authors for each author listed in your blog.\n"));
    }

    $app->validate_magic() or return;

    my @files_to_import;
    my $dir = $app->config('ImportPath');
    opendir DH, $dir or return $app->error($app->translate(
        "Can't open directory '[_1]': [_2]", $dir, "$!"));
    for my $f (readdir DH) {
        next if $f =~ /^\./;
        my $file = File::Spec->catfile($dir, $f);
        push @files_to_import, $file if -r $file;
    }
    closedir DH;

    unless (@files_to_import) {
        return $app->error($app->translate("No readable files could be found in your import directory [_1].", $dir));
    }

    $app->{no_print_body} = 1;

    local $| = 1;
    my $charset = MT::ConfigMgr->instance->PublishCharset;
    $app->send_http_header('text/html' .
        ($charset ? "; charset=$charset" : ''));

    my $param;
    $param = { import_as_me => $import_as_me };

    $app->print($app->build_page('import_start.tmpl', $param));

    require MT::Entry;
    require MT::Placement;
    require MT::Category;
    require MT::Permission;
    require MT::Comment;
    require MT::TBPing;

    if (UNIVERSAL::isa($MT::Object::DRIVER, 'MT::ObjectDriver::DBM')) {
        $MT::Object::DRIVER->no_build_indexes(1);
    }

    # try block so we can re-enable indexing safely
    my $import_result = eval {

    my $SEP = ('-' x 8);
    my $SUB_SEP = ('-' x 5);

    my(%authors, %categories);

    ## Default category for imported entries.
    my $def_cat_id = $q->param('default_cat_id');

    my $t_start = $q->param('title_start');
    my $t_end = $q->param('title_end');
    my $allow_comments = $blog->allow_comments_default;
    my $allow_pings = $blog->allow_pings_default ? 1 : 0;
    my $convert_breaks = $blog->convert_paras;
    my $def_status = $q->param('default_status') || $blog->status_default;

    foreach my $file (@files_to_import) {
        my $f = $file;
        $f =~ s!.+[/\\]!!g;
        $app->print($app->translate("Importing entries from file '[_1]'", $f) ."\n");
        open FH, $file
            or return $app->error($app->translate(
                "Can't open file '[_1]': [_2]", $file, "$!"));

        my $result = eval {
            local $/ = "\n$SEP\n";
            ENTRY_BLOCK:
            while (<FH>) {
                my($meta, @pieces) = split /^$SUB_SEP$/m;
                next unless $meta && @pieces;

                ## Create entry object and assign some defaults.
                my $entry = MT::Entry->new;
                $entry->blog_id($blog_id);
                $entry->status($def_status);
                $entry->allow_comments($allow_comments);
                $entry->allow_pings($allow_pings);
                $entry->convert_breaks($convert_breaks);
                $entry->author_id($author_id) if $import_as_me;

                ## Some users may want to import just their GM comments, having
                ## already imported their GM entries. We try to match up the
                ## entries using the created on timestamp, and the import file
                ## tells us not to import an entry with the meta-tag "NO ENTRY".
                my $no_save = 0;

                ## Handle all meta-data: author, category, title, date.
                my $i = -1;
                my($primary_cat_id, @placements);
                my @lines = split /\r?\n/, $meta;
                META:
                for my $line (@lines) {
                    $i++;
                    next unless $line;
                    $line =~ s!^\s*!!;
                    $line =~ s!\s*$!!;
                    my($key, $val) = split /\s*:\s*/, $line, 2;
                    if ($key eq 'AUTHOR' && !$import_as_me) {
                        my $author;
                        unless ($author = $authors{$val}) {
                            $author = MT::Author->load({ name => $val });
                        }
                        unless ($author) {
                            $author = MT::Author->new;
                            $author->created_by($author_id);
                            $author->name($val);
                            $author->email('');
                            $author->type(MT::Author::AUTHOR);
                            $author->set_password($pass);
                            $app->print($app->translate("Creating new author ('") .
                                        $val . "')...");
                            if ($author->save) {
                                $app->print($app->translate("ok\n"));
                            } else {
                                $app->print($app->translate("failed\n"));
                                return $app->error($app->translate(
                                    "Saving author failed: [_1]", $author->errstr));
                            }
                            $authors{$val} = $author;
                            $app->print("Assigning permissions for new author...");
                            my $perms = MT::Permission->new;
                            $perms->blog_id($blog_id);
                            $perms->author_id($author->id);
                            $perms->can_post(1);
                            if ($perms->save) {
                                $app->print("ok\n");
                            } else {
                                $app->print("failed\n");
                                return $app->error($app->translate(
                                 "Saving permission failed: [_1]", $perms->errstr));
                            }
                        }
                        $entry->author_id($author->id);
                    } elsif ($key eq 'CATEGORY' || $key eq 'PRIMARY CATEGORY') {
                        if ($val) {
                            my $cat;
                            unless ($cat = $categories{$val}) {
                                $cat = MT::Category->load({ label => $val,
                                                            blog_id => $blog_id });
                            }
                            unless ($cat) {
                                $cat = MT::Category->new;
                                $cat->blog_id($blog_id);
                                $cat->label($val);
                                $cat->author_id($entry->author_id);
                                $cat->parent(0);
                                $app->print("Creating new category ('$val')...");
                                if ($cat->save) {
                                    $app->print("ok\n");
                                } else {
                                    $app->print("failed\n");
                                    return $app->error($app->translate(
                                     "Saving category failed: [_1]", $cat->errstr));
                                }
                                $categories{$val} = $cat;
                            }
                            if ($key eq 'CATEGORY') {
                                push @placements, $cat->id;
                            } else {
                                $primary_cat_id = $cat->id;
                            }
                        }
                    } elsif ($key eq 'TITLE') {
                        $entry->title($val);
                    } elsif ($key eq 'DATE') {
                        my $date = $app->_convert_date($val) or return;
                        $entry->created_on($date);
                    } elsif ($key eq 'STATUS') {
                        my $status = MT::Entry::status_int($val)
                            or return $app->error($app->translate(
                                "Invalid status value '[_1]'", $val));
                        $entry->status($status);
                    } elsif ($key eq 'ALLOW COMMENTS') {
                        $val = 0 unless $val;
                        $entry->allow_comments($val);
                    } elsif ($key eq 'CONVERT BREAKS') {
                        $val = 0 unless $val;
                        $entry->convert_breaks($val);
                    } elsif ($key eq 'ALLOW PINGS') {
                        $val = 0 unless $val;
                        return $app->error("Invalid allow pings value '$val'")
                            unless $val eq 0 || $val eq 1;
                        $entry->allow_pings($val);
                    } elsif ($key eq 'NO ENTRY') {
                        $no_save++;
                    } elsif ($key eq 'START BODY') {
                        ## Special case for backwards-compatibility with old
                        ## export files: if we see START BODY: on a line, we
                        ## gather up the rest of the lines in meta and package
                        ## them for handling below in the non-meta area.
                        @pieces = ("BODY:\n" . join "\n", @lines[$i+1..$#lines]);
                        last META;
                    }
                }

                ## If we're not saving this entry (but rather just using it to
                ## import comments, for example), we need to load the relevant
                ## entry using the timestamp.
                if ($no_save) {
                    my $ts = $entry->created_on;
                    $entry = MT::Entry->load({ created_on => $ts,
                        blog_id => $blog_id });
                    if (!$entry) {
                        $app->print("Can't find existing entry with timestamp " .
                            "'$ts'... skipping comments, and moving on to " .
                            "next entry.\n");
                        next ENTRY_BLOCK;
                    } else {
                        $app->print(sprintf "Importing into existing " .
                            "entry %d ('%s')\n", $entry->id, $entry->title);
                    }
                }

                ## Deal with non-meta pieces: entry body, extended entry body,
                ## comments. We need to hold the list of comments until after
                ## we have saved the entry, then assign the new entry ID of
                ## the entry to each comment.
                my(@comments, @pings);
                for my $piece (@pieces) {
                    $piece =~ s!^\s*!!;
                    $piece =~ s!\s*$!!;
                    if ($piece =~ s/^BODY:\r?\n//) {
                        $entry->text($piece);
                    }
                    elsif ($piece =~ s/^EXTENDED BODY:\r?\n//) {
                        $entry->text_more($piece);
                    }
                    elsif ($piece =~ s/^EXCERPT:\r?\n//) {
                        $entry->excerpt($piece) if $piece =~ /\S/;
                    }
                    elsif ($piece =~ s/^KEYWORDS:\r?\n//) {
                        $entry->keywords($piece) if $piece =~ /\S/;
                    }
                    elsif ($piece =~ s/^COMMENT:\r?\n//) {
                        ## Comments are: AUTHOR, EMAIL, URL, IP, DATE (in any order),
                        ## then body
                        my $comment = MT::Comment->new
                            or die("Couldn't construct MT::Comment " . 
                                   MT::Comment->errstr);
                        $comment->blog_id($blog_id);
                        $comment->approve;
                        my @lines = split /\r?\n/, $piece;
                        my($i, $body_idx) = (0) x 2;
                        COMMENT:
                        for my $line (@lines) {
                            $line =~ s!^\s*!!;
                            my($key, $val) = split /\s*:\s*/, $line, 2;
                            if ($key eq 'AUTHOR') {
                                $comment->author($val);
                            } elsif ($key eq 'EMAIL') {
                                $comment->email($val);
                            } elsif ($key eq 'URL') {
                                $comment->url($val);
                            } elsif ($key eq 'IP') {
                                $comment->ip($val);
                            } elsif ($key eq 'DATE') {
                                my $date = $app->_convert_date($val) or next;
                                $comment->created_on($date);
                            } else {
                                ## Now we have reached the body of the comment;
                                ## everything from here until the end of the
                                ## array is body.
                                $body_idx = $i;
                                last COMMENT;
                            }
                            $i++;
                        }
                        $comment->text( join "\n", @lines[$body_idx..$#lines] );
                        push @comments, $comment;
                    }
                    elsif ($piece =~ s/^PING:\r?\n//) {
                        ## Pings are: TITLE, URL, IP, DATE, BLOG NAME,
                        ## then excerpt
                        require MT::TBPing;
                        my $ping = MT::TBPing->new;
                        $ping->blog_id($blog_id);
                        my @lines = split /\r?\n/, $piece;
                        my($i, $body_idx) = (0) x 2;
                        PING:
                        for my $line (@lines) {
                            $line =~ s!^\s*!!;
                            my($key, $val) = split /\s*:\s*/, $line, 2;
                            if ($key eq 'TITLE') {
                                $ping->title($val);
                            } elsif ($key eq 'URL') {
                                $ping->source_url($val);
                            } elsif ($key eq 'IP') {
                                $ping->ip($val);
                            } elsif ($key eq 'DATE') {
                                if (my $date = $app->_convert_date($val)) {
                                    $ping->created_on($date);
                                }
                            } elsif ($key eq 'BLOG NAME') {
                                $ping->blog_name($val);
                            } else {
                                ## Now we have reached the ping excerpt;
                                ## everything from here until the end of the
                                ## array is body.
                                $body_idx = $i;
                                last PING;
                            }
                            $i++;
                        }
                        $ping->excerpt( join "\n", @lines[$body_idx..$#lines] );
                        $ping->approve;
                        push @pings, $ping;
                    }
                }

                ## Assign a title if one is not already assigned.
                unless ($entry->title) {
                    my $body = $entry->text;
                    if ($t_start && $t_end && $body =~
                        s!\Q$t_start\E(.*?)\Q$t_end\E\s*!!s) {
                        (my $title = $1) =~ s/[\r\n]/ /g;
                        $entry->title($title);
                        $entry->text($body);
                    } else {
                        $entry->title( first_n_words($body, 5) );
                    }
                }

                ## If an entry has comments listed along with it, set
                ## allow_comments to 1 no matter what the default is.
                if (@comments && !$entry->allow_comments) {
                    $entry->allow_comments(1);
                }

                ## If an entry has TrackBack pings listed along with it,
                ## set allow_pings to 1 no matter what the default is.
                if (@pings) {
                    $entry->allow_pings(1);

                    ## If the entry has TrackBack pings, we need to make sure
                    ## that an MT::Trackback object is created. To do that, we
                    ## need to make sure that $entry->save is called.
                    $no_save = 0;
                }

                ## Save entry.
                unless ($no_save) {
                    $app->print("Saving entry ('", $entry->title, "')... ");
                    if ($entry->save) {
                        $app->print("ok (ID ", $entry->id, ")\n");
                    } else {
                        $app->print("failed\n");
                        return $app->error($app->translate(
                            "Saving entry failed: [_1]", $entry->errstr));
                    }
                }

                ## Save placement.
                ## If we have no primary category ID (from a PRIMARY CATEGORY
                ## key), we first look to see if we have any placements from
                ## CATEGORY tags. If so, we grab the first one and use it as the
                ## primary placement. If not, we try to use the default category
                ## ID specified.
                if (!$primary_cat_id) {
                    if (@placements) {
                        $primary_cat_id = shift @placements;
                    } elsif ($def_cat_id) {
                        $primary_cat_id = $def_cat_id;
                    }
                } else {
                    ## If a PRIMARY CATEGORY is also specified as a CATEGORY, we
                    ## don't want to add it twice; so we filter it out.
                    @placements = grep { $_ != $primary_cat_id } @placements;
                }

                ## So if we have a primary placement from any of the means
                ## specified above, we add the placement.
                if ($primary_cat_id) {
                    my $place = MT::Placement->new;
                    $place->is_primary(1);
                    $place->entry_id($entry->id);
                    $place->blog_id($blog_id);
                    $place->category_id($primary_cat_id);
                    $place->save
                        or return $app->error($app->translate(
                            "Saving placement failed: [_1]", $place->errstr));
                }

                ## Now add all of the other, non-primary placements.
                for my $cat_id (@placements) {
                    my $place = MT::Placement->new;
                    $place->is_primary(0);
                    $place->entry_id($entry->id);
                    $place->blog_id($blog_id);
                    $place->category_id($cat_id);
                    $place->save
                        or return $app->error($app->translate(
                            "Saving placement failed: [_1]", $place->errstr));
                }

                ## Save comments.
                for my $comment (@comments) {
                    $comment->entry_id($entry->id);
                    $app->print("Creating new comment (from '", $comment->author, 
                        "')... ");
                    if ($comment->save) {
                        $app->print("ok (ID ", $comment->id, ")\n");
                    } else {
                        $app->print("failed\n");
                        return $app->error($app->translate(
                            "Saving comment failed: [_1]", $comment->errstr));
                    }
                }

                ## Save pings.
                if (@pings) {
                    my $tb = $entry->trackback
                        or return $app->error($app->translate(
                            "Entry has no MT::Trackback object!"));
                    for my $ping (@pings) {
                        $ping->tb_id($tb->id);
                        $app->print("Creating new ping ('", $ping->title,
                            "')... ");
                        if ($ping->save) {
                            $app->print("ok (ID ", $ping->id, ")\n");
                        } else {
                            $app->print("failed\n");
                            return $app->error($app->translate(
                                "Saving ping failed: [_1]", $ping->errstr));
                        }
                    }
                }
            }
            1;
        };
        close FH;
        return unless $result;
    }

    1;  # signal success if we got this far

    }; # end try block

    if (UNIVERSAL::isa($MT::Object::DRIVER, 'MT::ObjectDriver::DBM')) {
        $MT::Object::DRIVER->rebuild_indexes('MT::Entry');
        $MT::Object::DRIVER->rebuild_indexes('MT::Comment');
        $MT::Object::DRIVER->rebuild_indexes('MT::TBPing');
        $MT::Object::DRIVER->rebuild_indexes('MT::Category');
        $MT::Object::DRIVER->rebuild_indexes('MT::Trackback');
        $MT::Object::DRIVER->rebuild_indexes('MT::Placement');
        $MT::Object::DRIVER->rebuild_indexes('MT::Permission');
        $MT::Object::DRIVER->rebuild_indexes('MT::Author');
        $MT::Object::DRIVER->no_build_indexes(0);
    }

    $param->{import_success} = $import_result;
    $param->{error} = $app->errstr unless $import_result;

    $app->print($app->build_page("import_end.tmpl", $param));

    1;
}

sub _convert_date {
    my $app = shift;
    my($date) = @_;
    my($mo, $d, $y, $h, $m, $s, $ampm) = $date =~
        m!^\s*(\d{1,2})/(\d{1,2})/(\d{2,4}) (\d{1,2}):(\d{1,2}):(\d{1,2})(?:\s(\w{2}))?\s*$!
        or return $app->error($app->translate(
            "Invalid date format '[_1]'; must be 'MM/DD/YYYY HH:MM:SS AM|PM' (AM|PM is optional)", $date));
    if ($ampm) {
        if ($ampm eq 'PM' && $h < 12) {
            $h += 12;
        } elsif ($ampm eq 'AM' && $h == 12) {
            $h = 0;
        }
    }
    if (length($y) == 2) {
        $y += 1900;
    }
    sprintf "%04d%02d%02d%02d%02d%02d", $y, $mo, $d, $h, $m, $s;
}

sub show_entry_prefs {
    my $app = shift;
    my $perms = $app->{perms}
        or return $app->error($app->translate("No permissions"));
    my %param;
    my $prefs = $perms->entry_prefs || 'Advanced|Bottom';
    ($prefs, my($pos)) = split /\|/, $prefs;
    if ($prefs eq 'Basic' || $prefs eq 'Advanced') {
        $param{'disp_prefs_' . $prefs} = 1;
    } else {
        $param{disp_prefs_custom} = 1;
        my @p = split /,/, $prefs;
        for my $p (@p) {
            $param{'disp_prefs_show_' . $p} = 1;
        }
    }
    $param{'position_' . $pos} = 1;
    $param{entry_id} = $app->param('entry_id');
    $app->add_breadcrumb($app->translate('Preferences'));
    $app->build_page('entry_prefs.tmpl', \%param);
}

sub save_entry_prefs {
    my $app = shift;
    my $perms = $app->{perms}
        or return $app->error($app->translate("No permissions"));
    $app->validate_magic() or return;
    my $q = $app->param;
    my $type = $q->param('entry_prefs');
    my $prefs;
    if ($type eq 'Custom') {
        $prefs = join ',', $q->param('custom_prefs');
    } else {
        $prefs = $type;
    }
    $prefs .= '|' . $q->param('bar_position');
    $perms->entry_prefs($prefs);
    $perms->save
        or return $app->error($app->translate(
            "Saving permissions failed: [_1]", $perms->errstr));
    my $url = $app->uri('mode' => 'view', args => { '_type' => 'entry' });
    if (my $id = $q->param('entry_id')) {
        $url .= '&id=' . $id;
    }
    $url .= '&blog_id=' . $perms->blog_id . '&saved_prefs=1';
    $app->build_page('reload_opener.tmpl', { url => $url });
}

sub pinged_urls {
    my $app = shift;
    my $perms = $app->{perms}
        or return $app->error($app->translate("No permissions"));
    my %param;
    my $entry_id = $app->param('entry_id');
    require MT::Entry;
    my $entry = MT::Entry->load($entry_id, {cached_ok=>1});
    $param{url_loop} = [ map { { url => $_ } } @{ $entry->pinged_url_list } ];
    $app->build_page('pinged_urls.tmpl', \%param);
}

sub reg_file {
    my $app = shift;
    my $q = $app->param;
    my $uri = $app->base .
        $app->uri( 'mode' => 'reg_bm_js', 
                   args => { bm_show => $q->param('bm_show'),
                             bm_height => $q->param('bm_height')});
    $app->{no_print_body} = 1;
    $app->set_header('Content-Disposition' => 'attachment; filename=mt.reg');
    $app->send_http_header('text/plain; name=mt.reg');
    $app->print(
        qq(REGEDIT4\r\n) .
        qq([HKEY_CURRENT_USER\\Software\\Microsoft\\Internet Explorer\\MenuExt\\QuickPost]\r\n) .
        qq(@="$uri"\r\n) .
        qq("contexts"=hex:31));
    1;
}

sub reg_bm_js {
    my $app = shift;
    my $q = $app->param;
    my $js = $app->_bm_js(scalar $q->param('bm_show'),
                    scalar $q->param('bm_height'));
    $js =~ s!d=document!d=external.menuArguments.document!;
    $js =~ s!d\.location\.href!external.menuArguments.location.href!;
    $js =~ s!^javascript:!!;
    $js =~ s!\%20! !g;
    $app->{no_print_body} = 1;
    $app->send_http_header('text/plain');
    $app->print('<script language="javascript">' . $js . '</script>');
    1;
}

sub category_add {
    my $app = shift;
    my $q = $app->param;
    my $data = $app->_build_category_list($q->param('blog_id'));
    my %param;
    $param{'category_loop'} = $data;
    $app->add_breadcrumb($app->translate('Add a Category'));
    $app->build_page('category_add.tmpl', \%param);
}

sub category_do_add {
    my $app = shift;
    my $q = $app->param;
    my $perms = $app->{perms}
        or return $app->error($app->translate("No permissions"));
    return $app->error($app->translate("Permission denied."))
        unless $perms->can_edit_categories;
    $app->validate_magic() or return;
    require MT::Category;
    my $name = $q->param('label') or return $app->error("No label");
    $name =~ s/(^\s+|\s+$)//g;
    return $app->errtrans("Category name cannot be blank.")
        if $name eq '';
    my $parent = $q->param ('parent') || '0';
    my $cat = MT::Category->new;
    $cat->blog_id(scalar $q->param('blog_id'));
    $cat->author_id($app->user->id);
    $cat->label($name);
    $cat->parent ($parent);

    my @siblings = MT::Category->load({ parent => $cat->parent,
                                        blog_id => $app->param('blog_id') });
    foreach (@siblings) {
        return $app->errtrans("No categories with the same name can have the same parent")
            if $_->label eq $cat->label;
    }
    
    $cat->save or return $app->error($cat->errstr);
    my $id = $cat->id;
    $name = encode_js($name);
    my %param = (javascript => <<SCRIPT);
    o.doAddCategoryItem('$name', '$id');
SCRIPT
    $app->build_page('reload_opener.tmpl', \%param);
}

sub cc_return {
    my $app = shift;
    my $code = $app->param('license_code');
    my $url = $app->param('license_url');
    my $image = $app->param('license_button');
    my %param = (license_name => MT::Util::cc_name($code));
    if ($url) {
        $param{license_code} = "$code $url $image";
    } else {
        $param{license_code} = $code;
    }
    $app->build_page('cc_return.tmpl', \%param);
}

sub reset_blog_templates {
    my $app = shift;
    my $q = $app->param;
    my $perms = $app->{perms}
        or return $app->error($app->translate("No permissions"));
    return $app->error($app->translate("Permission denied."))
        unless $perms->can_edit_templates;
    $app->validate_magic() or return;
    my $blog = MT::Blog->load($perms->blog_id, {cached_ok=>1});
    require MT::Template;
    my @tmpl = MT::Template->load({ blog_id => $blog->id });
    for my $tmpl (@tmpl) {
        $tmpl->remove or return $app->error($tmpl->errstr);
    }
    my $tmpl_list;
    eval { $tmpl_list = require 'MT/default-templates.pl' };
    return $app->error($app->translate(
        "Can't find default template list; where is " .
        "'default-templates.pl'?")) if
        $@ || !$tmpl_list || ref($tmpl_list) ne 'ARRAY' ||!@$tmpl_list;
    my @arch_tmpl;
    for my $val (@$tmpl_list) {
        $val->{name} = $app->translate($val->{name});
        $val->{text} = $app->translate_templatized($val->{text});
        my $tmpl = MT::Template->new;
        $tmpl->set_values($val);
        $tmpl->build_dynamic(0);
        $tmpl->blog_id($blog->id);
        $tmpl->save or
            return $app->error($app->translate(
                "Populating blog with default templates failed: [_1]",
                $tmpl->errstr));
        if ($val->{type} eq 'archive' || $val->{type} eq 'category' ||
            $val->{type} eq 'individual') {
            push @arch_tmpl, $tmpl;
        }
    }

    ## Set up mappings from new templates to archive types.
    for my $tmpl (@arch_tmpl) {
        my(@at);
        if ($tmpl->type eq 'archive') {
            @at = qw( Daily Weekly Monthly );
        } elsif ($tmpl->type eq 'category') {
            @at = qw( Category );
        } elsif ($tmpl->type eq 'individual') {
            @at = qw( Individual );
        }
        require MT::TemplateMap;
        for my $at (@at) {
            my $map = MT::TemplateMap->new;
            $map->archive_type($at);
            $map->is_preferred(1);
            $map->template_id($tmpl->id);
            $map->blog_id($tmpl->blog_id);
            $map->save
                or return $app->error($app->translate(
                    "Setting up mappings failed: [_1]", $map->errstr));
        }
    }
    $app->redirect($app->uri( 'mode' => 'list', args => { '_type' => 'template', blog_id => $blog->id, 'reset' => 1}));
}

sub update_dynamicity {
    my $app = shift;
    my ($blog) = @_;
    my $dcty = $blog->custom_dynamic_templates;
    if ($dcty eq 'none') {
        require MT::Template;
        my @templates = MT::Template->load({ blog_id => $blog->id });
        for my $tmpl (@templates) {
            $tmpl->build_dynamic(0);
            $tmpl->save();
        }
    } elsif ($dcty eq 'archives') {
        require MT::Template;
        my @templates = MT::Template->load({ blog_id => $blog->id });
        for my $tmpl (@templates) {
            $tmpl->build_dynamic($tmpl->type ne 'index' || 0);
            $tmpl->save();
        }
    } elsif ($dcty eq 'custom') {
    }

    if ($dcty ne 'none') {
        eval {
            my $htaccess_path = File::Spec->catfile($blog->site_path(),
                                                    ".htaccess");
            require URI;
            my $mtview_server_url = new URI($blog->site_url());
            $mtview_server_url = $mtview_server_url->path();
            $mtview_server_url .= ($mtview_server_url =~ m|/$| ? "" : "/")
                . "mtview.php";
            
            my $mtview_path = File::Spec->catfile($blog->site_path(), "mtview.php");
            my $contents = "";
            if (open(HT, $htaccess_path)) {
                $/ = undef;
                $contents = <HT>;
                close HT;
            }
            if ($contents !~ /^\s*Rewrite(Cond|Engine|Rule)\b/m) {
                my $htaccess = <<HTACCESS;

## %%%%%%% Movable Type generated this part; don't remove this line! %%%%%%%
# Disable fancy indexes, so mtview.php gets a chance...
Options -Indexes +SymLinksIfOwnerMatch
  <IfModule mod_rewrite.c>
  # The mod_rewrite solution is the preferred way to invoke
  # dynamic pages, because of its flexibility.

  # Add mtview.php to the list of DirectoryIndex options, listing it last,
  # so it is invoked only if the common choices aren't present...
  <IfModule mod_dir.c>
    DirectoryIndex index.php index.html index.htm default.htm default.html default.asp $mtview_server_url
  </IfModule>

  RewriteEngine on

  # don't serve mtview.php if the request is for a real directory
  # (allows the DirectoryIndex lookup to function)
  RewriteCond %{REQUEST_FILENAME} !-d

  # don't serve mtview.php if the request is for a real file
  # (allows the actual file to be served)
  RewriteCond %{REQUEST_FILENAME} !-f
  # anything else is handed to mtview.php for resolution
  RewriteRule ^(.*)\$ $mtview_server_url [L,QSA]
</IfModule>

<IfModule !mod_rewrite.c>
  # if mod_rewrite is unavailable, we forward any missing page
  # or unresolved directory index requests to mtview
  # if mtview.php can resolve the request, it returns a 200
  # result code which prevents any 4xx error code from going
  # to the server's access logs. However, an error will be
  # reported in the error log file. If this is your only choice,
  # and you want to suppress these messages, adding a "LogLevel crit"
  # directive within your VirtualHost or root configuration for
  # Apache will turn them off.
  ErrorDocument 404 $mtview_server_url
  ErrorDocument 403 $mtview_server_url
</IfModule>
## ******* Movable Type generated this part; don't remove this line! *******

HTACCESS

                $blog->file_mgr->mkpath($blog->site_path);

                open(HT, ">>$htaccess_path")
                    || die "Couldn't open $htaccess_path for appending";
                print HT $htaccess || die "Couldn't write to $htaccess_path";
                close HT;
            }
        }; if ($@) { print STDERR $@; } 
        
        my $compiled_template_path = File::Spec->catfile($blog->site_path(), 
                                                         'templates_c');
        my $fmgr = $blog->file_mgr;
        my $saved_umask = $app->config('DirUmask');
        $app->config('DirUmask', '0000');
        $fmgr->mkpath($compiled_template_path);
        $app->config('DirUmask', $saved_umask);
        if (-d $compiled_template_path) {
            $app->add_return_arg('no_writecache' => 1)
                unless (-w $compiled_template_path);
        } else {
            $app->add_return_arg('no_cachedir' => 1)
                unless (-d $compiled_template_path);
        }
            # FIXME: use FileMgr
    }
    $app->add_return_arg(dynamic_set => 1);
}

sub _builtin_spam_handler {
    my ($eh, $app, $obj) = @_;
    # Do nothing. This is just an example for developers like you.
}

sub handshake {
    my $app = shift;
    my $blog_id = $app->param('blog_id');
    my $remote_auth_token = $app->param('remote_auth_token');
    
    my %param = ();
    $param{remote_auth_token} = $remote_auth_token;
    $app->build_page('handshake_return.tmpl', \%param);
}

sub itemset_action {
    my $app = shift;
    # plugin_action_selector should always (?) be in the query; use it?
    my $action_name = $app->param('action_name');
    my $type = $app->param('_type');
    my ($the_action) = (grep {$_->{key} eq $action_name}
                             @{$app->{CoreItemsetActions}{$type}},
                        grep {$_->{key} eq $action_name}
                             @{$app->{PluginItemsetActions}{$type}});
    return $app->errtrans("That action ([_1]) is apparently not implemented!",
                          $action_name)
        unless $the_action;
    
    $the_action->{code}->($app);
}

sub rebuild_new_phase {
    my ($app) = @_;
    my %reb_set = map { $_ => 1 } $app->param('id');
    $app->rebuild_these(\%reb_set, how => NEW_PHASE);
}

# rebuild_set is a hash whose keys are entry IDs
# the value can be the entry itself, for efficiency,
# but if the value is not a ref, the entry is loaded from the ID.
# This is not a handler but a utility routine
sub rebuild_these {
    my ($app, $rebuild_set, %options) = @_;

    # if there's nothing to rebuild, just return
    if (!keys %$rebuild_set) {
        return $app->call_return;
    }

    if ($options{how} eq NEW_PHASE) {
        my $params = {
            return_args => $app->return_args,
            id => [ keys %$rebuild_set ]
        };
        my %param = (is_full_screen => 1,
                     redirect_target => $app->uri( mode => 'rebuild_phase',
                                                   args => $params));
        return $app->build_page('rebuilding.tmpl', \%param);

    } else {
        require MT::Entry;
        for my $id (keys %$rebuild_set) {
            my $e = ref $rebuild_set->{$id} ?
                $rebuild_set->{$id} : MT::Entry->load($id, {cached_ok=>1});
            $app->rebuild_entry(Entry => $e, BuildDependencies => 1);
        }
    }
}

sub handle_junk {
    my $app = shift;
    my @ids = $app->param("id");
    my $type = $app->param("_type");
    my $class = $app->_load_driver_for($type);
    my @item_loop;
    my $i = 0;
    my $blog_id = $app->param('blog_id');
    my (%rebuild_entries, %rebuild_categories);
    MT->_register_core_callbacks({HandleJunk => \&_builtin_spam_handler});
    foreach my $id (@ids) {
        # TBD: Check permissions
        my $obj = $class->load($id, {cached_ok=>1}) or die "No $class $id";
        my $old_visible = $obj->visible || 0;
        MT->run_callbacks('HandleJunk', $app, $obj); # mv this into blk below?
        $obj->junk;
        $obj->save;     # (so that each cb doesn't have to save indiv'ly)
        next if $old_visible == $obj->visible;
        if ($obj->isa('MT::TBPing')) {
            my ($parent_type, $parent_id) = $obj->parent_id();
            if ($parent_type eq 'MT::Entry') {
                $rebuild_entries{$parent_id} = 1;
            } else {
                $rebuild_categories{$obj->category_id} = 1;
                # TBD: do something with this list.
            }
        } else {
            $rebuild_entries{$obj->entry_id} = 1;
        }
    }
    $app->add_return_arg('junked' => 1);
    if (%rebuild_entries) {
        $app->rebuild_these(\%rebuild_entries, how => NEW_PHASE);
    } else {
        $app->call_return;
    }
}

sub _builtin_spam_unhandler {
    my ($eh, $app, $obj) = @_;
    # Do nothing. This is just an example for developers like you.
}

sub not_junk {
    my $app = shift;
    my @ids = $app->param("id");
    my @item_loop;
    my $i = 0;
    my $type = $app->param('_type');
    my $class = $app->_load_driver_for($type);
    my %rebuild_set;
    MT->_register_core_callbacks({HandleNotJunk => \&_builtin_spam_unhandler});
    foreach my $id (@ids) {
        my $obj = $class->load($id, {cached_ok=>1});
        MT->run_callbacks('HandleNotJunk', $app, $obj);
        if ($obj->isa('MT::TBPing')) {
            my ($parent_type, $parent_id) = $obj->parent_id();
            if ($parent_type eq 'MT::Entry') {
                $rebuild_set{$parent_id} = 1;
            } else {
            }
        } else {
            $rebuild_set{$obj->entry_id} = 1;
        }
        $obj->approve;
        $obj->save();
    }
    $app->param('approve', 1);

    $app->add_return_arg('unjunked' => 1);

    $app->rebuild_these(\%rebuild_set, how => NEW_PHASE);
}

sub comment_to_row {
    my ($obj, $text_limit)  = @_;
    my $row = $obj->column_values;
    $row->{author_display} = $row->{author};
    $row->{author_display} = substr($row->{author_display}, 0, 25) . '...'
        if $row->{author_display} && $row->{author_display} =~ m(\S{25,});
    $row->{comment_short} = (substr($obj->text(), 0, $text_limit)
                             . (length($obj->text) > $text_limit ? "..." : ""));
    $row->{visible} = $obj->visible();
    $row->{entry_id} = $obj->entry_id();
    require MT::Entry;
    my $entry = MT::Entry->load($obj->entry_id, {cached_ok=>1});
    $row->{entry_title} = $entry->title() || $entry->text || "";
    $row->{entry_title} = substr($row->{entry_title}, 0, 25) . '...'
        if $row->{entry_title} && $row->{entry_title} =~ m(\S{25,});
    $row->{commenter_id} = $obj->commenter_id() if $obj->commenter_id();
    my %urls = MT::Util::extract_urls( join "\n",
        ($obj->text() || '') .
        ($obj->url() || '') .
        ($obj->author() || '')
    );
    my %domains;
    $domains{$_} = 1 foreach values %urls;
    my @domains = map { domain => $_ }, sort keys %domains;
    $row->{domains} = \@domains;
    my $cmntr = MT::Author->load({ id => $obj->commenter_id(),
                                   type => MT::Author::COMMENTER });
    if ($cmntr) {
        $row->{email_hidden} = $cmntr && $cmntr->is_email_hidden();
        require MT::Permission;
        my $blog_id = $obj->blog_id;
        my $status = $cmntr->status($blog_id);
        $row->{commenter_approved} = ($cmntr->status($blog_id)== APPROVED);
        $row->{commenter_banned} = ($cmntr->status($blog_id) == BANNED);
    }
    $row->{created_on_time_formatted} =
        format_ts("%Y-%m-%d %H:%M:%S", $obj->created_on());     
    return $row;
}

sub _cb_notjunktest_filter {
    my ($eh, $app, $obj) = @_;
    require MT::JunkFilter;
    MT::JunkFilter->filter($obj);
    $obj->is_junk ? 0 : 1;
}

sub find_junk {
    my $app = shift;
    my $blog_id = $app->param('blog_id');
    my $offset = $app->param('offset') || 0;
    my $iter = MT::Comment->load_iter({ blog_id => $blog_id,
                                        is_junk => 0 }, { offset => $offset });
    my @spam_comments;
    my $i;
    MT->_register_core_callbacks({NotJunkTest =>
                                      \&_cb_notjunktest_filter});

    my $start = time;
    my $cmt;
    my %param;
    my $count = 0;
    require MT::Entry;
    my $trim_length = $app->config('ShowIPInformation') ? 45 : 90;
    while ($cmt = $iter->()) {
        last if @spam_comments == 20;
        $count++;
        my $subject = $cmt->clone;
        if (!MT->run_callbacks('NotJunkTest', $app, $subject)) {
            my $err = MT->errstr;
            my $row = comment_to_row($cmt, $trim_length);
            my $entry = MT::Entry->load($cmt->entry_id, {cached_ok=>1});
            $row->{has_edit_access} = $app->{perms}->can_edit_all_posts
                || $app->user->id == $entry->author_id;
            my $log = $subject->junk_log || '';
            $log =~ s!\n!<br />!g;
            $row->{reason} = $log; # $err;
            push @spam_comments, $row;
        }
        $offset++;
        last if time - $start > 60;
    }
    if ((@spam_comments) && ($cmt)) {
        $param{more} = 1;
    }
    if (!@spam_comments) {
        $param{scan_count} = $count;
        $param{redirect} = 1;
    }
    $param{offset} = $offset;
    if ((!@spam_comments) && (!$param{redirect})) {
        $app->redirect($app->uri('mode' => 'list_comments', args => { ($blog_id ? (blog_id => $blog_id) : () ), no_junk_found => 1}));
    }
    $param{object_loop} = \@spam_comments;
    $app->build_page('junk_results.tmpl', \%param);    
}

sub expire_junk {
    my $app = shift;
    my ($blog) = @_;
    my ($blog_id, $expiry_age) = ($blog->id, 86400 * $blog->junk_folder_expiry);
    require MT::Util;
    my @ts = MT::Util::offset_time_list(time() - $expiry_age, $blog_id);
    my $ts = sprintf("%04d%02d%02d%02d%02d%02d",
                     $ts[5]+1900, $ts[4]+1, @ts[3,2,1,0]);
    for my $type (qw(comment ping)) {
        my $class = $app->_load_driver_for($type);
        my @old_junk = $class->load({last_moved_on => ['19700101000000', $ts],
                                     junk_status => -1, blog_id => $blog_id},
                                    {range => {last_moved_on => 1}});
        $_->remove foreach @old_junk;
    }
}

sub add_itemset_action {
    my $app = shift;
    my ($itemset_action, $is_core) = @_;
    my $type = $itemset_action->{type};
    Carp::croak 'itemset actions require a string called "key"' 
        unless ($itemset_action->{key}
                && !(ref($itemset_action->{key})));
    Carp::croak 'itemset actions require a coderef called "code"'
        unless ($itemset_action->{code} && 
                (ref $itemset_action->{code} eq 'CODE'));
    Carp::croak 'itemset actions require a string called "label"'
        unless ($itemset_action->{label} && 
                !(ref $itemset_action->{label}));

    my $coreness = $is_core ?
        'CoreItemsetActions' : 'PluginItemsetActions';
    $itemset_action->{orig_label} = $itemset_action->{label};
    push @{$app->{$coreness}{$type}}, $itemset_action;
}

sub update_list_prefs {
    my $app = shift;
    my $prefs = $app->list_pref($app->param('_type'));
    $app->call_return;
}

1;
__END__

=head1 NAME

MT::App::CMS

=head1 SYNOPSIS

The application-level callbacks of the C<MT::App::CMS> application are
documented here.

=head1 CALLBACKS

=over 4

=item CMSPostEntrySave

Called when an entry has been saved, after all of its constituent
parts (for example, category placements) have been saved. An 
CMSPostEntrySave callback would have the following signature:

    sub cms_post_entry_save($eh, $app, $entry)
    {
        ...
    }

=back

For backward compatibility, C<AppPostEntrySave> is an alias to C<CMSPostEntrySave>.

=head2 Parametric Calllbacks

Every object "type" has a suite of callbacks defined for that type, as
below. Each item in the list below forms a callback name by appending
the object "type" after an underscore,
e.g. C<CMSViewPermissionFilter_blog>, C<CMSPostSave_template>,
etc. The "type" values come from the same space as passed to the CMS
app's C<_type> query parameter. If you're not sure what C<_type>
corresponds to a certain MT::Object subclass, consult the following list:

=over 4

=item author           => MT::Author

=item role             => MT::Role

=item group            => MT::Group

=item group_membership => MT::AuthorGroupMap

=item comment          => MT::Comment

=item entry            => MT::Entry

=item template         => MT::Template

=item blog             => MT::Blog

=item notification     => MT::Notification

=item templatemap      => MT::TemplateMap

=item category         => MT::Category

=item banlist          => MT::IPBanList

=item ping             => MT::TBPing

=item ping_cat         => MT::TBPing

=back

Callbacks that apply to these object types are as follows:

=over 4

=item CMSViewPermissionFilter
    
Calling convention is:

    callback($eh, $app, $id, $obj_promise)

Where C<$id> is the ID of an object, if it already exists, or
C<undef> if the user will be creating a new object of this type.

C<$obj_promise> is a promise for the object itself. You can use
C<$obj_promise->force> to get ahold of the object, if you need it, but
typically you won't need it. (See L<MT::Promise>)

Return a false value to abort the operation and display a message to
the user that s/he doesn't have permission to view the object.

=item CMSSavePermissionFilter
    
Calling convention is:

    callback($eh, $app, $id)
    
Where C<$id> is the ID of the object, if it already exists, or
C<undef> if it is a new object with this request.

Note that at this point, the object may not yet exist. The request can
be understood through the query parameters of the app, accessible
through C<$app-E<gt>param()>. A C<CMSSavePermissionFilter> callback
should be "safe"--it should not modify the database.

Return a false value to abort the operation and display a message to
the user that s/he doesn't have permission to modify the object. The
method is not called if the acting user is a superuser.

=item CMSSaveFilter

This callback gives you the chance to "decline" for reasons other than lack of permissions.

The routine is called as follows:
    
    callback($eh, $app)

Returning a false value will decline the request. It is advisibable to
return an error via the C<$eh> object in order to signal to the user
what went wrong.

Note that the new object has not been constructed yet. The operation
can be understood by examining the C<$app> object's query parameters
via C<$app-E<gt>param()>

A C<CMSSaveFilter> callback should be "safe"--it should not modify the
database.

=item CMSPreSave

    callback($eh, $app, $obj, $original)

C<$obj> and C<$original> hold the object which is about to be saved,
and the object as it was when this request began, respectively. This
allows the callback to determine what kind of changes are being
attempted in the user's request. If the request is to create a new
object, $original will be a valid object reference, but the object
will be "blank": it will be just what is returned by the C<new> method
on that class.

=item CMSPostSave

    callback($eh, $app, $obj, $original)

C<$obj> and C<$original> hold the object which is about to be saved,
and the object as it was when this request began, respectively. When
the callback routine is called, the new object as C<$obj> has already
been committed to the database. This is a convenient time to trigger
follow-up actions, such as notification and static-page rebuilds.

=back
