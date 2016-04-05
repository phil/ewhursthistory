<?php

$HeadTitle = "Ewhurst Cricket Club";
$HeadDescription = "";
$HeadKeywords = "";

$HeadLinks = array(
	'<link rel="alternate" type="application/atom+xml" title="Atom" href="http://www.whatisnext.co.uk/ecc/atom.xml" />',
	'<link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="http://www.whatisnext.co.uk/ecc/index.xml" />',
	'<link rel="EditURI" type="application/rsd+xml" title="RSD" href="http://www.whatisnext.co.uk/ecc/rsd.xml" />');


	include($_SERVER['DOCUMENT_ROOT']."/ecc/ssi/htmlhead.php");
?>

<body id="body-home">
<div id="wrapper" class="relative">
	
	<?php include($_SERVER['DOCUMENT_ROOT']."/ecc/ssi/masthead.php"); ?>
	
	<?php include($_SERVER['DOCUMENT_ROOT']."/ecc/ssi/navigation.php"); ?>
	
	<div id="document-wrapper">
	<div id="document">
	
	<?php include($_SERVER['DOCUMENT_ROOT']."/ecc/ssi/feature.php"); ?>
	
		<div id="document-content">
			<p id="welcome-introduction">Welcome to the (un)offical Ewhurt Cricket Club website. Here you will find all the latest and greatest news updates as well as keep track of our cricketing season, on and off the playing field.</p>

			<?php include($_SERVER['DOCUMENT_ROOT']."/ecc/ssi/siteupdates.php"); ?>

			<?php include($_SERVER['DOCUMENT_ROOT']."/ecc/blog-archivefull-top5.php"); ?>
			 
	
		</div> <!-- End DocuemntContent -->
		
		<?php include($_SERVER['DOCUMENT_ROOT']."/ecc/blog-categories.php"); ?>

		
		
	
		<?php include($_SERVER['DOCUMENT_ROOT']."/ecc/ssi/footer.php"); ?>
	
	</div>
	</div>
	
</div>

<?php include($_SERVER['DOCUMENT_ROOT']."/ecc/ssi/uix.php"); ?>
</body>
</html>