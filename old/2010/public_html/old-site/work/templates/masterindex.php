<?php

$HeadTitle = "Work";
$HeadDescritpion = "";
$headKeywords = "";

$HeadLinks = array(
	'<link rel="alternate" type="application/atom+xml" title="Atom" href="<$MTBlogURL$>syndicate/atom.xml" />',
	'<link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="<$MTBlogURL$>syndicate/rss.xml" />',
	'<link rel="EditURI" type="application/rsd+xml" title="RSD" href="<$MTBlogURL$>rsd.xml" />');

include($_SERVER['DOCUMENT_ROOT']."/ssi/htmlhead.php");
?>

<body id="body-journal">
<? include($_SERVER['DOCUMENT_ROOT']."/ssi/skiptocontent.php") ?>
<? include($_SERVER['DOCUMENT_ROOT']."/ssi/masthead.php") ?>
<? include($_SERVER['DOCUMENT_ROOT']."/ssi/navigation.php") ?>

<div id="work-wrapper" class="section-wrapper">
  <div id="content" class="section">
 
				<MTEntries lastn="1">
				<div id="latest-job" class="job">
					<$MTEntryTrackbackData$>
					<h1 id="a<$MTEntryID pad="1"$>" class="job-title"><a href="<$MTEntryPermalink$>"><$MTEntryTitle smarty_pants="1"$></a></h1>
					
					<div class="job-content">
						<$MTEntryBody  smarty_pants="1"$>
					</div>

					<div class="job-details">
						
					</div>
				</div>
				</MTEntries>
				
				
    
        <div id="recent-jobs">
           <h1>Recently, I've mostly been doing . . .</h1>
           <ul>
            <MTEntries lastn="10" offset="1">
            <li><a href="<$MTEntryPermalink$>" class="job-link"><span class="job-date"><$MTEntryDate format="%b %e"$></span> <span class="job-title"><$MTEntryTitle  smarty_pants="1"$></span></a></li>
            </MTEntries>
           </ul>
          <p class="more-information"><a href="syndicate/rss.xml">RSS 2.0</a> | <a href="syndicate/atom.xml">Atom</a> | <a href="achive.php">Previous Jobs</a></p>
        </div>

<div id="clients">
					<h1>Clients</h1>
						<MTTopLevelCategories>
						<MTSubCatIsFirst><ul></MTSubCatIsFirst>
							<MTIfNonZero tag="MTCategoryCount">
							<li><a href="<$MTCategoryArchiveLink$>" title="<$MTCategoryDescription$>"><span class="client-name"><MTCategoryLabel  smarty_pants="1"></span></a></li>
							</MTIfNonZero>
							<MTSubCatsRecurse>
						<MTSubCatIsLast></ul></MTSubCatIsLast>
						</MTTopLevelCategories>
                                              <p class="more-information"></p>
				</div>

        <div class="section-end"></div>
        
  </div>
</div>

<? include($_SERVER['DOCUMENT_ROOT']."/ssi/footer.php") ?>
  
</body>
</html>