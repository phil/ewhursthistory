<?php

$HeadTitle = "Journal Archive";
$HeadDescritpion = "";
$headKeywords = "";

$HeadLinks = array(
	'<link rel="alternate" type="application/atom+xml" title="Atom" href="<$MTBlogURL$>syndicate/atom.xml" />',
	'<link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="<$MTBlogURL$>syndicate/rss.xml" />',
	'<link rel="EditURI" type="application/rsd+xml" title="RSD" href="<$MTBlogURL$>rsd.xml" />');

include($_SERVER['DOCUMENT_ROOT']."/ssi/htmlhead.php");
?>
<!-- 
   
   <MTBlogIfCCLicense>
   <$MTCCLicenseRDF$>
   </MTBlogIfCCLicense>
-->

<body id="body-journal">
<? include($_SERVER['DOCUMENT_ROOT']."/ssi/skiptocontent.php") ?>
<? include($_SERVER['DOCUMENT_ROOT']."/ssi/masthead.php") ?>
<? include($_SERVER['DOCUMENT_ROOT']."/ssi/navigation.php") ?>

<div id="Journal-archive-wrapper" class="section-wrapper">
	<div id="content" class="section">
	
	<div id="journal-archive">
		<ul>
			<MTArchiveList>
			<li><span class="archive-date"><$MTArchiveDate format="%a %e %B"$></span><a href="<$MTArchiveLink$>" class="archive-link"><$MTArchiveTitle$></a></li>
			</MTArchiveList>
		</ul>
		
		
	</div>
				
				
	<div id="journal-categories-list">
		<h3>Categories</h3>
		<MTTopLevelCategories>
		<MTSubCatIsFirst><ul></MTSubCatIsFirst>
			<MTIfNonZero tag="MTCategoryCount">
			<li><a href="<$MTCategoryArchiveLink$>" title="<$MTCategoryDescription$>"><MTCategoryLabel> <span class="journal-category-count">[<MTCategoryCount>]</span></a></li>
			</MTIfNonZero>
			<MTSubCatsRecurse>
		<MTSubCatIsLast></ul></MTSubCatIsLast>
		</MTTopLevelCategories>
	</div>


	<div class="section-end"></div>
        
</div>
<div>

<? include($_SERVER['DOCUMENT_ROOT']."/ssi/footer.php") ?>
		
</body>
</html>