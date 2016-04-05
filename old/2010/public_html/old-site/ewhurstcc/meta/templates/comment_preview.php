<?php

$HeadTitle = "<$MTBlogName encode_html="1"$>: Comment on <$MTEntryTitle$>";
$HeadDescription = "";
$HeadKeywords = "";

$HeadLinks = array(
	'<link rel="start" href="<$MTBlogURL$>" title="Home" />',
	'<link rel="alternate" type="application/atom+xml" title="Atom" href="<$MTBlogURL$>atom.xml" />',
	'<link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="<$MTBlogURL$>index.xml" />',
	'<link rel="EditURI" type="application/rsd+xml" title="RSD" href="<$MTBlogURL$>rsd.xml" />');


	include($_SERVER['DOCUMENT_ROOT'].'/ecc/ssi/htmlhead.php');
?>
<body id="BodyBlog">
<div id="Wrapper" class="Relative">
	
	<?php include($_SERVER['DOCUMENT_ROOT'].'/ecc/ssi/masthead.php'); ?>
	
	<?php include($_SERVER['DOCUMENT_ROOT'].'/ecc/ssi/eccexplorer.php'); ?>
	
	<div id="DocumentWrapper">
	<div id="Document">
	
		<div id="DocumentContent">
			<h1>Previewing your Comment</h1>

			<ul id="PostedComments">
				<li class="comment">
					<$MTCommentPreviewBody$>
					<p>Posted <$MTCommentPreviewDate$> by <$MTCommentPreviewAuthorLink default_name="Anonymous"$></p>
				</li>
			</ul>

			<MTEntryIfCommentsOpen> 
			<form method="post" action="<$MTCGIPath$><$MTCommentScript$>" name="CommentsForm" id="CommentsForm" onsubmit="if (this.bakecookie.checked) rememberMe(this)">	
				<input type="hidden" name="static" value="1" />
				<input type="hidden" name="entry_id" value="<$MTEntryID$>" />
	
				<h2>Post a comment</h2>
	
	         <MTIfCommentsModerated>
	         <p class="CommentsModerated">If you haven't left a comment here before, you gonn need to be approved by E.C.C before your comment will appear. Until then, it won't appear on the entry. Thanks for waiting. This is only really here to stop <a href="www.bernardbrace.co.uk">Bernard Brace</a> from abusing the commenting system.</p>
	         </MTIfCommentsModerated>
	
				<p id="CommenterName"><label for="comment-author">Name:</label><input id="comment-author" name="author" size="30" value="<$MTCommentPreviewAuthor$>" /></p>
				<p id="CommenterEmail"><label for="comment-email">Email Address:</label><input id="comment-email" name="email" size="30" value="<$MTCommentPreviewEmail$>" /></p>
				<p id="CommenterUrl"><label for="comment-url">URL:</label><input id="comment-url" name="url" size="30" value="<$MTCommentPreviewURL$>" /></p>
				<p id="CommenterCookie"><label for="comment-bake-cookie"><input type="checkbox" id="comment-bake-cookie" name="bakecookie" onclick="if (!this.checked) forgetMe(document.comments_form)" value="1" />Remember personal info?</label></p>
				<p id="CommenterMessage"><label for="comment-text">Write your Message:</label><textarea id="comment-text" name="text" rows="10" cols="30"><$MTCommentPreviewBody autolink="0" sanitize="0" convert_breaks="0"$></textarea></p>
				<div id="CommentsSubmit">
					<input type="submit" accesskey="v" name="preview" id="comment-preview" value="Preview" />
					<input type="submit" accesskey="s" name="post" id="comment-post" value="Post" />
					<input type="button" name="cancel" id="comment-cancel" value="Cancel" onclick="window.location='<$MTEntryPermalink$>'" />
				</div>
			</form>
			</MTEntryIfCommentsOpen>
			
		</div> <!-- End DocuemntContent -->
	
		<?php include($_SERVER['DOCUMENT_ROOT'].'/ecc/ssi/docfooter.php'); ?>
	
	</div>
	</div>
	
</div>


<?php include($_SERVER['DOCUMENT_ROOT'].'/ecc/ssi/uix.php'); ?>
</body>
</html>