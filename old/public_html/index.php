<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<?php 

$HeadTitle = "Welome";
$HeadDescription = "";
$HeadKeywords = "";

include($_SERVER['DOCUMENT_ROOT'] . '/ssi/htmlhead.php');

?>

<body>
<div id="Page">
<div id="PageHeader"></div>
<div id="Welcome"><h1>Welcome to Ewhurst&nbsp;History&nbsp;Society</h1></div>
<div id="SocietyStatement"><p>The Society meets on the 3rd Tuesday of the month at the Baptist Church, The Street, Ewhurst. We have a programme of talks from September - May, with additional social events and visits in June &amp; July. In addition a small group meets on an informal basis to further research into local history. Our latest project, 'Ewhurst Houses and People', has recently been published and is available to order from the <a href="publications/" >publications page</a>. We have also published two other books on local history and have organised several Local History Exhibitions.</p></div>

<div class="specialevent">
  <h2>Now Available - St Peter and St Paul: A Guide and History</h2>
  <div class="ImageFrame">
      <a href="publications/ewhurst_church/index.php"><img src="publications/ewhurst_church/cover.jpg" class="ImageStd" alt="St Peter and St Paul Cover" /></a>
    </div>
  <p>Ewhurst History Society latest publication is a new guide book for the Parish Church, written by Janet Balchin. The book is in the same A4 landscape format as previous Ewhurst History Society publications and has 84 pages (including 4 in full colour) and over 100 illustrations, including many not previously published. It is priced at £12.50 and after expenses have been covered, profits will be shared between the church and the History Society. </p>
</div>

<!--
<div class="specialevent">
	<p><strong>STOP PRESS - Please note that with effect from January 2011, meetings of the Ewhurst History Society will be held in the Baptist Church, The Street, Ewhurst.  Meetings will no longer be held in the Glebe Centre.</strong></p>
</div>

<div class="specialevent">
	<h2>Now Available - Ewhurst Houses and People</h2>
	<div class="ImageFrame">
			<a href="publications/ewhursthouses.php"><img src="publications/marylands.jpg" class="ImageStd" alt="Ewhurst Houses and People. Front Cover" /></a>
		</div>
	<p>Our Latest book <em>Ewhurst Houses and People</em> is now available. The Book is priced at &pound;12.50 (plus p&amp;p). Further information is available on the <a href="publications/index.php">Publications</a> page.</p>
</div>

-->

<div id="SiteExplorer" class="Launcher"><?php include("ssi/siteexplorer.php") ?></div>
<div id="PageFooter"><?php include("ssi/pagefooter.php") ?></div>
</div>
</body>
</html>
