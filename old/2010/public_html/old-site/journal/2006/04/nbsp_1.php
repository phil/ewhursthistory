<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en" xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
	<title>Journal, &amp;nbsp;</title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<meta name="description" content="There was once a time when I could type this character combination without having to think too much about what order the &#8216;n&#8217;, &#8216;b&#8217;, &#8216;s&#8217; and &#8216;p&#8217; went. For those of you who don&#8217;t know this entity very well, it&#8217;s&#8230;" />
	<meta name="keywords" content="whatisnext, What Is Next, Next Century Systems, Next, XHTML, HTML, XML, CSS" />

	<meta name="author" content="Phil Balchin" />
	<meta name="Copyright" content="Copyright (c) 2005 Next Century Systems" />
		
	<link rel="shortcut icon" href="/favicon.ico" />

<link rel="alternate" type="application/atom+xml" title="Atom" href="http://www.whatisnext.co.uk/journal/syndicate/atom.xml" />
<link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="http://www.whatisnext.co.uk/journal/syndicate/rss.xml" />
<link rel="EditURI" type="application/rsd+xml" title="RSD" href="http://www.whatisnext.co.uk/journal/rsd.xml" />

<link rel="stylesheet" href="http://www.whatisnext.co.uk/journal/css/screen.css" type="text/css" media="screen" />
<link rel="stylesheet" href="http://www.whatisnext.co.uk/journal/css/print.css" type="text/css" media="print" />

<script src="/js/scripts.js" type="text/javascript"></script>
<script src="/js/jquery/jquery.js" type="text/javascript"></script>
<script src="/mint/?js" type="text/javascript"></script>

<!-- CCLicense
   
-->
</head>

<body id="body-journal">
<? include($_SERVER['DOCUMENT_ROOT']."/ssi/skiptocontent.php") ?>
<? include($_SERVER['DOCUMENT_ROOT']."/ssi/masthead.php") ?>
<? include($_SERVER['DOCUMENT_ROOT']."/ssi/navigation.php") ?>

<div id="wrapper">

<div class="jounal-navigator">
	
	<a href="http://www.whatisnext.co.uk/journal/2006/04/new_desktops.php" class="previous-entry">New Desktops</a>
	

	<a href="http://www.whatisnext.co.uk/journal/" class="journal-index">Journal Front Page</a>
	
	
	<a href="http://www.whatisnext.co.uk/journal/2006/04/please_excuse_the_mess.php" class="next-entry">Please excuse the mess</a>
	
</div>    

		<div id="entry-557" class="entry">
					
			<h1>&amp;nbsp;</h1>
					
			<div class="entry-body">
				<p>There was once a time when I could type this character combination without having to think too much about what order the &#8216;n&#8217;, &#8216;b&#8217;, &#8216;s&#8217; and &#8216;p&#8217; went. For those of you who don&#8217;t know this entity very well, it&#8217;s the non-breaking-space entity. It used to be the most overly used of all the entities, it was the web designers best friend. So why doesn&#8217;t anyone use them anymore?</p>
			</div>
					
			<div class="entry-more">
            			<p>The reason this entity gained fame and fortune has more to do with arcane voodoo, than good coding. It was used during the great <em>table dynasty [1995&mdash;2002]</em>, when the only way to layout a two coloum grid was to have a two column table. EYou see, everything was done with tables, say you wanted a margin seperating these two columns, easy, just add another column! it really was that simple. But, this middle column wouldn&#8217;t have any text in it, it soul purpuse was to make a bit of space between the content column and the sidebar column. Which in some browsers could cause unexpected results, so any web desinger worth their namesake would simlpy add <code>&amp;amp;nbsp;</code> entity to the column.</p>

<p>Now thing have changed. The separation of structure and style has killed the need to the arcane zoodoo of table layout, and with it, the &nbsp; entity was left in the gutter <em>(litterally)</em>. The web has forgotton how useful this little entity can be.</p>

<h2>What is this &nbsp; thing anyway?</h2>

<p>Its full name is <strong>non-breaking space</strong>, its entity reference is <code>&amp;amp;nbsp;</code>, and its entity code is <code>&amp;amp;#160;</code>. As the name suggests, when rendered by a browser, it is a space, just like any other space. But, and here&#8217;s the clever bit, this space will not <em>break/wordwrap</em> at the end of a line of text. Instead, the browser will find the nearest space before and break there. Why would you want to do this? It keeps words together, thats why.</p>

<h2>Example</h2>

<p>Say i&#8217;m writing some copy for a web site, Its not much, just one paragraph about 10 lines long. At the end of the first line is the company name, &#8220;Crazyman Company&#8221;. But the &#8220;Crazyman&#8221; and the &#8220;Company&#8221; are on different lines because they don&#8217;t both fit on the first line, so &#8220;Company&#8221; gets wrapped onto the line below. Simple, instead of typing &#8220;<code>Crazyman Company</code>&#8221;, use &#8220;<code>Crazyman&amp;amp;nbsp;Company</code>. Now the browser will wrap at the space  before the &#8220;Crazyman&#8221; so the company name stays together, giving it more impact and making it easier to read.</p>

<h2><span class="caps">OK, </span>but why?</h2>

<p>Beacuse it looks nicer, you&#8217;re supposed to be a web designer? go figure.</p>
			</div>
			
		</div>
	</div>
</div>


<div id="comment-wrapper" class="section-wrapper">
	<div id="comments" class="section">
	
			
				
			 
			<form method="post" action="http://www.whatisnext.co.uk/cgi-bin/mt/mt-comments.cgi" name="comments_form" onsubmit="if (this.bakecookie.checked) rememberMe(this)">
				<input type="hidden" name="static" value="1" />
				<input type="hidden" name="entry_id" value="557" />
					   
				<div class="comments-open" id="comments-open">
					<h2 class="comments-open-header">Post a comment</h2>
							  
					<div class="comments-open-content">
						<script type="text/javascript">
						<!--
							writeTypeKeyGreeting(commenter_name, 557);
						//-->
						</script>
							  
						
		
						<div id="comments-open-data">
						<div id="name-email">
							<dl>
								<dt><label for="comment-author">Name:</label></dt>
								<dd><input id="comment-author" name="author" size="30" /></dd>
								<dt><label for="comment-email">Email:</label></dt>
								<dd><input id="comment-email" name="email" size="30" /></dd>
								<dt><label for="comment-url">URL:</label></dt>
								<dd><input id="comment-url" name="url" size="30" /></dd>
								<dt></dt>
								<dd><label for="comment-bake-cookie"><input type="checkbox"
										id="comment-bake-cookie" name="bakecookie" onclick="if (!this.checked) forgetMe(document.comments_form)" value="1" />
								<dt><label for="comment-text">Comments: (you may use HTML tags for style)</label></dt>
								<dd></dd>
							</dl>
						</div>
						</div>
		
						<p id="comments-open-text">
						
						<textarea id="comment-text" name="text" rows="10" cols="30"></textarea>
						</p>
						
						<div id="comments-open-footer" class="comments-open-footer">
						<input type="submit" accesskey="v" name="preview" id="comment-preview" value="Preview" />
						<input type="submit" accesskey="s" name="post" id="comment-post" value="Post" />
						</div>
						
					</div>
				</div>
			</form>
			
		</div>
		
		<div class="section-end"></div>
		
	</div>			
</div>


<? include($_SERVER['DOCUMENT_ROOT']."/ssi/footer.php") ?>

</body>
</html>