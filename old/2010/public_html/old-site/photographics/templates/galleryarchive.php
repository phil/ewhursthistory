<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
   <meta http-equiv="Content-Type" content="text/html; charset=<$MTPublishCharset$>" />
   
   <? include($_SERVER['DOCUMENT_ROOT']."/photographics/ssi/stylesheets.php") ?>
   <link rel="alternate" type="application/atom+xml" title="Atom" href="<$MTBlogURL$>atom.xml" />
   <link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="<$MTBlogURL$>index.xml" />
   
   <title>Photographics - <$MTArchiveTitle smarty_pants="1" encode_html="1" $></title>
   
   <link rel="EditURI" type="application/rsd+xml" title="RSD" href="<$MTBlogURL$>rsd.xml" />

</head>
<body id="body-photos-dark">
	<div id="wrapper">

		<div class="gallery-nav">
			<p><a href="<$MTBlogURL$>">&laquo; Return to Contents</a></p>
		</div>

		<h1><$MTArchiveTitle smarty_pants="1"$></h1>

		<div class="gallery">
			<ul>
				<MTEntries>
				<li><a href="<$MTEntryPermalink$>"><img src="<$MTBlogURL$>photos/<$MTEntryExcerpt$>-260.jpg" alt="<$MTEntryTitle smarty_pants="1" encode_html="1" $>" /></a></li>
				</MTEntries>
				<li class="clear"></li>
			</ul>
	
		</div>

		<div class="gallery-nav">
			<p class="gallery-nav-index"><a href="<$MTBlogURL$>">&laquo;  Return to Contents</a>
		</div>
	
		<? include($_SERVER['DOCUMENT_ROOT']."/photographics/ssi/footer.php") ?>

	</div>
</body>
</html>
