<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en" xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
	<title>whatisnext.co.uk &raquo; Journal</title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<meta name="description" content="whatisnext.co.uk is a small development company from Surrey. On his site, you'll find my Journal, some Desktops, other freebees and my Portfolio" />
	<meta name="keywords" content="whatisnext, What Is Next, Next Century Systems, Next, XHTML, HTML, XML, CSS" />

	<meta name="author" content="Phil Balchin" />
	<meta name="Copyright" content="Copyright (c) 2005 Next Century Systems" />

	<link rel="shortcut icon" href="/favicon.ico" />

<link rel="alternate" type="application/atom+xml" title="Atom" href="<$MTBlogURL$>syndicate/atom.xml" />
<link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="<$MTBlogURL$>syndicate/rss.xml" />
<link rel="EditURI" type="application/rsd+xml" title="RSD" href="<$MTBlogURL$>rsd.xml" />

<link rel="stylesheet" href="<$MTBlogURL$>css/screen.css" type="text/css" media="screen" />
<link rel="stylesheet" href="<$MTBlogURL$>css/print.css" type="text/css" media="print" />

<script src="/js/scripts.js" type="text/javascript"></script>
<script src="/js/jquery/jquery.js" type="text/javascript"></script>
<script src="/mint/?js" type="text/javascript"></script>

<!-- CCLicense
   <MTBlogIfCCLicense>
   <$MTCCLicenseRDF$>
   </MTBlogIfCCLicense>
-->
	
</head>

<body id="body-journal">
<? include($_SERVER['DOCUMENT_ROOT']."/ssi/skiptocontent.php") ?>
<? include($_SERVER['DOCUMENT_ROOT']."/ssi/masthead.php") ?>
<? include($_SERVER['DOCUMENT_ROOT']."/ssi/navigation.php") ?>

<div id="wrapper">
 
		<MTEntries lastn="1">
		<div id="latest-entry" class="journal-entry">
			<$MTEntryTrackbackData$>
			<h1 id="a<$MTEntryID pad="1"$>" class="entry-header">Latest: <a href="<$MTEntryPermalink$>"><$MTEntryTitle smarty_pants="1"$></a></h1>
			<p class="date"><$MTEntryDate format="%x"$></p>
					
			<div class="entry-content">
				<$MTEntryBody  smarty_pants="1"$>
			</div>
		</div>
		</MTEntries>
				
				
    
		<div id="recent-entries">
			<h1>Recently</h1>
			<ul>
				<MTEntries lastn="10" offset="1">
				<li><a href="<$MTEntryPermalink$>" class="journal-archive-entry-link"><span class="entry-date"><$MTEntryDate format="%e %b"$></span> <span class="entry-title"><$MTEntryTitle  smarty_pants="1"$></span></a></li>
				</MTEntries>
			</ul>
			<p class="more-information"><a href="syndicate/rss.xml">RSS 2.0</a> | <a href="syndicate/atom.xml">Atom</a> | <a href="achive.php">Previous Entries</a></p>
		</div>

		<div id="journal-archive">
			<h1>Categories</h1>
			<ul id="category-list">
			<MTTopLevelCategories>
				<MTIfNonZero tag="MTCategoryCount">
				<li><a href="<$MTCategoryArchiveLink$>" title="<$MTCategoryDescription$>"><span class="archive-title"><MTCategoryLabel smarty_pants="1"></span> <span class="archive-count"><$MTCategoryCount$></span></a></li>
				</MTIfNonZero>
			</MTTopLevelCategories>
			</ul>

			<h1>Archives</h1>
			<MTArchiveList archive_type="Monthly">
        	<MTArchiveListHeader><ul class="date-list"></MTArchiveListHeader>
        	<li><a href="<$MTArchiveLink$>"><span class="archive-title"><$MTArchiveTitle$></span> <span class="archive-count"><$MTArchiveCount$></span></a></li>
	        <MTArchiveListFooter></ul></MTArchiveListFooter>
	     </MTArchiveList>


			<p class="more-information"></p>
		</div>


		<div id="laf-links">
			<h1>Lost and Found</h1>
			<?php include($_SERVER['DOCUMENT_ROOT']."/lostandfound/index-top15.php") ?>
			<p class="more-information"><a href="lostandfound/syndicate/rss.xml">RSS 2.0</a> | <a href="lostandfound/syndicate/atom.xml">Atom</a> | <a href="lostandfound/index.php">Previous Found Things</a></p>
		</div>

		<? include($_SERVER['DOCUMENT_ROOT']."/ssi/footer.php") ?>
        
</div>


</body>
</html>