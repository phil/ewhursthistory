<?php
if (!isset($Mint->tmp['pageTitle']))
{
	$Mint->tmp['pageTitle'] = $Mint->cfg['siteDisplay'];
}
if (!isset($Mint->tmp['headTags']))
{
	$Mint->tmp['headTags'] = '';
}
?>
<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
<title>Mint: <?php echo $Mint->tmp['pageTitle']; ?></title>
<link  type="text/css" href="app/styles/mint.css" rel="stylesheet" />
<script type="text/javascript" src="app/scripts/si-object-mint.js"></script>
<?php echo $Mint->tmp['headTags']; ?>