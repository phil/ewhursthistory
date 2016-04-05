<?php

$HeadTitle = "<$MTBlogName encode_html="1"$>: <$MTEntryTitle remove_html="1"$>";
$HeadDescription = "";
$HeadKeywords = "";

$HeadLinks = array(
	'<link rel="start" href="<$MTBlogURL$>" title="Home" />',
	'<link rel="alternate" type="application/atom+xml" title="Atom" href="<$MTBlogURL$>atom.xml" />',
	'<link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="<$MTBlogURL$>index.xml" />',
	'<link rel="EditURI" type="application/rsd+xml" title="RSD" href="<$MTBlogURL$>rsd.xml" />',
	'<script src="/js/scripts.js" type="text/javascript"></script>',
	'<MTEntryPrevious><link rel="prev" href="<$MTEntryPermalink$>" title="<$MTEntryTitle encode_html="1"$>" /></MTEntryPrevious>',
	'<MTEntryNext><link rel="next" href="<$MTEntryPermalink$>" title="<$MTEntryTitle encode_html="1"$>" /></MTEntryNext>');


	include($_SERVER['DOCUMENT_ROOT'].'/ecc/ssi/htmlhead.php');
?>
<body id="BodyBlog">
<div id="Wrapper" class="Relative">
	
	<?php include($_SERVER['DOCUMENT_ROOT'].'/ecc/ssi/masthead.php'); ?>
	
	<?php include($_SERVER['DOCUMENT_ROOT'].'/ecc/ssi/eccexplorer.php'); ?>
	
	<div id="DocumentWrapper">
	<div id="Document">
	
		<div id="DocumentContent">
			<p class="BlogEntryNav">
				<MTEntryPrevious><a href="<$MTEntryPermalink$>">&laquo; <$MTEntryTitle$></a> | </MTEntryPrevious>
				<a href="<$MTBlogURL$>">Main</a>
				<MTEntryNext> | <a href="<$MTEntryPermalink$>"><$MTEntryTitle$> &raquo;</a></MTEntryNext>
			</p>

			<$MTEntryTrackbackData$>
			
			<h1><a href="<$MTEntryPermalink$>"><$MTEntryTitle$></a></h1>
			<h2><MTDateHeader><$MTEntryDate format="%x"$></MTDateHeader></h2>
			<div class="EntryContent">
				<div class="EntryBody">
					<$MTEntryBody$>
				</div>
				<div id="more" class="EntryMore">
					<$MTEntryMore$>
				</div>
			</div>

			<MTIfCommentsActive>
			<div id="comments">
		
				<MTCommentsHeader><h2>Comments</h2></MTCommentsHeader>
		
				<ul id="PostedComments">
					<MTComments>
					<li id="c<$MTCommentID pad="1"$>" class="comment">
						<$MTCommentBody$>
						<p class="CommentInfo">Posted <a href="#comment-<$MTCommentID$>"><$MTCommentDate$></a> by <$MTCommentAuthorLink default_name="Anonymous"$> <$MTCommentAuthorIdentity$></p>
					</li>
					</MTComments>
				</ul>
		
				<MTEntryIfCommentsOpen> 
				<form method="post" action="<$MTCGIPath$><$MTCommentScript$>" name="CommentsForm" id="CommentsForm" onsubmit="if (this.bakecookie.checked) rememberMe(this)">	
					<input type="hidden" name="static" value="1" />
					<input type="hidden" name="entry_id" value="<$MTEntryID$>" />
		
					<h2>Post a comment</h2>
		
		         <MTIfCommentsModerated>
		         <p class="CommentsModerated">If you haven't left a comment here before, you gonn need to be approved by E.C.C before your comment will appear. Until then, it won't appear on the entry. Thanks for waiting. This is only really here to stop <a href="www.bernardbrace.co.uk">Bernard Brace</a> from abusing the commenting system.</p>
		         </MTIfCommentsModerated>
		
					<p id="CommenterName"><label for="comment-author">Name:</label><input id="comment-author" name="author" size="30" /></p>
					<p id="CommenterEmail"><label for="comment-email">Email Address:</label><input id="comment-email" name="email" size="30" /></p>
					<p id="CommenterUrl"><label for="comment-url">URL:</label><input id="comment-url" name="url" size="30" /></p>
					<p id="CommenterCookie"><label for="comment-bake-cookie"><input type="checkbox" id="comment-bake-cookie" name="bakecookie" onclick="if (!this.checked) forgetMe(document.comments_form)" value="1" />Remember personal info?</label></p>
					<p id="CommenterMessage"><label for="comment-text">Write your Message:</label><textarea id="comment-text" name="text" rows="10" cols="30"></textarea></p>
					<div id="CommentsSubmit"><input type="submit" accesskey="s" name="post" id="comment-post" value=" Post Comment " /></div>
				</form>
				</MTEntryIfCommentsOpen>
			</div>
			</MTIfCommentsActive>
	
		</div> <!-- End DocuemntContent -->
	
		<?php include($_SERVER['DOCUMENT_ROOT'].'/ecc/ssi/docfooter.php'); ?>
	
	</div>
	</div>
	
</div>


<?php include($_SERVER['DOCUMENT_ROOT'].'/ecc/ssi/uix.php'); ?>
</body>
</html>