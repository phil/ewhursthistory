<?php

include ($_SERVER['DOCUMENT_ROOT']."/ecc/photos//galleryinfo.php");
  $blogrelurl = "/ecc/photos/";
  $blogurl = "http://www.whatisnext.co.uk/ecc/photos/";
  $section = "photosolo";
  $pgtitle = "PIC00084";
  $entryid = 476;
  $img = '<img alt="PIC00084" src="http://www.whatisnext.co.uk/ecc/photos/assets/2004-08-13-03-56-22.jpg" width="640" height="480" />';

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
		
			<p id="GalleryPath"><a href="<?= $blogrelurl ?>">E.C.C Tours of Duty</a> > <a href="<?= $galleryurl ?>"><?= $gallerytitle ?></a> > <a href="<?= $galleryurl ?>gallery/">Gallery</a> > PIC00084</p>  
			
			<div id="Photo"><img alt="PIC00084" src="http://www.whatisnext.co.uk/ecc/photos/assets/2004-08-13-03-56-22.jpg" width="640" height="480" /></div>
			
			<div id="PhotoInfo">
				<h1>E.C.C Tours of Duty</h1>
				<p><em>No description</em></p>
			</div>
			<div id="PhotoMeta">
				<ul>
					<li class="count">Photo # of #</li>
					<li class="date">13 August 2004</li>
					
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