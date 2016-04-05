<?php
/******************************************************************************
 Mint
 
 Copyright 2004-2005 Shaun Inman. This code cannot be redistributed without
 permission from http://www.shauninman.com/
 
 More info at: http://www.haveamint.com/
 
 ******************************************************************************
 Attaches Mint JavaScript to all PHP-parsed pages automatically 
 ******************************************************************************/
function Minted($page) 
{
	$ip = array(); // Add IP addresses that Mint should ignore
	if 
	(
		strpos($page,'frameset') !== false || 
		(!empty($ip) && in_array($_SERVER['REMOTE_ADDR'], $ip))
	)
	{
		return $page;
	}
	
	$mint = '<script src="/mint/?js" type="text/javascript" language="javascript"></script>';
	$replace = array
	(
		'</head>',
		'</HEAD>'
	);
	return str_replace($replace, "{$mint}\r</head>", $page);
}
ob_start("Minted");
?>