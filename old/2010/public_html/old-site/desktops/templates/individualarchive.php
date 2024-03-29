<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" id="sixapart-standard">
<head>
   <meta http-equiv="Content-Type" content="text/html; charset=<$MTPublishCharset$>" />
   <meta name="generator" content="Movable Type <$MTVersion$>" />
   
   <link rel="stylesheet" href="<$MTBlogURL$>styles-site.css" type="text/css" />
   <link rel="alternate" type="application/atom+xml" title="Atom" href="<$MTBlogURL$>atom.xml" />
   <link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="<$MTBlogURL$>index.xml" />
   
   <title><$MTBlogName encode_html="1"$></title>
   
   <link rel="EditURI" type="application/rsd+xml" title="RSD" href="<$MTBlogURL$>rsd.xml" />
   
   <MTBlogIfCCLicense>
   <$MTCCLicenseRDF$>
   </MTBlogIfCCLicense>
</head>
<body class="layout-two-column-right">
   <div id="container">
      <div id="container-inner" class="pkg">
      
         <div id="banner">
            <div id="banner-inner" class="pkg">
               <h1 id="banner-header"><a href="<$MTBlogURL$>" accesskey="1"><$MTBlogName encode_html="1"$></a></h1>
               <h2 id="banner-description"><$MTBlogDescription$></h2>
            </div>
         </div>
         
         <div id="pagebody">
            <div id="pagebody-inner" class="pkg">
               <div id="alpha">
                  <div id="alpha-inner" class="pkg">
                  
                     <MTEntries>
                     <$MTEntryTrackbackData$>
                     
                     <MTDateHeader><h2 class="date-header"><$MTEntryDate format="%x"$></h2></MTDateHeader>
                     <a id="a<$MTEntryID pad="1"$>"></a>
                     <div class="entry" id="entry-<$MTEntryID$>">
                        <h3 class="entry-header"><$MTEntryTitle$></h3>
                        <div class="entry-content">
                           <div class="entry-body">
                              <$MTEntryBody$>
                              <MTEntryIfExtended>
                              <p class="entry-more-link">
                                 <a href="<$MTEntryPermalink$>#more">Continue reading "<$MTEntryTitle$>" &raquo;</a>
                              </p>
                              </MTEntryIfExtended>
                              <p class="entry-footer">
                                 <span class="post-footers">Posted by <$MTEntryAuthorDisplayName$> at <$MTEntryDate format="%X"$></span> <span class="separator">|</span> <a class="permalink" href="<$MTEntryPermalink$>">Permalink</a>
                                 <MTIfCommentsActive>| <a href="<$MTEntryPermalink$>#comments">Comments (<$MTEntryCommentCount$>)</a></MTIfCommentsActive>
                                 <MTIfPingsActive>| <a href="<$MTEntryPermalink$>#trackback">TrackBacks (<$MTEntryTrackbackCount$>)</a></MTIfPingsActive>
                              </p>
                           </div>
                        </div>
                     </div>
                     </MTEntries>
                  </div>
               </div>
               
               <div id="beta">
                  <div id="beta-inner" class="pkg">
                     <div class="module-search module">
                        <h2 class="module-header">Search</h2>
                        <div class="module-content">
                           <form method="get" action="<$MTCGIPath$><$MTSearchScript$>">
                              <input type="hidden" name="IncludeBlogs" value="<$MTBlogID$>" />
                              <label for="search" accesskey="4">Search this blog:</label><br />
                              <input id="search" name="search" size="20" />
                              <input type="submit" value="Search" />
                           </form>
                        </div>
                     </div>
                     
                     <MTIfArchiveTypeEnabled archive_type="Category"><div class="module-categories module">
                        <h2 class="module-header">Categories</h2>
                        <div class="module-content">
                        <MTTopLevelCategories>
                        <MTSubCatIsFirst><ul class="module-list"></MTSubCatIsFirst>
                           <MTIfNonZero tag="MTCategoryCount">
                           <li class="module-list-item"><a href="<$MTCategoryArchiveLink$>" title="<$MTCategoryDescription$>"><MTCategoryLabel></a>
                           <MTElse>
                           <li class="module-list-item"><MTCategoryLabel>
                           </MTElse>
                           </MTIfNonZero>
                              <MTSubCatsRecurse>
                           </li>
                        <MTSubCatIsLast></ul></MTSubCatIsLast>
                        </MTTopLevelCategories>
                        </div>
                     </div>
                     </MTIfArchiveTypeEnabled>
                     
                     <MTIfArchiveTypeEnabled archive_type="Monthly">
                     <div class="module-archives module">
                        <h2 class="module-header"><a href="<$MTBlogURL$>archives.html">Archives</a></h2>
                        <div class="module-content">
                        <MTArchiveList archive_type="Monthly">
                           <MTArchiveListHeader><ul class="module-list"></MTArchiveListHeader>
                              <li class="module-list-item"><a href="<$MTArchiveLink$>"><$MTArchiveTitle$></a></li>
                           <MTArchiveListFooter></ul></MTArchiveListFooter>
                        </MTArchiveList>
                        </div>
                     </div>
                     </MTIfArchiveTypeEnabled>
                     
                     <div class="module-archives module">
                        <h2 class="module-header">Recent Posts</h2>
                        <div class="module-content">
                           <ul class="module-list">
                           <MTEntries lastn="10">
                              <li class="module-list-item"><a href="<$MTEntryPermalink$>"><$MTEntryTitle$></a></li>
                           </MTEntries>
                           </ul>
                        </div>
                     </div>
                     
                     <div class="module-syndicate module">
                        <div class="module-content">
                           <a href="<$MTBlogURL$>atom.xml">Subscribe to this blog's feed</a><br />
                           [<a href="http://www.sixapart.com/about/feeds">What is this?</a>]
                        </div>
                     </div>
                     
                     <MTBlogIfCCLicense>
                     <div class="module-creative-commons module">
                        <div class="module-content">
                           <a href="<$MTBlogCCLicenseURL$>"><img alt="Creative Commons License" src="<$MTBlogCCLicenseImage$>" /></a><br />
                           This weblog is licensed under a <a href="<$MTBlogCCLicenseURL$>">Creative Commons License</a>.
                        </div>
                     </div>
                     </MTBlogIfCCLicense>
                     
                     <div class="module-powered module">
                        <div class="module-content">
                           Powered by<br /><a href="http://www.sixapart.com/movabletype/">Movable Type <$MTVersion$></a>
                        </div>
                     </div>
                  </div>
               </div>
            </div>
         </div>
      </div>
   </div>
</body>
</html>
