<?php

error_reporting(E_ERROR | E_WARNING | E_PARSE);
global $_GET;
if ($_GET['file']) {
	ob_start();
	define('MINT',true);
	include_once('../../../app/lib/mint.php');
	include_once('../../../app/lib/pepper.php');
	include_once('../../../config/db.php');
	$_GET['key'] = $Mint->generateKey();
	ini_set("include_path", ini_get("include_path") . ":../../../");
	$Mint->loadPepper();
	$file = $_GET['file'];
	unset($_GET['referer']);
	$_GET['resource'] = $file;
	$_GET['is_download'] = 1;
	$file_parts = parse_url($file);
	$_GET['resource_title'] = 'Download: ' . $file_parts['path'];	
	$_GET['record'] = true;
	// Included to work with Session Tracker
	$sessionTracker = $Mint->getPepperByClassName('RHC3_SessionTracker');
	if ($sessionTracker) $_GET = array_merge($_GET, $sessionTracker->onRecord());
	// end Session Tracker Code
	include_once('../../../app/paths/record/index.php');
	header("Content-Disposition: attachment; filename=".basename($file));
	header('Location: ' . $_GET['file']);
	ob_end_clean();
}

?>
