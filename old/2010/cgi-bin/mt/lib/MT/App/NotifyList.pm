# Copyright 2001-2005 Six Apart. This code cannot be redistributed without
# permission from www.sixapart.com.  For more information, consult your
# Movable Type license.
#
# $Id: NotifyList.pm 15432 2005-07-29 20:41:11Z bchoate $

package MT::App::NotifyList;

use strict;
use MT::App;

use base 'MT::App';

sub init {
    my $app = shift;
    $app->SUPER::init(@_) or return;
    $app->add_methods('subscribe' => \&subscribe,
		      'confirm' => \&confirm,
		      'unsubscribe' => \&unsubscribe);
    $app->{default_mode} = 'subscribe';
}

sub subscribe {
    my $app = shift;
    my $q = $app->{query};
    my $subscr_addr = lc $q->param('email');
    $subscr_addr =~ s/(^\s+|\s+$)//gs;
    return $app->errtrans("Please enter a valid email address.")
        unless ($subscr_addr && MT::Util::is_valid_email($subscr_addr));
    unless ($q->param('blog_id'))
    {
	return $app->errtrans("Missing required parameter: blog_id. Please consult the user manual to configure notifications.");
    }

    my $secret = $app->{cfg}->EmailVerificationSecret
	|| return $app->error($app->translate("Email notifications have not been configured! The weblog owner needs to set the EmailVerificationSecret configuration variable in mt.cfg."));
    my $admin_email_addr = $app->{cfg}->EmailAddressMain 
	|| die "You need to set the EmailAddressMain configuration value "
	. "to your own email address in order to use notifications";
    my $blog = MT::Blog->load($q->param('blog_id'))
        || die "No blog found with the given blog_id.";
    my $entry_id = $q->param('entry_id');
    if ($entry_id) {
        require MT::Entry;
        my $entry = MT::Entry->load({id => $entry_id, blog_id => $blog->id, status => MT::Entry::RELEASE()})
            || die "No entry found with the given entry_id.";
    }

    my $redirect_url = $q->param('_redirect');
    my $site_url = $blog->site_url;
    if ($redirect_url !~ m!\Q$site_url\E!) {
        return $app->errtrans("An invalid redirect parameter was provided. The weblog owner needs to specify a path that matches with the domain of the weblog.");
    }

    if ($app->lookup($blog->id, $subscr_addr)) {
        return $app->error($app->translate("The email address '[_1]' is already in the notification list for this weblog.", $subscr_addr));
    }

    my @pool = ('A'..'Z','a'..'z','0'..'9');
    my $salt = join '', (map {$pool[rand @pool]} 1..2);
    my $magic = crypt($secret.$subscr_addr, $salt);
    my $body = MT->build_email('verify-subscribe.tmpl',
			    {script_path => $app->{cfg}->CGIPath
				 . '/mt-add-notify.cgi',
			     blog_id => $blog->id,
			     entry_id => $entry_id,
                             redirect_url => $redirect_url,
			     blog_name => $blog->name,
			     magic => $magic,
			     email => $subscr_addr}); 
    use MT::Mail;
    MT::Mail->send({From => $admin_email_addr,
		    To => $subscr_addr,
		    Subject => "Please verify your email to subscribe"}, $body);
    <<HTML;
An email has been sent to $subscr_addr. To complete your subscription, 
please follow the link contained in that email. This will verify that
the address you provided is correct and belongs to you.
HTML
}

sub lookup {
    my $app = shift;
    my ($blog_id, $email) = @_;

    require MT::Notification;
    my $niter = MT::Notification->load_iter({blog_id => $blog_id});
    while (my $n = $niter->()) {
        return $n if $n->email eq $email;
    }
    undef;
}

sub confirm {
    my $app = shift;
    my $q = $app->{query};

    # email confirmed

    my $blog_id = $q->param('blog_id');
    unless ($blog_id && $q->param('email') &&
	    $q->param('magic')) {
	print $q->header;
	print "Missing required parameters\n";
	exit;
    }

    my $magic = $q->param('magic');
    my $email = lc $q->param('email');
    $email =~ s/(^\s+|\s+$)//gs;
    my $secret = $app->{cfg}->EmailVerificationSecret;
    my $salt = substr($magic, 0, 2);
    my $failed = 0;
    if (crypt($secret.$email, $salt) ne $magic) {
        $failed = 1;
    }

    my $entry_id = $q->param('entry_id');
    require MT::Blog;
    my $blog = MT::Blog->load($blog_id);
    my $url;
    if ($blog) {
        $url = $blog->site_url();
        if (my $redirect = $q->param('redirect')) {
            if ($redirect !~ m!^\Q$url\E!) {
                $failed = 1;
            } else {
                $url = $redirect;
            }
        } else {
            if ($entry_id) {
                require MT::Entry;
                my $entry = MT::Entry->load({id => $entry_id, blog_id => $blog_id, status => MT::Entry::RELEASE()});
                if ($entry) {
                    $url = $entry->permalink;
                } else {
                    $failed = 1;
                }
            }
        }
    } else {
        $failed = 1;
    }

    if ($failed) {
        print $q->header;
        print "Subscription confirmation failed.\n";
        exit;
    }

    if (!$app->lookup($blog->id, $email)) {
        require MT::Notification;
        my $note = MT::Notification->new;
        $note->blog_id( $blog_id );
        $note->email( $email );
        $note->save;
    }
    print $q->redirect($url);
}

sub unsubscribe {
    my $app = shift;

    my $q = $app->{query};

    my $email = $q->param('email');
    require MT::Notification;
    my $notification = MT::Notification->load({email => $email});
    return "The address $email was not subscribed.\n\n" if !$notification;
    $notification->remove();
    return "The address $email has been unsubscribed.\n\n";
}

1;
