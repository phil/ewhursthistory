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

package bradchoate::keyvalues;

use strict;
use MT::Util qw(html_text_transform decode_html);

sub KeyValues {
  my ($ctx, $args, $cond) = @_;
  my $pattern = $args->{pattern};
  my $iterate = $args->{iterate};
  my $source = $args->{source};
  my $delimiter = $args->{delimiter} || '=';
  my $e = $ctx->stash('entry');

  if (!$e && !$source) {
    return $ctx->error("You did not provide a source for the key values.");
  }
  my $saved_more;
  my $tokens = $ctx->stash('tokens');
  my $builder = $ctx->stash('builder');
  my $t;
  if ($source) {
    $t = build_expr($ctx, $source, $cond);
    return unless defined $t;
  } else {
    $saved_more = $e->text_more;
    $t = $saved_more;
  }
  $t = '' unless defined $t;

  my $cpatt;
  if (defined $pattern) {
    require bradchoate::regex;
    $cpatt = bradchoate::regex::compile_pattern($pattern);
    return $ctx->error("Could not evaluate pattern '$pattern'.") unless defined $cpatt;
  }

  my %values;
  my @keys;
  my @lines = split /\r?\n/, $t;
  my @stripped;
  my $row = 0;
  my $count = scalar(@lines);
  my $need_closure;
  my $line;
  while ($row < $count) {
      $line = $lines[$row];
      chomp $line;
      if ($line =~ m/^[A-Z0-9][^\s]+?$delimiter/io) {
	  # key/value!
	  my ($key, $value) = $line =~ m/^([A-Z0-9][^\s]+?)$delimiter(.*)/io;
	  if ($value eq $delimiter) {
	      # read additional lines until we find '$delimiter$key'
	      $row++;
	      $need_closure = $key;
	      while ($row < $count) {
		  $line = $lines[$row];
		  chomp $line;
		  if ($line =~ m/^$delimiter$delimiter$key\s*$/) {
		      undef $need_closure;
		      last;
		  } else {
		      $value .= $line . "\n";
		  }
		  $row++;
	      }
	      chomp $value if $value;
	  }
	  if (!$cpatt || $cpatt->($key)) {
	      push @keys, lc($key);
	      $values{lc($key)} = {name => $key, value => $value};
	  }
      } else {
	  push @stripped, $line;
      }
      $row++;
  }
  if ($need_closure) {
      return $ctx->error("Key $need_closure was not closed properly: missing '$delimiter$delimiter$need_closure'");
  }
  $t = join "\n", @stripped;
  $t = '' unless defined $t;

  local $ctx->{__stash}{__keyvalues} = \%values;
  local $ctx->{__stash}{KeyValueCleanData} = $t;
  $e->text_more($t) if $e && !$source;
  my $out;
  if ((defined $iterate) && ($iterate)) {
    my $i = 0;
    foreach my $k (@keys) {
      my $key = $values{$k}{name};
      local $ctx->{__stash}{__key} = $k;
      my $res = build_out($ctx, $tokens,
			  {KeyValuesHeader => !$i,
			   KeyValuesFooter => !defined $keys[$i+1],
			   %{$cond}});
      return $ctx->error($builder->errstr) unless defined $res;
      $out .= $res;
    }
  } else {
    $out = build_out($ctx, $tokens, $cond);
    return $ctx->error($builder->errstr) unless defined $out;
  }
  # restore
  if ($e && !$source) {
    $e->text_more($saved_more);
  }
  defined $out ? $out : '';
}

sub KeyValuesStripped {
    my ($ctx, $arg) = @_;
    my $e = $_[0]->stash('entry');
    my $t = $ctx->stash('KeyValueCleanData');
    my $convert_breaks = exists $arg->{convert_breaks} ?
        $arg->{convert_breaks} :
            defined $e ? 
                ($e->convert_breaks ? $e->convert_breaks :
                    $_[0]->stash('blog')->convert_paras) : 0;
    $t = $convert_breaks ? html_text_transform($t) : $t;
    $t = '' unless defined $t;
    $t;
}

sub KeyValue {
  my ($ctx, $args, $cond) = @_;
  my $kv = $ctx->stash('__keyvalues');
  return '' unless $kv;
  my $key = $args->{key} || $ctx->stash('__key');
  $key = build_expr($ctx, $key, $cond);
  $key = lc(trim($key));
  my $default = $args->{default};
  if ($default && (!defined $kv->{$key})) {
    $default = build_expr($ctx, $default, $cond);
  }
  return (defined $default ? $default : '') unless (defined $kv) && $key && (exists $kv->{$key});
  $kv->{$key}{value};
}

sub KeyName {
  my ($ctx, $args, $cond) = @_;
  my $kv = $ctx->stash('__keyvalues');
  my $key = $args->{key} || $ctx->stash('__key');
  $key = build_expr($ctx, $key, $cond);
  $key = lc(trim($key));
  return '' unless (defined $kv) && $key;
  $kv->{$key}{name} || '';
}

sub IfKeyExists {
  my ($ctx, $args, $cond) = @_;
  my $key = $args->{key};
  $key = build_expr($ctx, $key, $cond);
  $key = lc(trim($key));
  my $kv = $ctx->stash('__keyvalues');
  return '' unless (defined $key) && (defined $kv);
  my $res = '';
  if (exists $kv->{$key}) {
    $res = build_out($ctx, undef, $cond);
  }
  $res;
}

sub IfNoKeyExists {
  my ($ctx, $args, $cond) = @_;
  my $key = $args->{key};
  $key = build_expr($ctx, $key, $cond);
  $key = lc(trim($key));
  my $kv = $ctx->stash('__keyvalues');
  return '' unless (defined $key) && (defined $kv);
  my $res = '';
  if (!exists $kv->{$key}) {
    $res = build_out($ctx, undef, $cond);
  }
  $res;
}

sub IfKeyMatches {
  my ($ctx, $args, $cond) = @_;
  my $key = $args->{key} || $ctx->stash('__key');
  $key = build_expr($ctx, $key, $cond);
  $key = lc(trim($key));
  my $value = trim($args->{value});
  my $pattern = $args->{pattern};
  my $kv = $ctx->stash('__keyvalues');
  return '' unless (defined $key) && (defined $kv);
  my $res = '';
  if (defined $pattern) {
    require bradchoate::regex;
    my $cpatt = bradchoate::regex::compile_pattern($pattern);
    return $ctx->error("Could not evaluate pattern '$pattern'") unless defined $cpatt;
    if ($cpatt->($kv->{$key}{value} || '')) {
      $res = build_out($ctx, undef, $cond);
      $kv->{$key}{matched} = 1;
    }
  } elsif (defined $value) {
    my $keyvalue = $kv->{$key}{value};
    if ((defined $keyvalue) && ($keyvalue eq $value)) {
      $res = build_out($ctx, undef, $cond);
      $kv->{$key}{matched} = 1;
    }
  }
  $res;
}

sub IfKeyNotMatched {
  my ($ctx, $args, $cond) = @_;
  my $key = $args->{key} || $ctx->stash('__key');
  $key = build_expr($ctx, $key, $cond);
  $key = lc(trim($key));
  my $kv = $ctx->stash('__keyvalues');
  return '' unless defined $kv;
  my $res = '';
  if (!$kv->{$key}{matched}) {
    $res = build_out($ctx, undef, $cond);
  }
  $res;
}

sub build_out {
  my ($ctx, $tok, $cond) = @_;
  $tok = $ctx->stash('tokens') unless defined $tok;
  my $builder = $ctx->stash('builder');
  my $out = $builder->build($ctx, $tok, $cond);
  return $ctx->error($builder->errstr) unless defined $out;
  $out;
}

sub build_expr {
  my ($ctx, $val, $cond) = @_;
  $val = decode_html($val);
  if (($val =~ m/\<MT.*?\>/) ||
      ($val =~ s/\[(\/?MT(.*?))\]/\<$1\>/g)) {
    my $builder = $ctx->stash('builder');
    my $tok = $builder->compile($ctx, $val);
    defined($val = $builder->build($ctx, $tok, $cond))
      or return $ctx->error($builder->errstr);
  }
  defined $val ? $val : '';
}

sub trim {
  my ($s) = @_;
  return $s unless defined $s;
  for ($s) {
    s/^\s+//;
    s/\s+$//;
  }
  $s;
}

1;
