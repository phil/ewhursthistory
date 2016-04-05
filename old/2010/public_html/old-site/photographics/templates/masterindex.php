<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
   <meta http-equiv="Content-Type" content="text/html; charset=<$MTPublishCharset$>" />
   
   
   <? include($_SERVER['DOCUMENT_ROOT']."/photographics/ssi/stylesheets.php") ?>
   
   <title>Photographics</title>
   
   <link rel="EditURI" type="application/rsd+xml" title="RSD" href="<$MTBlogURL$>rsd.xml" />
   
</head>
<body id="body-photos-dark">
	<div id="wrapper">
	
		<div id="banner"><img src="img/banner1.jpg" alt="Photographics Portfolio" /></div>

		<div id="recent-photos">
			<h1><span>Recently Added</span></h1>
			<ul>
			<MTEntries lastn="3">
				<li><a href="<$MTEntryPermalink$>"><img src="<$MTBlogURL$>photos/<$MTEntryExcerpt$>-260.jpg" alt="<$MTEntryTitle encode_html="1" $>" class="photo-mid" /></a></li>
			</MTEntries>
			</ul>
		</div>

		<div id="galleries">
			<h1><span>Galleries</span></h1>
			<ul id="gallery-list">
			<MTTopLevelCategories>
				<MTIfNonZero tag="MTCategoryCount">
				<li><a href="<$MTCategoryArchiveLink$>" title="<$MTCategoryDescription encode_html="1"$>"><$MTCategoryLabel smarty_pants="1" encode_html="1"$></a></li>
<MTElse>
<li><span class="inactive"><$MTCategoryLabel smarty_pants="1" encode_html="1"$> [Comming Soon]</span></li>
</MTElse>
				</MTIfNonZero>
			</MTTopLevelCategories>
			</ul></div>

		<div id="about">
			<h1><span>About the Photographs</span></h1>
			<p>Photographics is the area of my portfolio where I show case the very best of my photographs. All the photographs are arranged into galleries with a common theme, and every photograph also has a complete description, as well as some technical details about when, how, and why i took each shot.</p>

			<p>For a the complete archive of my public photos, <a href="http://www.flickr.com/photos/whatisnext">check my flickr.com pages</a></p>
		</div>

		<? include($_SERVER['DOCUMENT_ROOT']."/ssi/navigation.php") ?>

		<? include($_SERVER['DOCUMENT_ROOT']."/photographics/ssi/footer.php") ?>
	
	</div>
</body>
</html>
