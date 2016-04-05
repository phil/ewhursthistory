<?php

$HeadTitle = "Ewhurst Cricket Club: Second Entry";
$HeadDescription = "";
$HeadKeywords = "";

$HeadLinks = array(
	'<link rel="start" href="http://www.whatisnext.co.uk/ecc/" title="Home" />',
	'<link rel="alternate" type="application/atom+xml" title="Atom" href="http://www.whatisnext.co.uk/ecc/atom.xml" />',
	'<link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="http://www.whatisnext.co.uk/ecc/index.xml" />',
	'<link rel="EditURI" type="application/rsd+xml" title="RSD" href="http://www.whatisnext.co.uk/ecc/rsd.xml" />',
	'<script src="/js/scripts.js" type="text/javascript"></script>',
	'<link rel="prev" href="http://www.whatisnext.co.uk/ecc/2005/12/first_entry.php" title="First Entry" />',
	'<link rel="next" href="http://www.whatisnext.co.uk/ecc/2006/01/beta_mode.php" title="Beta Mode" />');


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
				<a href="http://www.whatisnext.co.uk/ecc/2005/12/first_entry.php">&laquo; First Entry</a> | 
				<a href="http://www.whatisnext.co.uk/ecc/">Main</a>
				 | <a href="http://www.whatisnext.co.uk/ecc/2006/01/beta_mode.php">Beta Mode &raquo;</a>
			</p>

			<!--
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:trackback="http://madskills.com/public/xml/rss/module/trackback/"
         xmlns:dc="http://purl.org/dc/elements/1.1/">
<rdf:Description
    rdf:about="http://www.whatisnext.co.uk/ecc/2005/12/second_entry.php"
    trackback:ping="http://www.whatisnext.co.uk/cgi-bin/mt/mt-tb.cgi/241"
    dc:title="Second Entry"
    dc:identifier="http://www.whatisnext.co.uk/ecc/2005/12/second_entry.php"
    dc:subject="Committee Updates"
    dc:description="And the all important excert"
    dc:creator="Melody"
    dc:date="2005-12-20T00:09:37+00:00" />
</rdf:RDF>
-->

			
			<h1><a href="http://www.whatisnext.co.uk/ecc/2005/12/second_entry.php">Second Entry</a></h1>
			<h2>December 20, 2005</h2>
			<div class="EntryContent">
				<div class="EntryBody">
					<p>Entry Body</p>
				</div>
				<div id="more" class="EntryMore">
					<p>Extended stuff</p>
				</div>
			</div>

						<div id="comments">
		
				<h2>Comments</h2>
		
				<ul id="PostedComments">
										<li id="c000007" class="comment">
						<p>Beta Testiung Only</p>
						<p class="CommentInfo">Posted <a href="#comment-7">January  8, 2006 11:40 PM</a> by <a href="http://www.whatisnext.co.uk" rel="nofollow">Phil Balchin</a> </p>
					</li>
					
				</ul>
		
				 
				<form method="post" action="http://www.whatisnext.co.uk/cgi-bin/mt/mt-comments.cgi" name="CommentsForm" id="CommentsForm" onsubmit="if (this.bakecookie.checked) rememberMe(this)">	
					<input type="hidden" name="static" value="1" />
					<input type="hidden" name="entry_id" value="241" />
		
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