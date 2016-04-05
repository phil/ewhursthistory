<?php

$HeadTitle = "Work : <$MTEntryTitle$>";
$HeadDescritpion = "";
$headKeywords = "";

$HeadLinks = array(
	'<link rel="alternate" type="application/atom+xml" title="Atom" href="<$MTBlogURL$>atom.xml" />',
	'<link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="<$MTBlogURL$>index.xml" />',
	'<link rel="EditURI" type="application/rsd+xml" title="RSD" href="<$MTBlogURL$>rsd.xml" />');

include($_SERVER['DOCUMENT_ROOT']."/ssi/htmlhead.php");
?>

<body id="body-work">
<? include($_SERVER['DOCUMENT_ROOT']."/ssi/skiptocontent.php") ?>
<? include($_SERVER['DOCUMENT_ROOT']."/ssi/masthead.php") ?>
<? include($_SERVER['DOCUMENT_ROOT']."/ssi/navigation.php") ?>

<div id="work-wrapper" class="section-wrapper">
	<div id="content" class="section">
    
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

<? include($_SERVER['DOCUMENT_ROOT']."/ssi/footer.php") ?>

</body>
</html>