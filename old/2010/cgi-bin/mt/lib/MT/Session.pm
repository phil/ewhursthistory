# Copyright 2001-2005 Six Apart. This code cannot be redistributed without
# permission from www.sixapart.com.  For more information, consult your
# Movable Type license.
#
# $Id: Session.pm 15432 2005-07-29 20:41:11Z bchoate $

package MT::Session;
use strict;

use MT::Object;
@MT::Session::ISA = qw( MT::Object );
__PACKAGE__->install_properties({
    column_defs => {
        'id' => 'string(80) not null primary key',
        'data' => 'blob',
        'email' => 'string(255)',
        'name' => 'string(255)',
        'kind' => 'string(2)',
        'start' => 'integer not null',
    },
    indexes => {
        'start' => 1,
        'kind' => 1
    },
    datasource => 'session',
});

sub get_unexpired_value {
    my $timeout = shift;
    my $candidate = __PACKAGE__->load(@_);
    if ($candidate && $candidate->start() < time - $timeout) {
        $candidate->remove();
        $candidate = undef;
    }
    return $candidate;
}

sub save {
    my $sess = shift;
    if (my $data = $sess->{__data}) {
        require MT::Serialize;
        my $ser = MT::Serialize->serialize(\$data);
        $sess->data($ser);
    }
    $sess->{__dirty} = 0;
    $sess->SUPER::save(@_);
}

sub is_dirty {
    my $sess = shift;
    $sess->{__dirty};
}

sub thaw_data {
    my $sess = shift;
    return $sess->{__data} if $sess->{__data};
    my $data = $sess->data;
    $data = '' unless $data;
    require MT::Serialize;
    my $out = MT::Serialize->unserialize($data);
    if (ref $out eq 'REF') {
        $sess->{__data} = $$out;
    } else {
        $sess->{__data} = {};
    }
    $sess->{__dirty} = 0;
    $sess->{__data};
}

sub get {
    my $sess = shift;
    my ($var) = @_;
    my $data = $sess->thaw_data;
    $data->{$var};
}

sub set {
    my $sess = shift;
    my ($var, $val) = @_;
    my $data = $sess->thaw_data;
    $sess->{__dirty} = 1;
    $data->{$var} = $val;
}

1;

__END__

=pod

=head1 NAME

MT::Session - temporary storage of arbitrary data.

=head1 SYNOPSIS

Provides for the storage of arbitrary temporary data. The name
"session" is a hold-over from the days when commenter sessions were
the only kind of temporary data that MT stored.

A piece of temporary data is identified uniquely by an ID, but it also
has a "kind," a two-character identifier that separates different
usages of the table. The C<id> value must be distinct across all
kinds.

Each kind is associated with a fixed timeout window; records older
than that amount are deleted automatically.  Currently-used kinds are
as follows:

=over 4

=item SI

Active commenter sessions are held in SI sessions.

=item KY

The public key of the remote comment authentication service is held in
the I<single> record of kind 'KY'.

=item AN

"Nonce" values (used for certain authentication systems) are stored
with a kind of 'AN'.

=item US

Active user sessions are held in 'US' records.

=item NW

The cached contents of the newsbox (top right of MT's welcome screen)
is held in the I<single> record of kind 'NW'.

=head1 METHODS

=head2 $sess = MT::Session->get_unexpired_value($timeout,
                                        [ $terms, [ $args, ... ] ]);

Fetches the specified session record, if it is current (its C<start>
field falls within last $timeout seconds). Arguments following the
$timeout argument are passed directly to C<MT::Object::load>.

=cut
