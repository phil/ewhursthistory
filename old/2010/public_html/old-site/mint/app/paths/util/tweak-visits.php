<?php
/******************************************************************************
 Mint
  
 Copyright 2004-2005 Shaun Inman. This code cannot be redistributed without
 permission from http://www.shauninman.com/
 
 More info at: http://www.haveamint.com/
 
 ******************************************************************************
 Utility Path
 ******************************************************************************/
 if (!defined('MINT')) { header('Location:/'); }; // Prevent viewing this file 
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
<title>Mint: Tweak Visits</title>
<style type="text/css" title="text/css" media="screen">
/* <![CDATA[ */
body
{
	position: relative;
	background-color: #FFF;
	margin: 0;
	padding: 48px 0;
	font: 76%/1.6em "Lucida Grande", Verdana, Arial, sans-serif;
	color: #333;
	text-align: center;
}

div
{
	width: 400px;
	margin: 0 auto;
	text-align: left;
}

h1
{
	font-weight: normal;
	line-height: 1.2em;
}

th,td
{
	text-align: left;
	vertical-align: top;
	white-space: nowrap;
}
input[type=text]
{
	width: 64px;
}

td span 
{
	font-size: 0.82em;
}

th.saved
{
	border: 1px solid #F2F2C2;
	background-color: #FFC;
	padding: 0.6em 1.0em;
}
/* ]]> */
</style>
</head>
<body>
<div>
<h1>Mint says, "I get by with a little help from my friends."</h1>

<p>Use the form below to edit your Past Year or monthly visits. Any changes are compared against the values originally sent to the browser with this form and the difference is added to the current totals so you won't miss any hits while making these changes.</p>

<form method="post" action="">
<table>
	<tr>
		<th>Date (YYYMMDD)</th>
		<th>Total</th>
		<th colspan="2">Uniques</th>
	</tr>
<?php
	
	// Get incorrect month visits
	$pepper = $Mint->getPepperByClassName('SI_Default');
	$existingMonths	= $pepper->data['visits'][4];
	
	if (isset($_POST['action']) && $_POST['action'] == 'tweak-visits')
	{
		foreach($_POST['months'] as $timestamp => $hits)
		{
			// Diff the control numbers and add difference to current totals to avoid missing hits that occur between loading numbers and saving.
			$diffTotal = $hits['total'] - $_POST['controlmonth'][$timestamp]['total'];
			$existingMonths[$timestamp]['total'] += $diffTotal;
			
			$diffUniques = $hits['unique'] - $_POST['controlmonth'][$timestamp]['unique'];
			$existingMonths[$timestamp]['unique'] += $diffUniques;
		}
		
		if (isset($_POST['delete']) && !empty($_POST['delete']))
		{
			foreach($_POST['delete'] as $timestamp)
			{
				unset($existingMonths[$timestamp]);
			}
		}
		
		$pepper->data['visits'][4] = $existingMonths;
		$Mint->_save();
		echo '<th colspan="4" class="saved">Saved.</th>';
	}
	
	foreach($existingMonths as $timestamp => $hits)
	{
		echo '
<tr>
	<td>'.$Mint->offsetDate('M y', $timestamp).' <span>'.$Mint->offsetDate('(Y-m-d g:ia)', $timestamp).'</span></td>
	<td><input type="text" value="'.$hits['total'].'" name="months['.$timestamp.'][total]" /><input type="hidden" value="'.$hits['total'].'" name="controlmonth['.$timestamp.'][total]" /></td>
	<td><input type="text" value="'.$hits['unique'].'" name="months['.$timestamp.'][unique]" /><input type="hidden" value="'.$hits['unique'].'" name="controlmonth['.$timestamp.'][unique]" /></td>
	<td><input type="checkbox" value="'.$timestamp.'" name="delete[]" /> Delete</td>
</tr>';
	}
?>
</table>
<input type="hidden" name="action" value="tweak-visits" />
<input type="submit" value="Save Changes" />
</form>
</div>
</body>
</html>