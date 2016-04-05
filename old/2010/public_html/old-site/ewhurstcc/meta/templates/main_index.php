<?php

$HeadTitle = "<$MTBlogName encode_html="1"$>";
$HeadDescription = "";
$HeadKeywords = "";

$HeadLinks = array(
	'<link rel="alternate" type="application/atom+xml" title="Atom" href="<$MTBlogURL$>atom.xml" />',
	'<link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="<$MTBlogURL$>index.xml" />',
	'<link rel="EditURI" type="application/rsd+xml" title="RSD" href="<$MTBlogURL$>rsd.xml" />');


	include($_SERVER['DOCUMENT_ROOT']."/ecc/ssi/htmlhead.php");
?>

<body id="BodyHome">
<div id="Wrapper" class="Relative">
	
	<?php include($_SERVER['DOCUMENT_ROOT']."/ecc/ssi/masthead.php"); ?>
	
	<?php include($_SERVER['DOCUMENT_ROOT']."/ecc/ssi/eccexplorer.php"); ?>
	
	<div id="DocumentWrapper">
	<div id="Document">
	
	<?php include($_SERVER['DOCUMENT_ROOT']."/ecc/ssi/feature.php"); ?>
	
		<div id="DocumentContent">
			<p id="WelcomeIntroduction">Welcome to the (un)offical Ewhurt Cricket Club website. Here you will find all the latest and greatest news updates as well as keep track of our cricketing season, on and off the playing field.</p>

			<?php include($_SERVER['DOCUMENT_ROOT']."/ecc/ssi/siteupdates.php"); ?>

			<MTEntries>
			<$MTEntryTrackbackData$>
			
			<div class="Entry" id="entry-<$MTEntryID$>">
				<h1><MTEntryIfExtended><a href="<$MTEntryPermalink$>"><$MTEntryTitle$></a><MTElse><$MTEntryTitle$></MTElse></MTEntryIfExtended></h1>
				<h2><MTDateHeader><$MTEntryDate format="%x"$></MTDateHeader><MTIfCommentsActive> | <a href="<$MTEntryPermalink$>#comments">Comments (<$MTEntryCommentCount$>)</a></MTIfCommentsActive></h2>
				<div class="EntryContent">
					<div class="EntryBody">
						<$MTEntryBody$>
					</div>
				</div>
			 </div>
			 </MTEntries>
	
		</div> <!-- End DocuemntContent -->
		
		<div class="Module">
			<h2>Recent Posts</h2>
			<ul class="ModuleList">
				<MTEntries lastn="10">
				<li class="ModuleListItem"><a href="<$MTEntryPermalink$>"><$MTEntryTitle$></a></li>
				</MTEntries>
			</ul>	
		</div>

		<MTIfArchiveTypeEnabled archive_type="Category">
		<div class="Module">
			<h2>Browse by Categories</h2>
			<MTTopLevelCategories>
			<MTSubCatIsFirst><ul class="ModuleList"></MTSubCatIsFirst>
			<MTIfNonZero tag="MTCategoryCount">
			<li class="ModuleListItem"><a href="<$MTCategoryArchiveLink$>" title="<$MTCategoryDescription$>"><MTCategoryLabel></a>
			<MTElse>
			<li class="ModuleListItem"><MTCategoryLabel>
			</MTElse>
			</MTIfNonZero>
			<MTSubCatsRecurse>
			</li>
			<MTSubCatIsLast></ul></MTSubCatIsLast>
			</MTTopLevelCategories>
		</div>
		</MTIfArchiveTypeEnabled>
	
		<?php include($_SERVER['DOCUMENT_ROOT']."/ecc/ssi/docfooter.php"); ?>
	
	</div>
	</div>
	
</div>

<?php include($_SERVER['DOCUMENT_ROOT']."/ecc/ssi/uix.php"); ?>
</body>
</html>