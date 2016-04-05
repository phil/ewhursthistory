<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en" xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
	<title>Journal, Styling the Flickr Badge</title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<meta name="description" content="As I&#8217;m going around trying to smarten this place up, I ran into a problem with the Flickr Badge. First, It has a maximum of ten image thumbs. Second, even the small thumbnails are pretty big. Time to get out&#8230;" />
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
	
	<a href="http://www.whatisnext.co.uk/journal/2006/04/please_excuse_the_mess.php" class="previous-entry">Please excuse the mess</a>
	

	<a href="http://www.whatisnext.co.uk/journal/" class="journal-index">Journal Front Page</a>
	
	
	<a href="http://www.whatisnext.co.uk/journal/2006/05/may_4th.php" class="next-entry">May 4th</a>
	
</div>    

		<div id="entry-560" class="entry">
					
			<h1>Styling the Flickr Badge</h1>
					
			<div class="entry-body">
				<p>As I&#8217;m going around trying to smarten this place up, I ran into a problem with the Flickr Badge. <em>First,</em> It has a maximum of ten image thumbs. <em>Second,</em> even the small thumbnails are pretty big. Time to get out the coding equivilent of an axe.</p>
			</div>
					
			<div class="entry-more">
            			<h2>First, the Limited number of images</h2>

<p>When you do the wizard on Flickr to create a badge of your photos, it has a limited number of options to change the number of photos to display. Ok, this is easliy hacked by changing the code at the end, nut it max&#8217;s out at 10. Even if you type 30, it will only display 10. So, getting around this should be easy, simply paste the code more than once into your <span class="caps">HTML.</span> Nope! You&#8217;ll get the same ten photos twice, notsure if this is a bug or deliberate, but it&#8217;s not quite what we were looking for. Try making another badge that only gets its photos from one of your tags, or random, or set etc. </p>

<h2>Making the Thumbs smaller</h2>

<p>Next up, the default small thumbnail was too big to sit nicly into my design idea. To correct this, <strong>[CSS enters stage right]</strong> we&#8217;ll be using our friend <span class="caps">CSS.</span> Forcing a width and height onto <code>.flickr_badge_image a img</code> resizes the img. Obviously only resize an image smaller than the original, and try to keep the proportion correct. I&#8217;ve used 32&#215;32 pixels as its about half the size of 75&#215;75 pixels.</p>
			</div>
			
		</div>
	</div>
</div>


<div id="comment-wrapper" class="section-wrapper">
	<div id="comments" class="section">
	
			
				
			 
			<form method="post" action="http://www.whatisnext.co.uk/cgi-bin/mt/mt-comments.cgi" name="comments_form" onsubmit="if (this.bakecookie.checked) rememberMe(this)">
				<input type="hidden" name="static" value="1" />
				<input type="hidden" name="entry_id" value="560" />
					   
				<div class="comments-open" id="comments-open">
					<h2 class="comments-open-header">Post a comment</h2>
							  
					<div class="comments-open-content">
						<script type="text/javascript">
						<!--
							writeTypeKeyGreeting(commenter_name, 560);
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