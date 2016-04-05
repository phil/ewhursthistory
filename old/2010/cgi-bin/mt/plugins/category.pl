#!/usr/bin/perl

package MT::Plugins::Category;

use strict;
use MT::Template::Context;

use vars qw( $VERSION );
my $VERSION = "0.5";

use MT::Category;
use MT::Placement;
use MT::Promise qw( delay );
use MT::Entry;

MT::Template::Context->add_container_tag (Category => sub {
    my ($ctx, $args) = @_;
    my $blog_id = $ctx->stash ('blog_id');

    my $name = $args->{name} or return $ctx->error ('Name argument required');
    my $builder = $ctx->stash ('builder');
    my $tokens = $ctx->stash ('tokens');
 
    if ($name =~ s/\[(\/?MT[^\]]+)\]/\<$1\>/g) {
      my $tok = $builder->compile ($ctx, $name);
      defined ($name = $builder->build ($ctx, $tok))
        or return $ctx->error ($builder->errstr);
    }

    require MT::Category;
    my $cat;

    $cat = MT::Category->load ({ label => $name, blog_id => $blog_id }) 
      or return $ctx->error (MT->translate (
	  "Category '[_1]' not found in Blog '[_2]'", $name, $blog_id));

    return '' if (!$cat);
    
    local $ctx->{__stash}{category} = $cat;
    local $ctx->{inside_mt_categories} = 1;

    local $ctx->{__stash}{entries};
    local $ctx->{__stash}{category_count};
    my @args = (
	{ blog_id => $blog_id,
	  status => MT::Entry::RELEASE() },
	{ 'join' => [ 'MT::Placement', 'entry_id',
	              { category_id => $cat->id } ],
	  'sort' => 'created_on',
	  direction => 'descend', });
    if ($ctx->stash ('uncompiled') =~  /<\$?MTEntries/) {
      my @entries = MT::Entry->load(@args);

      $ctx->{__stash}{entries} = delay(sub{\@entries});
      $ctx->{__stash}{category_count} = scalar @entries;
    } else {
      $ctx->{__stash}{category_count} = MT::Entry->count (@args);
    }
    defined (my $out = $builder->build ($ctx, $tokens))
      or return $ctx->error ($ctx->errstr);

    $out;  
    });
