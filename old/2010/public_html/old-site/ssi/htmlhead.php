<?php

if ( $HeadDescription == "" )
{
	$HeadDescription = "whatisnext.co.uk is a small development company from Surrey. On this site, you'll find my Journal, some Desktops, other freebees and my Portfolio";
}

if ( $HeadKeywords != "" )
{
	$HeadKeywords += ", ";
}

?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en" xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
	<title><?php echo $HeadTitle; ?></title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<meta name="description" content="<? echo $HeadDescription; ?>" />
	<meta name="keywords" content="<? echo $HeadKeywords; ?>whatisnext, What Is Next, Next Century Systems, Next, XHTML, HTML, XML, CSS" />

	<meta name="author" content="Phil Balchin" />
	<meta name="Copyright" content="Copyright (c) 2005 Next Century Systems" />

	<?php
	
	for($i=0; $i<count($HeadMetas); $i++ )
	{
		echo $HeadMetas[$i];
	}
	
	?>
	
	<link rel="shortcut icon" href="/favicon.ico" />


	<?php
	
	for($i = 0; $i < count($HeadLinks); $i++)
	{
		echo $HeadLinks[$i];
	}
	
	?>
	
	<? include($_SERVER['DOCUMENT_ROOT'] . "/ssi/stylesheets.php") ?>

	<script src="/js/scripts.js" type="text/javascript"></script>
	
	<script src="/mint/?js" type="text/javascript"></script>
	
</head>