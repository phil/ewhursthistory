# $Id: Link.pm 4536 2004-05-11 05:33:05Z btrott $

package XML::Atom::Link;
use strict;

use XML::Atom;
use base qw( XML::Atom::ErrorHandler );

use constant NS => 'http://purl.org/atom/ns#';

sub new {
    my $class = shift;
    my $link = bless {}, $class;
    $link->init(@_) or return $class->error($link->errstr);
    $link;
}

sub init {
    my $link = shift;
    my %param = @_ == 1 ? (Body => $_[0]) : @_;
    my $elem;
    unless ($elem = $param{Elem}) {
        if (LIBXML) {
            my $doc = XML::LibXML::Document->createDocument('1.0', 'utf-8');
            $elem = $doc->createElementNS(NS, 'link');
            $doc->setDocumentElement($elem);
        } else {
            $elem = XML::XPath::Node::Element->new('link');
            my $ns = XML::XPath::Node::Namespace->new('#default' => NS);
            $elem->appendNamespace($ns);
        }
    }
    $link->{elem} = $elem;
    $link;
}

sub elem { $_[0]->{elem} }

sub get {
    my $link = shift;
    my($attr) = @_;
    my $val = $link->elem->getAttribute($attr);
    if ($] >= 5.008) {
        require Encode;
        Encode::_utf8_off($val);
    }
    $val;
}

sub set {
    my $link = shift;
    my($attr, $val) = @_;
    $link->elem->setAttribute($attr, $val);
}

sub as_xml {
    my $link = shift;
    if (LIBXML) {
        my $doc = XML::LibXML::Document->new('1.0', 'utf-8');
        $doc->setDocumentElement($link->elem);
        return $doc->toString(1);
    } else {
        return '<?xml version="1.0" encoding="utf-8"?>' . "\n" .
            $link->elem->toString;
    }
}

sub DESTROY { }

use vars qw( $AUTOLOAD );
sub AUTOLOAD {
    (my $var = $AUTOLOAD) =~ s!.+::!!;
    no strict 'refs';
    *$AUTOLOAD = sub {
        @_ > 1 ? $_[0]->set($var, @_[1..$#_]) : $_[0]->get($var)
    };
    goto &$AUTOLOAD;
}

1;
