<?php

include ($_SERVER['DOCUMENT_ROOT']."/ecc/photos//galleryinfo.php");
  $blogrelurl = "/ecc/photos/";
  $blogurl = "http://www.whatisnext.co.uk/ecc/photos/";
  $section = "photosolo";
  $pgtitle = "A &quot;Just&quot; Mental";
  $entryid = 412;
  $img = '<img alt="A &amp;quot;Just&amp;quot; Mental" src="http://www.whatisnext.co.uk/ecc/photos/assets/2003-09-27-20-01-04.jpg" width="480" height="640" />';

$HeadTitle = "E.C.C Tours of Duty";
$HeadDescription = "";
$HeadKeywords = "";

$HeadLinks = array(
	'<link rel="start" href="http://www.whatisnext.co.uk/ecc/photos/" title="Home" />',
	'<link rel="alternate" type="application/atom+xml" title="Atom" href="http://www.whatisnext.co.uk/ecc/photos/atom.xml" />',
	'<link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="http://www.whatisnext.co.uk/ecc/photos/index.xml" />',
	'<link rel="EditURI" type="application/rsd+xml" title="RSD" href="http://www.whatisnext.co.uk/ecc/photos/rsd.xml" />',
	'<script src="/js/scripts.js" type="text/javascript"></script>');


	include($_SERVER['DOCUMENT_ROOT'].'/ecc/ssi/htmlhead.php');
?>
<body id="BodyPhotos">
<div id="Wrapper" class="Relative">
	
	<?php include($_SERVER['DOCUMENT_ROOT'].'/ecc/ssi/masthead.php'); ?>
	
	<?php include($_SERVER['DOCUMENT_ROOT'].'/ecc/ssi/eccexplorer.php'); ?>
	
	<div id="DocumentWrapper">
	<div id="Document">
	
		<div id="DocumentContent">
		
			<p id="GalleryPath"><a href="<?= $blogrelurl ?>">E.C.C Tours of Duty</a> > <a href="<?= $galleryurl ?>"><?= $gallerytitle ?></a> > <a href="<?= $galleryurl ?>gallery/">Gallery</a> > A &quot;Just&quot; Mental</p>  
			
			<div id="Photo"><img alt="A &amp;quot;Just&amp;quot; Mental" src="http://www.whatisnext.co.uk/ecc/photos/assets/2003-09-27-20-01-04.jpg" width="480" height="640" /></div>
			
			<div id="PhotoInfo">
				<h1>E.C.C Tours of Duty</h1>
				<p><em>No description</em></p>
			</div>
			<div id="PhotoMeta">
				<ul>
					<li class="count">Photo # of #</li>
					<li class="date">27 September 2003</li>
					
				</ul>
			</div>
			
			<div id="GalleryNav">
			

			
			</div>
			
	
		</div> <!-- End DocuemntContent -->
	
		<?php include($_SERVER['DOCUMENT_ROOT'].'/ecc/ssi/docfooter.php'); ?>
	
	</div>
	</div>
	
</div>


<?php include($_SERVER['DOCUMENT_ROOT'].'/ecc/ssi/uix.php'); ?>
</body>
</html>