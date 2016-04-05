<?php

if ( $HeadDescription == "" )
{
	$HeadDescription = "";
}

if ( $HeadKeywords != "" )
{
	$HeadKeywords += ", ";
}

?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en" xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
	<title>Ewhurst CC &raquo; <?php echo $HeadTitle; ?></title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<meta name="description" content="<? echo $HeadDescription; ?>" />
	<meta name="keywords" content="<? echo $HeadKeywords; ?>ewhurst, ewhurst cricket, cricket, club, surrey, James Cation, Phil Balchin" />

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
	
	<link rel="stylesheet" href="/ecc/css/screen.css" type="text/css" media="screen" />

	<script src="/js/scripts.js" type="text/javascript"></script>
	
	<script src="/mint/?js" type="text/javascript"></script>
	
</head>