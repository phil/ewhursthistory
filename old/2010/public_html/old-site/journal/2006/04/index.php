<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" id="sixapart-standard">
<head>
   <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
   <meta name="generator" content="Movable Type 3.2" />

   <link rel="stylesheet" href="http://www.whatisnext.co.uk/journal/styles-site.css" type="text/css" />
   <link rel="alternate" type="application/atom+xml" title="Atom" href="http://www.whatisnext.co.uk/journal/atom.xml" />
   <link rel="alternate" type="application/rss+xml" title="RSS 2.0" href="http://www.whatisnext.co.uk/journal/index.xml" />

   <title>whatisnext.co.uk: April 2006 Archives</title>

   <link rel="start" href="http://www.whatisnext.co.uk/journal/" title="Home" />
   <link rel="prev" href="http://www.whatisnext.co.uk/journal/2006/02/" title="February 2006" />
   <link rel="next" href="http://www.whatisnext.co.uk/journal/2006/05/" title="May 2006" />
</head>
<body class="layout-one-column">
   <div id="container">
      <div id="container-inner" class="pkg">

         <div id="banner">
            <div id="banner-inner" class="pkg">
               <h1 id="banner-header"><a href="http://www.whatisnext.co.uk/journal/" accesskey="1">whatisnext.co.uk</a></h1>
               <h2 id="banner-description">Me and my life</h2>
            </div>
         </div>

         <div id="pagebody">
            <div id="pagebody-inner" class="pkg">
               <div id="alpha">
                  <div id="alpha-inner" class="pkg">
                     
                     <p class="content-nav">
                        <a href="http://www.whatisnext.co.uk/journal/2006/02/">&laquo; February 2006</a> |
                        <a href="http://www.whatisnext.co.uk/journal/">Main</a>
                        | <a href="http://www.whatisnext.co.uk/journal/2006/05/">May 2006 &raquo;</a>
                     </p>
                     
                                          <!--
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:trackback="http://madskills.com/public/xml/rss/module/trackback/"
         xmlns:dc="http://purl.org/dc/elements/1.1/">
<rdf:Description
    rdf:about="http://www.whatisnext.co.uk/journal/2006/04/index.php#000560"
    trackback:ping="http://www.whatisnext.co.uk/cgi-bin/mt/mt-tb.cgi/560"
    dc:title="Styling the Flickr Badge"
    dc:identifier="http://www.whatisnext.co.uk/journal/2006/04/index.php#000560"
    dc:subject="(X)HTML"
    dc:description="As I&amp;#8217;m going around trying to smarten this place up, I ran into a problem with the Flickr Badge. First, It has a maximum of ten image thumbs. Second, even the small thumbnails are pretty big. Time to get out..."
    dc:creator="Melody"
    dc:date="2006-04-28T00:05:09+00:00" />
</rdf:RDF>
-->


                     <h2 class="date-header">April 28, 2006</h2>
                     <a id="a000560"></a>
                     <div class="entry" id="entry-560">
                        <h3 class="entry-header">Styling the Flickr Badge</h3>
                        <div class="entry-content">
                           <div class="entry-body">
                              <p>As I&#8217;m going around trying to smarten this place up, I ran into a problem with the Flickr Badge. <em>First,</em> It has a maximum of ten image thumbs. <em>Second,</em> even the small thumbnails are pretty big. Time to get out the coding equivilent of an axe.</p>
                                                            <h2>First, the Limited number of images</h2>

<p>When you do the wizard on Flickr to create a badge of your photos, it has a limited number of options to change the number of photos to display. Ok, this is easliy hacked by changing the code at the end, nut it max&#8217;s out at 10. Even if you type 30, it will only display 10. So, getting around this should be easy, simply paste the code more than once into your <span class="caps">HTML.</span> Nope! You&#8217;ll get the same ten photos twice, notsure if this is a bug or deliberate, but it&#8217;s not quite what we were looking for. Try making another badge that only gets its photos from one of your tags, or random, or set etc. </p>

<h2>Making the Thumbs smaller</h2>

<p>Next up, the default small thumbnail was too big to sit nicly into my design idea. To correct this, <strong>[CSS enters stage right]</strong> we&#8217;ll be using our friend <span class="caps">CSS.</span> Forcing a width and height onto <code>.flickr_badge_image a img</code> resizes the img. Obviously only resize an image smaller than the original, and try to keep the proportion correct. I&#8217;ve used 32&#215;32 pixels as its about half the size of 75&#215;75 pixels.</p>
                              
                              <p class="entry-footer">
                                 <span class="post-footers">Posted by Phil at 12:05 AM</span> <span class="separator">|</span> <a class="permalink" href="http://www.whatisnext.co.uk/journal/2006/04/styling_the_flickr_badge.php">Permalink</a>
                                 | <a href="http://www.whatisnext.co.uk/journal/2006/04/styling_the_flickr_badge.php#comments">Comments (0)</a>
                                 | <a href="http://www.whatisnext.co.uk/journal/2006/04/styling_the_flickr_badge.php#trackback">TrackBacks (0)</a>
                              </p>
                           </div>
                        </div>
                     </div>
                                          <!--
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:trackback="http://madskills.com/public/xml/rss/module/trackback/"
         xmlns:dc="http://purl.org/dc/elements/1.1/">
<rdf:Description
    rdf:about="http://www.whatisnext.co.uk/journal/2006/04/index.php#000559"
    trackback:ping="http://www.whatisnext.co.uk/cgi-bin/mt/mt-tb.cgi/559"
    dc:title="Please excuse the mess"
    dc:identifier="http://www.whatisnext.co.uk/journal/2006/04/index.php#000559"
    dc:subject="whatisnext.co.uk"
    dc:description="Between full-time work, part-time freelance, eating and sleeping, I haven&amp;#8217;t had enough time to do any spring cleaing around here. So, updates to the styles and content is patchy at best, and downright crap for the rest of the time...."
    dc:creator="Melody"
    dc:date="2006-04-27T23:56:03+00:00" />
</rdf:RDF>
-->


                     <h2 class="date-header">April 27, 2006</h2>
                     <a id="a000559"></a>
                     <div class="entry" id="entry-559">
                        <h3 class="entry-header">Please excuse the mess</h3>
                        <div class="entry-content">
                           <div class="entry-body">
                              <p>Between full-time work, part-time freelance, eating and sleeping, I haven&#8217;t had enough time to do any spring cleaing around here. So, updates to the styles and content is patchy at best, and downright crap for the rest of the time. What makes it even harder, is using way too many machines to try and do the changes. Which means that i&#8217;m currently coding this site in whatever tools i can get my hands on, including: notepad, textwrangler, dreamweaver, Skedit, Visual Studio 2005. Put simlpy, whatever is installed, or whatever is a free download! By the way, my favourite of editor is the brilliant <a href="http://www.skti.org/skEdit.php">Skedit</a>, go check it out now.</p>
                              
                              <p class="entry-footer">
                                 <span class="post-footers">Posted by Phil at 11:56 PM</span> <span class="separator">|</span> <a class="permalink" href="http://www.whatisnext.co.uk/journal/2006/04/please_excuse_the_mess.php">Permalink</a>
                                 | <a href="http://www.whatisnext.co.uk/journal/2006/04/please_excuse_the_mess.php#comments">Comments (80)</a>
                                 | <a href="http://www.whatisnext.co.uk/journal/2006/04/please_excuse_the_mess.php#trackback">TrackBacks (0)</a>
                              </p>
                           </div>
                        </div>
                     </div>
                                          <!--
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:trackback="http://madskills.com/public/xml/rss/module/trackback/"
         xmlns:dc="http://purl.org/dc/elements/1.1/">
<rdf:Description
    rdf:about="http://www.whatisnext.co.uk/journal/2006/04/index.php#000557"
    trackback:ping="http://www.whatisnext.co.uk/cgi-bin/mt/mt-tb.cgi/557"
    dc:title="&amp;amp;nbsp;"
    dc:identifier="http://www.whatisnext.co.uk/journal/2006/04/index.php#000557"
    dc:subject="(X)HTML"
    dc:description="There was once a time when I could type this character combination without having to think too much about what order the &amp;#8216;n&amp;#8217;, &amp;#8216;b&amp;#8217;, &amp;#8216;s&amp;#8217; and &amp;#8216;p&amp;#8217; went. For those of you who don&amp;#8217;t know this entity very well, it&amp;#8217;s..."
    dc:creator="Melody"
    dc:date="2006-04-18T22:21:58+00:00" />
</rdf:RDF>
-->


                     <h2 class="date-header">April 18, 2006</h2>
                     <a id="a000557"></a>
                     <div class="entry" id="entry-557">
                        <h3 class="entry-header">&amp;nbsp;</h3>
                        <div class="entry-content">
                           <div class="entry-body">
                              <p>There was once a time when I could type this character combination without having to think too much about what order the &#8216;n&#8217;, &#8216;b&#8217;, &#8216;s&#8217; and &#8216;p&#8217; went. For those of you who don&#8217;t know this entity very well, it&#8217;s the non-breaking-space entity. It used to be the most overly used of all the entities, it was the web designers best friend. So why doesn&#8217;t anyone use them anymore?</p>
                                                            <p>The reason this entity gained fame and fortune has more to do with arcane voodoo, than good coding. It was used during the great <em>table dynasty [1995&mdash;2002]</em>, when the only way to layout a two coloum grid was to have a two column table. EYou see, everything was done with tables, say you wanted a margin seperating these two columns, easy, just add another column! it really was that simple. But, this middle column wouldn&#8217;t have any text in it, it soul purpuse was to make a bit of space between the content column and the sidebar column. Which in some browsers could cause unexpected results, so any web desinger worth their namesake would simlpy add <code>&amp;amp;nbsp;</code> entity to the column.</p>

<p>Now thing have changed. The separation of structure and style has killed the need to the arcane zoodoo of table layout, and with it, the &nbsp; entity was left in the gutter <em>(litterally)</em>. The web has forgotton how useful this little entity can be.</p>

<h2>What is this &nbsp; thing anyway?</h2>

<p>Its full name is <strong>non-breaking space</strong>, its entity reference is <code>&amp;amp;nbsp;</code>, and its entity code is <code>&amp;amp;#160;</code>. As the name suggests, when rendered by a browser, it is a space, just like any other space. But, and here&#8217;s the clever bit, this space will not <em>break/wordwrap</em> at the end of a line of text. Instead, the browser will find the nearest space before and break there. Why would you want to do this? It keeps words together, thats why.</p>

<h2>Example</h2>

<p>Say i&#8217;m writing some copy for a web site, Its not much, just one paragraph about 10 lines long. At the end of the first line is the company name, &#8220;Crazyman Company&#8221;. But the &#8220;Crazyman&#8221; and the &#8220;Company&#8221; are on different lines because they don&#8217;t both fit on the first line, so &#8220;Company&#8221; gets wrapped onto the line below. Simple, instead of typing &#8220;<code>Crazyman Company</code>&#8221;, use &#8220;<code>Crazyman&amp;amp;nbsp;Company</code>. Now the browser will wrap at the space  before the &#8220;Crazyman&#8221; so the company name stays together, giving it more impact and making it easier to read.</p>

<h2><span class="caps">OK, </span>but why?</h2>

<p>Beacuse it looks nicer, you&#8217;re supposed to be a web designer? go figure.</p>
                              
                              <p class="entry-footer">
                                 <span class="post-footers">Posted by Phil at 10:21 PM</span> <span class="separator">|</span> <a class="permalink" href="http://www.whatisnext.co.uk/journal/2006/04/nbsp_1.php">Permalink</a>
                                 | <a href="http://www.whatisnext.co.uk/journal/2006/04/nbsp_1.php#comments">Comments (0)</a>
                                 | <a href="http://www.whatisnext.co.uk/journal/2006/04/nbsp_1.php#trackback">TrackBacks (0)</a>
                              </p>
                           </div>
                        </div>
                     </div>
                                          <!--
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:trackback="http://madskills.com/public/xml/rss/module/trackback/"
         xmlns:dc="http://purl.org/dc/elements/1.1/">
<rdf:Description
    rdf:about="http://www.whatisnext.co.uk/journal/2006/04/index.php#000549"
    trackback:ping="http://www.whatisnext.co.uk/cgi-bin/mt/mt-tb.cgi/549"
    dc:title="New Desktops"
    dc:identifier="http://www.whatisnext.co.uk/journal/2006/04/index.php#000549"
    dc:subject="whatisnext.co.uk"
    dc:description="Check out the new Desktops, free to download and do with as you please! I&apos;ll be adding more every month (hopefully!), so keep coming back. Subscribe to the journal RSS/Atom feeds for easy updates...."
    dc:creator="Melody"
    dc:date="2006-04-13T13:32:57+00:00" />
</rdf:RDF>
-->


                     <h2 class="date-header">April 13, 2006</h2>
                     <a id="a000549"></a>
                     <div class="entry" id="entry-549">
                        <h3 class="entry-header">New Desktops</h3>
                        <div class="entry-content">
                           <div class="entry-body">
                              <p>Check out the new <a href="/projects/desktops/">Desktops</a>, free to download and do with as you please! I'll be adding more every month <em>(hopefully!)</em>, so keep coming back. Subscribe to the journal <a href="http://www.whatisnext.co.uk/journal/syndicate/rss.xml">RSS</a>/<a href="http://www.whatisnext.co.uk/journal/syndicate/atom.xml">Atom</a> feeds for easy updates.</p>
                              
                              <p class="entry-footer">
                                 <span class="post-footers">Posted by Phil at 01:32 PM</span> <span class="separator">|</span> <a class="permalink" href="http://www.whatisnext.co.uk/journal/2006/04/new_desktops.php">Permalink</a>
                                 | <a href="http://www.whatisnext.co.uk/journal/2006/04/new_desktops.php#comments">Comments (0)</a>
                                 | <a href="http://www.whatisnext.co.uk/journal/2006/04/new_desktops.php#trackback">TrackBacks (0)</a>
                              </p>
                           </div>
                        </div>
                     </div>
                                          <!--
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:trackback="http://madskills.com/public/xml/rss/module/trackback/"
         xmlns:dc="http://purl.org/dc/elements/1.1/">
<rdf:Description
    rdf:about="http://www.whatisnext.co.uk/journal/2006/04/index.php#000548"
    trackback:ping="http://www.whatisnext.co.uk/cgi-bin/mt/mt-tb.cgi/548"
    dc:title="What happend to the Blue?"
    dc:identifier="http://www.whatisnext.co.uk/journal/2006/04/index.php#000548"
    dc:subject="whatisnext.co.uk"
    dc:description="Put simply, i got a bit boarded of it. It was all getting too dark around here and as you might have noticed (or not), I&apos;ve been doing some pretty big changes, all in full view of the masses. Which..."
    dc:creator="Melody"
    dc:date="2006-04-13T09:38:24+00:00" />
</rdf:RDF>
-->


                     
                     <a id="a000548"></a>
                     <div class="entry" id="entry-548">
                        <h3 class="entry-header">What happend to the Blue?</h3>
                        <div class="entry-content">
                           <div class="entry-body">
                              <p>Put simply, i got a bit boarded of it. It was all getting too dark around here and as you might have noticed (or not), I've been doing some pretty big changes, all in full view of the masses. Which explains the green and red boxes <em>(for CSS problem solving)</em> all over the place, and why half the site doesn't work!</p>
                                                            <h2>What Works?</h2>

<p>The <a href="/">Home page</a>, The <a href="/about/">About Page</a>, enough of the <a href="/journal">Journal</a>  to get started, and the projects page, although its only got some desktops at the moment, but do feel free to download them, most sizes are covered, and they do get updated.</p>

<h2>What Doesn't</h2>

<p><em>Everything else!</em>. The entire  <a href="/work">Work</a> area, which will be my portfolio of client work. Lots of back-end Journal Pages. </p>

<p>Appolgies if anyone tries to comment and it doesn't work.</p>

<h2>What's planned?</h2>

<p>Lots of small <strong>un</strong>-important Journal Posts to fill things out a bit. My Work Portfolio. More free designer things like desktops, pretty ideas, typefaces. Amongst other things.</p>
                              
                              <p class="entry-footer">
                                 <span class="post-footers">Posted by Phil at 09:38 AM</span> <span class="separator">|</span> <a class="permalink" href="http://www.whatisnext.co.uk/journal/2006/04/what_happend_to_the_blue.php">Permalink</a>
                                 | <a href="http://www.whatisnext.co.uk/journal/2006/04/what_happend_to_the_blue.php#comments">Comments (0)</a>
                                 | <a href="http://www.whatisnext.co.uk/journal/2006/04/what_happend_to_the_blue.php#trackback">TrackBacks (0)</a>
                              </p>
                           </div>
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
