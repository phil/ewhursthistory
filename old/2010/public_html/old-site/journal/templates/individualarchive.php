<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en" xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
	<title>Journal, <$MTEntryTitle$></title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<meta name="description" content="<$MTEntryExcerpt smarty_pants="1"$>" />
	<meta name="keywords" content="whatisnext, What Is Next, Next Century Systems, Next, XHTML, HTML, XML, CSS" />

	<meta name="author" content="Phil Balchin" />
	<meta name="Copyright" content="Copyright (c) 2005 Next Century Systems" />
		
	<link rel="shortcut icon" href="/favicon.ico" />

<link rel="alternate" type="application/atom+xml" title="Atom" href="<$MTBlogURL$>syndicate/atom.xml" />
<link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="<$MTBlogURL$>syndicate/rss.xml" />
<link rel="EditURI" type="application/rsd+xml" title="RSD" href="<$MTBlogURL$>rsd.xml" />

<link rel="stylesheet" href="<$MTBlogURL$>css/screen.css" type="text/css" media="screen" />
<link rel="stylesheet" href="<$MTBlogURL$>css/print.css" type="text/css" media="print" />

<script src="/js/scripts.js" type="text/javascript"></script>
<script src="/js/jquery/jquery.js" type="text/javascript"></script>
<script src="/mint/?js" type="text/javascript"></script>

<!-- CCLicense
   <MTBlogIfCCLicense>
   <$MTCCLicenseRDF$>
   </MTBlogIfCCLicense>
-->
</head>

<body id="body-journal">
<? include($_SERVER['DOCUMENT_ROOT']."/ssi/skiptocontent.php") ?>
<? include($_SERVER['DOCUMENT_ROOT']."/ssi/masthead.php") ?>
<? include($_SERVER['DOCUMENT_ROOT']."/ssi/navigation.php") ?>

<div id="wrapper">

<div class="jounal-navigator">
	<MTEntryPrevious>
	<a href="<$MTEntryPermalink$>" class="previous-entry"><$MTEntryTitle  smarty_pants="1"$></a>
	</MTEntryPrevious>

	<a href="<$MTBlogURL$>" class="journal-index">Journal Front Page</a>
	
	<MTEntryNext>
	<a href="<$MTEntryPermalink$>" class="next-entry"><$MTEntryTitle  smarty_pants="1"$></a>
	</MTEntryNext>
</div>    

		<div id="entry-<$MTEntryID$>" class="entry">
					
			<h1><$MTEntryTitle  smarty_pants="1"$></h1>
					
			<div class="entry-body">
				<$MTEntryBody  smarty_pants="1"$>
			</div>
					
			<div class="entry-more">
            			<$MTEntryMore  smarty_pants="1"$>
			</div>
			
		</div>
	</div>
</div>

<MTIfCommentsActive>
<div id="comment-wrapper" class="section-wrapper">
	<div id="comments" class="section">
	
			<MTComments>
			<MTCommentsHeader><h3 class="comments-header">Comments</h3></MTCommentsHeader>
			<ol id="comment-list">
				<li>
				<div id="c<$MTCommentID pad="1"$>">Posted by:<$MTCommentAuthorLink default_name="Anonymous"$> <$MTCommentAuthorIdentity$> | <$MTCommentDate$></div>
				<div><$MTCommentBody smarty_pants="1"$></div>
				</li>
			</ol>
			</MTComments>
				
			<MTEntryIfCommentsOpen> 
			<form method="post" action="<$MTCGIPath$><$MTCommentScript$>" name="comments_form" onsubmit="if (this.bakecookie.checked) rememberMe(this)">
				<input type="hidden" name="static" value="1" />
				<input type="hidden" name="entry_id" value="<$MTEntryID$>" />
					   
				<div class="comments-open" id="comments-open">
					<h2 class="comments-open-header">Post a comment</h2>
							  
					<div class="comments-open-content">
						<script type="text/javascript">
						<!--
							writeTypeKeyGreeting(commenter_name, <$MTEntryID$>);
						//-->
						</script>
							  
						<MTIfCommentsModerated>
						<p class="comments-open-moderated">(If you haven't left a comment here before, you may need to be approved by the site owner before your comment will appear. Until then, it won't appear on the entry. Thanks for waiting.)</p>
						</MTIfCommentsModerated>
		
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
								<dt><label for="comment-text">Comments: <MTIfAllowCommentHTML>(you may use HTML tags for style)</MTIfAllowCommentHTML></label></dt>
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
			</MTEntryIfCommentsOpen>
		</div>
		
		<div class="section-end"></div>
		
	</div>			
</div>
</MTIfCommentsActive>

<? include($_SERVER['DOCUMENT_ROOT']."/ssi/footer.php") ?>

</body>
</html>