<?php

$HeadTitle = "Ewhurst Cricket Club: First Entry";
$HeadDescription = "";
$HeadKeywords = "";

$HeadLinks = array(
	'<link rel="start" href="http://www.whatisnext.co.uk/ecc/" title="Home" />',
	'<link rel="alternate" type="application/atom+xml" title="Atom" href="http://www.whatisnext.co.uk/ecc/atom.xml" />',
	'<link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="http://www.whatisnext.co.uk/ecc/index.xml" />',
	'<link rel="EditURI" type="application/rsd+xml" title="RSD" href="http://www.whatisnext.co.uk/ecc/rsd.xml" />',
	'<script src="/js/scripts.js" type="text/javascript"></script>',
	'',
	'<link rel="next" href="http://www.whatisnext.co.uk/ecc/2005/12/second_entry.php" title="Second Entry" />');


	include($_SERVER['DOCUMENT_ROOT'].'/ecc/ssi/htmlhead.php');
?>
<body id="BodyBlog">
<div id="Wrapper" class="Relative">
	
	<?php include($_SERVER['DOCUMENT_ROOT'].'/ecc/ssi/masthead.php'); ?>
	
	<?php include($_SERVER['DOCUMENT_ROOT'].'/ecc/ssi/eccexplorer.php'); ?>
	
	<div id="DocumentWrapper">
	<div id="Document">
	
		<div id="DocumentContent">
			<p class="EntryNav">
				
				<a href="http://www.whatisnext.co.uk/ecc/">Main</a>
				 | <a href="http://www.whatisnext.co.uk/ecc/2005/12/second_entry.php">Second Entry &raquo;</a>
			</p>

			<!--
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:trackback="http://madskills.com/public/xml/rss/module/trackback/"
         xmlns:dc="http://purl.org/dc/elements/1.1/">
<rdf:Description
    rdf:about="http://www.whatisnext.co.uk/ecc/2005/12/first_entry.php"
    trackback:ping="http://www.whatisnext.co.uk/cgi-bin/mt/mt-tb.cgi/240"
    dc:title="First Entry"
    dc:identifier="http://www.whatisnext.co.uk/ecc/2005/12/first_entry.php"
    dc:subject=""
    dc:description="Excerpt"
    dc:creator="Melody"
    dc:date="2005-12-03T17:24:27+00:00" />
</rdf:RDF>
-->

			
			<h1><a href="http://www.whatisnext.co.uk/ecc/2005/12/first_entry.php">First Entry</a></h1>
			<h2>December 03, 2005</h2>
			<div class="EntryContent">
				<div class="EntryBody">
					<p>Body Text</p>
				</div>
				<div id="more" class="EntryMore">
					<p>Extended Entry Area</p>
				</div>
			</div>

						<div id="comments">
		
				<h2>Comments</h2>
		
				<ul id="PostedComments">
					
				</ul>
		
				 
				<form method="post" action="http://www.whatisnext.co.uk/cgi-bin/mt/mt-comments.cgi" name="CommentsForm" id="CommentsForm" onsubmit="if (this.bakecookie.checked) rememberMe(this)">	
					<input type="hidden" name="static" value="1" />
					<input type="hidden" name="entry_id" value="240" />
		
					<h2>Post a comment</h2>
		
		         
		
					<p id="CommenterName"><label for="comment-author">Name:</label><input id="comment-author" name="author" size="30" /></p>
					<p id="CommenterEmail"><label for="comment-email">Email Address:</label><input id="comment-email" name="email" size="30" /></p>
					<p id="CommenterUrl"><label for="comment-url">URL:</label><input id="comment-url" name="url" size="30" /></p>
					<p id="CommenterCookie"><label for="comment-bake-cookie"><input type="checkbox" id="comment-bake-cookie" name="bakecookie" onclick="if (!this.checked) forgetMe(document.comments_form)" value="1" />Remember personal info?</label></p>
					<p id="CommenterMessage"><label for="comment-text">Write your Message:</label><textarea id="comment-text" name="text" rows="10" cols="30"></textarea></p>
					<div id="CommentsSubmit"><input type="submit" accesskey="s" name="post" id="comment-post" value=" Post Comment " /></div>
				</form>
				
			</div>
			
	
		</div> <!-- End DocuemntContent -->
	
		<?php include($_SERVER['DOCUMENT_ROOT'].'/ecc/ssi/docfooter.php'); ?>
	
	</div>
	</div>
	
</div>


<?php include($_SERVER['DOCUMENT_ROOT'].'/ecc/ssi/uix.php'); ?>
</body>
</html>