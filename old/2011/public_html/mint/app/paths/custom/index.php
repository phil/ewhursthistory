<?php
/******************************************************************************
 Mint
  
 Copyright 2004-2005 Shaun Inman. This code cannot be redistributed without
 permission from http://www.shauninman.com/
 
 More info at: http://www.haveamint.com/
 
 ******************************************************************************
 Custom Path
 ******************************************************************************/
 if (!defined('MINT')) { header('Location:/'); }; // Prevent viewing this file 
 
if (isset($_GET['RSS']))
{
	echo $Mint->rss();
}
else if
(
	isset($_GET['custom']) || 
	(
		isset($_POST['MintPath']) && 
		$_POST['MintPath'] == 'Custom'
	)
)
{
	$Mint->custom();
}
?>