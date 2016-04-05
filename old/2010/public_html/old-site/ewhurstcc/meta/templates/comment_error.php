<?php

$HeadTitle = "<$MTBlogName encode_html="1"$>: Comment Submission Error";
$HeadDescription = "";
$HeadKeywords = "";

$HeadLinks = array(
	'<link rel="start" href="<$MTBlogURL$>" title="Home" />',
	'<link rel="alternate" type="application/atom+xml" title="Atom" href="<$MTBlogURL$>atom.xml" />',
	'<link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="<$MTBlogURL$>index.xml" />',
	'<link rel="EditURI" type="application/rsd+xml" title="RSD" href="<$MTBlogURL$>rsd.xml" />',
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
			<h1>Comment Submission Error</h1>
			<p>Your comment submission failed for the following reasons:</p>
			<blockquote><strong><$MTErrorMessage$></strong></blockquote>
		</div> <!-- End DocuemntContent -->
	
		<?php include($_SERVER['DOCUMENT_ROOT'].'/ecc/ssi/docfooter.php'); ?>
	
	</div>
	</div>
	
</div>


<?php include($_SERVER['DOCUMENT_ROOT'].'/ecc/ssi/uix.php'); ?>
</body>
</html>