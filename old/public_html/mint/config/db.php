<?php
/******************************************************************************
 Mint
  
 Copyright 2004-2005 Shaun Inman. This code cannot be redistributed without
 permission from http://www.shauninman.com/
 
 More info at: http://www.haveamint.com/
 
 ******************************************************************************
 Configuration
 ******************************************************************************/
 if (!defined('MINT')) { header('Location:/'); }; // Prevent viewing this file 

$Mint = new Mint (array
(
	'server'	=> 'orf-mysql1.brinkster.com',
	'username'	=> 'ncs42',
	'password'	=> 'princess42',
	'database'	=> 'ncs42',
	'tblPrefix'	=> 'mint_ewhurst_'
));
?>