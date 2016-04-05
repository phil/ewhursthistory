# Copyright 2001-2005 Six Apart. This code cannot be redistributed without
# permission from www.sixapart.com.  For more information, consult your
# Movable Type license.
#
# $Id: TBPing.pm 16546 2005-08-23 04:57:57Z bchoate $

package MT::TBPing;
use strict;

use constant JUNK => -1;
use constant NOT_JUNK => 1;
use MT::Trackback;

use MT::Object;
@MT::TBPing::ISA = qw( MT::Object );
__PACKAGE__->install_properties({
    column_defs => {
        'id' => 'integer not null auto_increment',
        'blog_id' => 'integer not null',
        'tb_id' => 'integer not null',
        'title' => 'string(255)',
        'excerpt' => 'text',
        'source_url' => 'string(255)',
        'ip' => 'string(15) not null',
        'blog_name' => 'string(255)',
        'visible' => 'boolean',
        'junk_status' => 'smallint not null',
        'last_moved_on' => 'datetime not null',
        'junk_score' => 'float',
        'junk_log' => 'text',
    },
    indexes => {
        created_on => 1,
        blog_id => 1,
        tb_id => 1,
        ip => 1,
        visible => 1,
        junk_status => 1,
        last_moved_on => 1,
        junk_score => 1,
    },
    defaults => {
        junk_status => 0,
        last_moved_on => '20000101000000',
    },
    audit => 1,
    datasource => 'tbping',
    primary_key => 'id',
});

sub is_junk {
    $_[0]->junk_status == JUNK;
}
sub is_not_junk {
    $_[0]->junk_status != JUNK;
}

sub is_published {
    return $_[0]->visible && !$_[0]->is_junk;
}

sub is_moderated {
    return !$_[0]->visible() && !$_[0]->is_junk();
}

sub blog {
    my ($ping) = @_;
    my $blog = $ping->{__blog};
    unless ($blog) {
        my $blog_id = $ping->blog_id;
        require MT::Blog;
        $blog = MT::Blog->load($blog_id) or
            return $ping->error(MT->translate(
                "Load of blog '[_1]' failed: [_2]", $blog_id, MT::Blog->errstr));   
        $ping->{__blog} = $blog;
    }
    return $blog;
}

sub parent {
    my ($ping) = @_;
    require MT::Trackback;
    my $tb = MT::Trackback->load($ping->tb_id);
    if ($tb->entry_id) {
        return MT::Entry->load($tb->entry_id);
    } else {
        return MT::Category->load($tb->category_id);
    }
}

sub parent_id {
    my ($ping) = @_;
    require MT::Trackback;
    my $tb = MT::Trackback->load($ping->tb_id);
    if ($tb->entry_id) {
        return ('MT::Entry', $tb->entry_id);
    } else {
        return ('MT::Category', $tb->category_id);
    }
}

sub next {
    my $ping = shift;
    my($publish_only) = @_;
    unless ($ping->{__next} || !$ping->created_on) {
        $ping->{__next} = MT::TBPing->load(
            { blog_id => $ping->blog_id,
              $publish_only ? ('visible' => 1) : ()
            },
            { limit => 1,
              'sort' => 'created_on',
              direction => 'ascend',
              start_val => $ping->created_on });
    }
    $ping->{__next}; 
}

sub previous {
    my $ping = shift;
    my($publish_only) = @_;
    unless ($ping->{__previous}) {
        $ping->{__previous} = MT::TBPing->load(
            { blog_id => $ping->blog_id,
              $publish_only ? ('visible' => 1) : ()
            },
            { limit => 1,
              'sort' => 'created_on',
              direction => 'descend',
              start_val => $ping->created_on });
    }
    $ping->{__previous};
}

sub junk {
    my $ping = shift;
    if (($ping->junk_status || 0) != JUNK) {
        require MT::Util;
        my @ts = MT::Util::offset_time_list(time, $ping->blog_id);
        my $ts = sprintf("%04d%02d%02d%02d%02d%02d",
                         $ts[5]+1900, $ts[4]+1, @ts[3,2,1,0]);
        $ping->last_moved_on($ts);
    }
    $ping->junk_status(JUNK);
    $ping->visible(0);
}

sub moderate {
    my $ping = shift;
    $ping->visible(0);
#    $ping->junk_status(NOT_JUNK);
}

sub approve {
    my $ping = shift;
    $ping->visible(1);
    $ping->junk_status(NOT_JUNK);
}

sub all_text {
    my $this = shift;
    my $text = $this->column('blog_name') || '';
    $text .= "\n" . ($this->column('email') || '');
    $text .= "\n" . ($this->column('source_url') || '');
    $text .= "\n" . ($this->column('excerpt') || '');
    $text;
}

1;
__END__

=head1 NAME

MT::TBPing - Movable Type TrackBack Ping record

=head1 SYNOPSIS

    use MT::TBPing;
    my $ping = MT::TBPing->new;
    $ping->blog_id($tb->blog_id);
    $ping->tb_id($tb->id);
    $ping->title('Foo');
    $ping->excerpt('This is from a TrackBack ping.');
    $ping->source_url('http://www.foo.com/bar');
    $ping->save
        or die $ping->errstr;

=head1 DESCRIPTION

An I<MT::TBPing> object represents a TrackBack ping in the Movable Type system.
It contains all of the metadata about the ping (title, excerpt, URL, etc).

=head1 USAGE

As a subclass of I<MT::Object>, I<MT::TBPing> inherits all of the
data-management and -storage methods from that class; thus you should look
at the I<MT::Object> documentation for details about creating a new object,
loading an existing object, saving an object, etc.

=head1 DATA ACCESS METHODS

The I<MT::TBPing> object holds the following pieces of data. These fields can
be accessed and set using the standard data access methods described in the
I<MT::Object> documentation.

=over 4

=item * id

The numeric ID of the ping.

=item * blog_id

The numeric ID of the blog in which the ping is found.

=item * tb_id

The numeric ID of the TrackBack record (I<MT::Trackback> object) to which
the ping was sent.

=item * title

The title of the ping item.

=item * ip

The IP address of the server that sent the ping.

=item * excerpt

The excerpt of the ping item.

=item * source_url

The URL of the item pointed to by the ping.

=item * blog_name

The name of the blog on which the original item was posted.

=item * created_on

The timestamp denoting when the ping record was created, in the format
C<YYYYMMDDHHMMSS>. Note that the timestamp has already been adjusted for the
selected timezone.

=item * modified_on

The timestamp denoting when the ping record was last modified, in the
format C<YYYYMMDDHHMMSS>. Note that the timestamp has already been adjusted
for the selected timezone.

=back

=head1 DATA LOOKUP

In addition to numeric ID lookup, you can look up or sort records by any
combination of the following fields. See the I<load> documentation in
I<MT::Object> for more information.

=over 4

=item * created_on

=item * tb_id

=item * blog_id

=item * ip

=back

=head1 AUTHOR & COPYRIGHTS

Please see the I<MT> manpage for author, copyright, and license information.

=cut
