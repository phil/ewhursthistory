# $Id: Thing.pm 4540 2004-05-11 08:01:31Z btrott $

package XML::Atom::Thing;
use strict;

use XML::Atom;
use base qw( XML::Atom::ErrorHandler );
use XML::Atom::Util qw( first );
use XML::Atom::Link;
use LWP::UserAgent;
BEGIN {
    if (LIBXML) {
        *init = \&init_libxml;
        *set = \&set_libxml;
        *link = \&link_libxml;
    } else {
        *init = \&init_xpath;
        *set = \&set_xpath;
        *link = \&link_xpath;
    }
}

use constant NS => 'http://purl.org/atom/ns#';

sub new {
    my $class = shift;
    my $atom = bless {}, $class;
    $atom->init(@_) or return $class->error($atom->errstr);
    $atom;
}

sub init_libxml {
    my $atom = shift;
    my %param = @_ == 1 ? (Stream => $_[0]) : @_;
    if (%param) {
        if (my $stream = $param{Stream}) {
            my $parser = XML::LibXML->new;
            if (ref($stream) eq 'SCALAR') {
                $atom->{doc} = $parser->parse_string($$stream);
            } elsif (ref($stream)) {
                $atom->{doc} = $parser->parse_fh($stream);
            } else {
                $atom->{doc} = $parser->parse_file($stream);
            }
        } elsif (my $doc = $param{Doc}) {
            $atom->{doc} = $doc;
        } elsif (my $elem = $param{Elem}) {
            $atom->{doc} = XML::LibXML::Document->createDocument('1.0', 'utf-8');
            $atom->{doc}->setDocumentElement($elem);
        }
    } else {
        my $doc = $atom->{doc} = XML::LibXML::Document->createDocument('1.0', 'utf-8');
        my $root = $doc->createElementNS(NS, $atom->element_name);
        $doc->setDocumentElement($root);
    }
    $atom;
}

sub init_xpath {
    my $atom = shift;
    my %param = @_ == 1 ? (Stream => $_[0]) : @_;
    my $elem_name = $atom->element_name;
    if (%param) {
        if (my $stream = $param{Stream}) {
            my $xp;
            if (ref($stream) eq 'SCALAR') {
                $xp = XML::XPath->new(xml => $$stream);
            } elsif (ref($stream)) {
                $xp = XML::XPath->new(ioref => $stream);
            } else {
                $xp = XML::XPath->new(filename => $stream);
            }
            my $set = $xp->find('/' . $elem_name);
            unless ($set && $set->size) {
                $set = $xp->find('/');
            }
            $atom->{doc} = ($set->get_nodelist)[0];
        } elsif (my $doc = $param{Doc}) {
            $atom->{doc} = $doc;
        } elsif (my $elem = $param{Elem}) {
            my $xp = XML::XPath->new(context => $elem);
            my $set = $xp->find('/' . $elem_name);
            unless ($set && $set->size) {
                $set = $xp->find('/');
            }
            $atom->{doc} = ($set->get_nodelist)[0];
        }
    } else {
        my $xp = XML::XPath->new;
        $xp->set_namespace(atom => NS);
        $atom->{doc} = XML::XPath::Node::Element->new($atom->element_name);
        my $ns = XML::XPath::Node::Namespace->new('#default' => NS);
        $atom->{doc}->appendNamespace($ns);
    }
    $atom;
}

sub get {
    my $atom = shift;
    my($ns, $name) = @_;
    my $ns_uri = ref($ns) eq 'XML::Atom::Namespace' ? $ns->{uri} : $ns;
    my $node = first($atom->{doc}, $ns_uri, $name);
    return unless $node;
    my $val = LIBXML ? $node->textContent : $node->string_value;
    if ($] >= 5.008) {
        require Encode;
        Encode::_utf8_off($val);
    }
    $val;
}

sub set_libxml {
    my $atom = shift;
    my($ns, $name, $val, $attr) = @_;
    my $elem;
    my $ns_uri = ref($ns) eq 'XML::Atom::Namespace' ? $ns->{uri} : $ns;
    unless ($elem = first($atom->{doc}, $ns_uri, $name)) {
        $elem = $atom->{doc}->createElementNS($ns_uri, $name);
        $atom->{doc}->getDocumentElement->appendChild($elem);
    }
    if ($ns ne NS) {
        $atom->{doc}->getDocumentElement->setNamespace($ns->{uri}, $ns->{prefix}, 0);
    }
    if (ref($val) =~ /Element$/) {
        $elem->appendChild($val);
    } elsif (defined $val) {
        $elem->removeChildNodes;
        my $text = XML::LibXML::Text->new($val);
        $elem->appendChild($text);
    }
    if ($attr) {
        while (my($k, $v) = each %$attr) {
            $elem->setAttribute($k, $v);
        }
    }
    $val;
}

sub set_xpath {
    my $atom = shift;
    my($ns, $name, $val, $attr) = @_;
    my $elem;
    my $ns_uri = ref($ns) eq 'XML::Atom::Namespace' ? $ns->{uri} : $ns;
    unless ($elem = first($atom->{doc}, $ns_uri, $name)) {
        $elem = XML::XPath::Node::Element->new($name);
        if ($ns ne NS) {
            my $ns = XML::XPath::Node::Namespace->new($ns->{prefix} => $ns->{uri});
            $elem->appendNamespace($ns);
        }
        $atom->{doc}->appendChild($elem);
    }
    if (ref($val) =~ /Element$/) {
        $elem->appendChild($val);
    } elsif (defined $val) {
        $elem->removeChild($_) for $elem->getChildNodes;
        my $text = XML::XPath::Node::Text->new($val);
        $elem->appendChild($text);
    }
    if ($attr) {
        while (my($k, $v) = each %$attr) {
            $elem->setAttribute($k, $v);
        }
    }
    $val;
}

sub add_link {
    my $thing = shift;
    my($link) = @_;
    my $elem;
    if (LIBXML) {
        $elem = $thing->{doc}->createElementNS(NS, 'link');
        $thing->{doc}->getDocumentElement->appendChild($elem);
    } else {
        $elem = XML::XPath::Node::Element->new('link');
        my $ns = XML::XPath::Node::Namespace->new('#default' => NS);
        $elem->appendNamespace($ns);
        $thing->{doc}->appendChild($elem);
    }
    if (ref($link) eq 'XML::Atom::Link') {
        for my $k (qw( type rel href title )) {
            $elem->setAttribute($k, $link->$k());
        }
    } elsif (ref($link) eq 'HASH') {
        for my $k (qw( type rel href title )) {
            $elem->setAttribute($k, $link->{$k});
        }
    }
}

sub link_libxml {
    my $thing = shift;
    if (wantarray) {
        my @res = $thing->{doc}->getDocumentElement->getChildrenByTagNameNS(NS, 'link');
        my @links;
        for my $elem (@res) {
            push @links, XML::Atom::Link->new(Elem => $elem);
        }
        return @links;
    } else {
        my $elem = first($thing->{doc}, NS, 'link') or return;
        return XML::Atom::Link->new(Elem => $elem);
    }
}

sub link_xpath {
    my $thing = shift;
    if (wantarray) {
        my $set = $thing->{doc}->find("*[local-name()='link' and namespace-uri()='" . NS . "']");
        my @links;
        for my $elem ($set->get_nodelist) {
            push @links, XML::Atom::Link->new(Elem => $elem);
        }
        return @links;
    } else {
        my $elem = first($thing->{doc}, NS, 'link') or return;
        return XML::Atom::Link->new(Elem => $elem);
    }
}

sub as_xml {
    my $doc = $_[0]->{doc};
    return $doc->toString(LIBXML ? 1 : 0);
}

sub DESTROY { }

use vars qw( $AUTOLOAD );
sub AUTOLOAD {
    (my $var = $AUTOLOAD) =~ s!.+::!!;
    no strict 'refs';
    *$AUTOLOAD = sub {
        @_ > 1 ? $_[0]->set(NS, $var, @_[1..$#_]) : $_[0]->get(NS, $var)
    };
    goto &$AUTOLOAD;
}

1;
