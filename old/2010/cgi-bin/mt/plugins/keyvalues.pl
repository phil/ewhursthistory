# ---------------------------------------------------------------------------
# Key Values
# A Plugin for Movable Type
#
# Release 1.53
# August 23, 2002
#
# From Brad Choate
# http://www.bradchoate.com/
# ---------------------------------------------------------------------------
# This software is provided as-is.
# You may use it for commercial or personal use.
# If you distribute it, please keep this notice intact.
#
# Copyright (c) 2002 Brad Choate
# ---------------------------------------------------------------------------

use strict;

use MT::Template::Context;

MT::Template::Context->add_container_tag(KeyValues => \&KeyValues);
MT::Template::Context->add_container_tag(KeyValuesHeader => \&MT::Template::Context::_hdlr_pass_tokens);
MT::Template::Context->add_container_tag(KeyValuesFooter => \&MT::Template::Context::_hdlr_pass_tokens);
MT::Template::Context->add_tag(KeyName => \&KeyName);
MT::Template::Context->add_tag(KeyValue => \&KeyValue);
MT::Template::Context->add_tag(KeyValuesStripped => \&KeyValuesStripped);
MT::Template::Context->add_container_tag(IfKeyExists => \&IfKeyExists);
MT::Template::Context->add_container_tag(IfNoKeyExists => \&IfNoKeyExists);
MT::Template::Context->add_container_tag(IfKeyMatches => \&IfKeyMatches);
MT::Template::Context->add_container_tag(IfKeyNotMatched => \&IfKeyNotMatched);

sub KeyValues {
  require bradchoate::keyvalues;
  &bradchoate::keyvalues::KeyValues;
}

sub KeyValuesStripped {
  require bradchoate::keyvalues;
  &bradchoate::keyvalues::KeyValuesStripped;
}

sub KeyValue {
  require bradchoate::keyvalues;
  &bradchoate::keyvalues::KeyValue;
}

sub KeyName {
  require bradchoate::keyvalues;
  &bradchoate::keyvalues::KeyName;
}

sub IfKeyExists {
  require bradchoate::keyvalues;
  &bradchoate::keyvalues::IfKeyExists;
}

sub IfNoKeyExists {
  require bradchoate::keyvalues;
  &bradchoate::keyvalues::IfNoKeyExists;
}

sub IfKeyMatches {
  require bradchoate::keyvalues;
  &bradchoate::keyvalues::IfKeyMatches;
}

sub IfKeyNotMatched {
  require bradchoate::keyvalues;
  &bradchoate::keyvalues::IfKeyNotMatched;
}

1;
