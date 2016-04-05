<?php
  // Page Variables
  include ($_SERVER['DOCUMENT_ROOT']."/ecc/photos/galleryinfo.php");
  $blogrelurl = "/ecc/photos";
  $blogurl = "http://www.whatisnext.co.uk/ecc/photos/";
  $section = "photosolo";
  $pgtitle = "ecc Tour 128";
  $entryid = 289;
  $img = '<img alt="ecc Tour 128" src="http://www.whatisnext.co.uk/ecc/photosassets/2004-08-13-01-20-46.jpg" width="640" height="480" />';
  $opencomments = true;
  
  // Functions
  include ($_SERVER['DOCUMENT_ROOT']."/ecc/photosmeta/functions/all.php");
  
  DocHead();
  ContentOpen();
?>

<div id="desc">
  <h1>ecc Tour 128</h1>
  <p><em>No description</em></p>
</div>

<div id="main">
  <p id="photo"><?= $img ?></p>
  <div id="meta">
    <ul>
      <li class="count">Photo <?= CatOrder($entryids, $entryid) ?> of <?= $gallerycount ?></li>
      <li class="date">13 August 2004</li>
      <li class="tags">ECC-IOW2004</li>
    </ul>
  </div>

<!-- BEGIN #commentblock -->
<div id="commentblock">

  <h2>No comments yet</h2>
  



<p class="mainbutton" id="addcommentbutton"><a href="#addcomment" class="btn"><img src="<?= $blogrelurl ?>meta/img/btn_add_a_comment.gif" alt="" width="116" height="21" /></a></p>

<!-- BEGIN #addcomment -->
<div id="addcomment">
<h2>Add a comment</h2>





<form method="post" action="http://www.whatisnext.co.uk/cgi-bin/mt/mt-comments.cgi" onsubmit="if (this.bakecookie[0].checked) rememberMe(this)" id="comments-form">

  <table cellspacing="0">
  <tr valign="top" align="left" id="row-name">
    <th><label for="c-author">Name:</label></th>
    <td><input tabindex="1" id="c-author" name="author" class="text" value="" /></td>
  </tr>

  <tr valign="top" align="left" id="row-email">
    <th><label for="c-email">Email:</label></th>
    <td><input tabindex="2" id="c-email" name="email" class="text" value="" /> <em>(not displayed)</em></td>
  </tr>

  <tr valign="top" align="left">
    <th><label for="c-url">URL:</label></th>
    <td><input tabindex="3" type="text" name="url" id="c-url" class="text" value="" /></td>
  </tr>

  <tr valign="top" align="left">
    <th>&nbsp;</th>
    <td>remember me?&nbsp; <input type="radio" id="c-remember" name="bakecookie" />&nbsp;<label for="c-remember">Yes</label>&nbsp;
    <input type="radio" id="c-forget" name="bakecookie" onclick="forgetMe(this.form)" value="Forget Info" />&nbsp;<label for="c-forget">No</label>
    <input type="hidden" name="static" value="1" />
    <input type="hidden" name="entry_id" value="289" /></td>
  </tr>

  <tr valign="top" align="left">
    <th><label for="c-text">Comment:</label></th>
    <td><textarea tabindex="4" id="c-text" name="text" rows="10" cols="40"></textarea></td>
  </tr>

  <tr valign="top" align="left">
    <th class="buttons">&nbsp;</th>
    <td class="buttons"><input type="submit" name="preview" tabindex="5" value="Preview" id="btn-preview" /> <input type="submit" name="post" tabindex="6" value="Post" id="btn-post" />
    <p>Avoid clicking &ldquo;Post&rdquo; more than once.</p></td>
  </tr>
  </table>
</form>

<script type="text/javascript">
  <!--
        if (document.getElementById('c-email').value != undefined)
        document.getElementById('c-email').value = getCookie("mtcmtmail");
      if (document.getElementById('c-author').value != undefined)
        document.getElementById('c-author').value = getCookie("mtcmtauth");
      if (document.getElementById('c-url').value != undefined)
        document.getElementById('c-url').value = getCookie("mtcmthome");
    
  if (getCookie("mtcmtauth") || getCookie("mtcmthome")) {
		document.getElementById('c-remember').checked = true;
  } else {
		document.getElementById('c-forget').checked = true;
  }
  //-->
</script>

</div>
<!-- END #addcomment -->




</div>
<!-- END #commentblock -->


</div>







<?= ContentClose(); ?>

<p id="path"><a href="<?= $blogrelurl ?>">E.C.C Tours of Duty</a> > <a href="<?= $galleryurl ?>"><?= $gallerytitle ?></a> > <a href="<?= $galleryurl ?>gallery/">Gallery</a> > ecc Tour 128</p>

<?php  include ($_SERVER['DOCUMENT_ROOT']."/ecc/photosmeta/templates/modules/mod_footer.html"); ?>
<!-- Entry ID: 289 -->
<?= DocFoot(); ?>
