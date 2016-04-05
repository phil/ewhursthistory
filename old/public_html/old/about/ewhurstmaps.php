<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<?php 

$HeadTitle = "Maps of Ewhurst";
$HeadDescription = "";
$HeadKeywords = "";

include($_SERVER['DOCUMENT_ROOT'] . '/ssi/htmlhead.php');

?>

<body>
<div id="Page">
<div id="PageHeader"></div>
<div id="PageContent">
	<div id="ContentHeader"><h1>Maps of Ewhurst</h1>
		
	</div>
	<div id="ContentBody">
		<div class="ImageFrame">
			<img src="ewhurstmap.jpg" alt="A map of Ewhurst in relation to Guildford" />
		</div>
		<p>Ewhurst is a village about 35 miles south west of London on the Surrey Sussex border. 
		Close by is the larger village of Cranleigh and the nearest towns of Guildford, Dorking and 
		Horsham, are each about 10 miles away.</p>
		<div class="ImageFrame">
			<img src="ewhurstmapdetailed.jpg" alt="A detailed map of Ewhurst and Ellens Green" />
		</div>	
	</div>
	<div id="ContentFooter"><?php include($_SERVER['DOCUMENT_ROOT'] . '/ssi/contentfooter.php') ?></div>
</div>
<div id="SiteExplorer"><?php include($_SERVER['DOCUMENT_ROOT'] . '/ssi/siteexplorer.php') ?></div>

<div id="RelatedDocuments">
	<ul>
		<li><a href="ewhurst.php">About Ewhurst &raquo;</a></li>
		<li><a href="ewhurstbriefhistory.php">A Brief History of Ewhurst &raquo;</a></li>
	</ul>
</div>

<div id="PageFooter"><?php include($_SERVER['DOCUMENT_ROOT'] . '/ssi/pagefooter.php') ?></div>
</div>
</body>
</html>
