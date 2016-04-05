<?php
/******************************************************************************
 Mint
  
 Copyright 2004-2005 Shaun Inman. This code cannot be redistributed without
 permission from http://www.shauninman.com/
 
 More info at: http://www.haveamint.com/
 
 ******************************************************************************
 Application Path
 ******************************************************************************/
 if (!defined('MINT')) { header('Location:/'); }; // Prevent viewing this file 
 
include_once('app/lib/mint.php');
include_once('app/lib/pepper.php');
include_once('config/db.php');

$Mint->cfg['debug'] = false;

// Pepper is loaded separately so that the $Mint object exists in the global space
$Mint->loadPepper();

/******************************************************************************
 Record Path
 
 ******************************************************************************/
if (isset($_GET['js']) || isset($_GET['record']))
{
	include_once('app/paths/record/index.php');
	exit();
}

/******************************************************************************
 Update Path

 ******************************************************************************/
if
(
	$Mint->cfg['version'] &&
	$Mint->cfg['version'] < $Mint->version
)
{
	$Mint->update();
}
foreach ($Mint->pepper as $pepperId => $pepper)
{
	if ($Mint->cfg['pepperShaker'][$pepperId]['version'] < $pepper->version)
	{
		$pepper->update();
	}
}

/******************************************************************************
 Installation Path

 ******************************************************************************/
if 
(
	!$Mint->errors['fatal'] && 
	(
		!$Mint->cfg['installed'] || 
		(
			isset($_POST['MintPath']) && 
			$_POST['MintPath'] == 'Install'
		)
	)
)
{
	include_once('app/paths/install/index.php');
}

/******************************************************************************
 Utility Path (public)
 
 ******************************************************************************/
if (isset($_GET['info']))
{
	include_once('app/paths/util/info.php');
	exit();
}
if (isset($_GET['ignore']))
{
	$Mint->bakeCookie('MintIgnore', 'true', (time() + (3600 * 24 * 365 * 25)));
}

/******************************************************************************
 Ping Path

 Used when transfering a license
 ******************************************************************************/
if (isset($_SERVER["HTTP_X_MINT_PING"])) 
{
	echo 'INSTALLED';
	exit();
}

/******************************************************************************
 Widget Path

 Manages own authentication
 ******************************************************************************/
if (isset($_POST['widget']))
{
	echo $Mint->widget();
	exit();
}

/******************************************************************************
 Authorization Path

 Login/logout 
 ******************************************************************************/
if (!$Mint->errors['fatal'])
{
	include_once('app/paths/auth/index.php');
}

/******************************************************************************
 Utility Path (private)
 
 ******************************************************************************/
if (isset($_GET['tweak']))
{
	include_once('app/paths/util/tweak-visits.php');
	exit();
}

/******************************************************************************
 Uninstall Path

 ******************************************************************************/
if (isset($_GET['uninstall']))
{
	include_once('app/paths/uninstall/index.php');
}

/******************************************************************************
 Custom Path

 RSS and other custom function calls. Must immediately follow 
 Authorization or we'll have a bit of a security hole.
 ******************************************************************************/
if 
(
	isset($_GET['custom']) || 
	(
		isset($_POST['MintPath']) && 
		$_POST['MintPath'] == 'Custom'
	) || 
	isset($_GET['RSS'])
)
{
	include_once('app/paths/custom/index.php');
	exit();
}

/******************************************************************************
 Preference Path

 ******************************************************************************/
if 
(
	isset($_GET['preferences']) ||
	(
		isset($_POST['MintPath']) && 
		$_POST['MintPath'] == 'Preferences'
	) ||
	isset($_GET['instructions'])
)
{
	include_once('app/paths/preferences/index.php');
}

/******************************************************************************
 Feedback Path

 Positive feedback notices
 ******************************************************************************/
if ($Mint->feedback['feedback'] && empty($Mint->errors['list']))
{
	include_once('app/paths/feedback/index.php');
	exit();
}

/******************************************************************************
 Fatal Error Path

 Database and other
 ******************************************************************************/
if ($Mint->errors['fatal'])
{
	include_once('app/paths/errors/index.php');
	exit();
}
$Mint->bakeCookie('MintConfigurePepper', '', time() - 365 * 24 * 60 * 60);

/******************************************************************************
 Display (default) Path
 
 ******************************************************************************/
include_once('app/paths/display/index.php');
?>