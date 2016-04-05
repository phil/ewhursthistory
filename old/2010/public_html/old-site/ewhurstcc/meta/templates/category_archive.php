<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" id="sixapart-standard">
<head>
   <meta http-equiv="Content-Type" content="text/html; charset=<$MTPublishCharset$>" />
   <meta name="generator" content="Movable Type <$MTVersion$>" />

   <link rel="stylesheet" href="<$MTBlogURL$>styles-site.css" type="text/css" />
   <link rel="alternate" type="application/atom+xml" title="Atom" href="<$MTBlogURL$>atom.xml" />
   <link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="<$MTBlogURL$>index.xml" />

   <title><$MTBlogName encode_html="1"$>: <$MTArchiveTitle$> Archivesphp</title>
</head>
<body class="layout-one-column">
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
                     
                     <p class="content-nav">
                        <a href="<$MTBlogURL$>">Main</a>
                     </p>
                     
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
            </div>
         </div>
      </div>
   </div>
</body>
</html>