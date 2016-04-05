<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=<$MTPublishCharset$>" />
	<title>Photographics | <$MTEntryTitle smarty_pants="1" encode_html="1" $></title>
	<? include($_SERVER['DOCUMENT_ROOT']."/photographics/ssi/stylesheets.php") ?>
	<script src="/js/jquery/jquery.js" type="text/javascript"></script>
</head>
<body id="body-photos-dark">
	<div id="wrapper">
		
		<div class="gallery-nav">
			<p><a href="javascript:history.go(-1)">&laquo; Return to Gallery</a></p>
		</div>

		<div class="photographic">
			<img src="<$MTBlogURL$>photos/<$MTEntryExcerpt$>.jpg" alt="<$MTEntryTitle smarty_pants="1" encode_html="1" $>" />
		</div>

		<div class="photographic-details">
			<h1><$MTEntryTitle smarty_pants="1" $></h1>

			<$MTEntryBody$>

			<p class="gallery-nav-index">Galleries: <MTEntryCategories><a href="<$MTCategoryArchiveLink$>"><$MTCategoryLabel smarty_pants="1" encode_html="1" $></a>, </MTEntryCategories></p>
		</div>

		<div class="gallery-nav">
			<p><a href="javascript:history.go(-1)">&laquo; Return to Gallery</a></p>
		</div>
	
		<? include($_SERVER['DOCUMENT_ROOT']."/photographics/ssi/footer.php") ?>

	</div>
</body>
</html>
