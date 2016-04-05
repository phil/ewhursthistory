<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
   <meta http-equiv="Content-Type" content="text/html; charset=<$MTPublishCharset$>" />
   
   <link rel="stylesheet" href="<$MTBlogURL$>styles-site.css" type="text/css" />
   <link rel="alternate" type="application/atom+xml" title="Atom" href="<$MTBlogURL$>atom.xml" />
   <link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="<$MTBlogURL$>index.xml" />
   
   <title><$MTBlogName encode_html="1"$></title>
   
   <link rel="EditURI" type="application/rsd+xml" title="RSD" href="<$MTBlogURL$>rsd.xml" />
   
   <link rel="stylesheet" type="text/css" href="/desktops/css/screen.css" media="screen" />
   
   <MTBlogIfCCLicense>
   <$MTCCLicenseRDF$>
   </MTBlogIfCCLicense>
</head>


<body>
<div id="desktops-header">
<? include($_SERVER['DOCUMENT_ROOT']."/ssi/navigation.php"); ?>
<h1><span>Desktops</span></h1>
</div>

<div id="desktops-navigation">
<h2>Categories</h2>
<ul>
<MTCategories>
<li><a href="<$MTCategoryArchiveLink$>"><span class="cat-label"><$MTCategoryLabel$></span> <span class="cat-count">[<$MTCategoryCount$>]</span></a></li>
</MTCategories>
<li class="clear"></li>
</ul>
</div>

<div id="desktops-content">
<h2>Recently Added Desktops</h2>	
<p>Free desktops for all to download, just click the link below that best fits your screen. I will be creating and releasing new desktops every month for your pixel pleasure.</p>
	<ul class="desktop-list">
	
	<MTEntries n="30">
        <li>
        	<$MTEntryTrackbackData$>
        	<$MTInclude module="Desktop Object"$>
		<div id="desktop-footer"></div>
        </li>
	</MTEntries>

	<ul>

</div>
                  
<?php include($_SERVER['DOCUMENT_ROOT']."/ssi/footer.php"); ?>

</body>
</html>
