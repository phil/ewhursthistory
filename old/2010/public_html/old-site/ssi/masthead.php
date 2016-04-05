<div id="masthead-wrapper" class="setion-wrapper">
<div id="masthead" class="section">
    <div id="brand-info">
      <a href="http://www.whatisnext.co.uk"><img id="brand-logo" src="/logo16.gif" alt="whatisnext.co.uk Logotype" /></a>
      <p id="brand-name">whatisnext.co.uk</p>
    </div>
</div>
</div>

	<?php
	$mastheads = array(
	0 => array(
		"id" => "mastheadgenerichome",
		"name" => "GenericHome",
		"caption" => "www.whatisnext.co.uk",
		"url" => "http://www.whatisnext.co.uk",
		"imgurl" => "generichome.jpg",
		"type" => "GenericHome",
		"rel" => "InternalFeature"
		),
	1 => array(
		"id" => "mastheaddesktops",
		"name" => "New Desktops",
		"caption" => "New www/whatisnext.co.uk desktops are available",
		"url" => "/create/desktops/", 
		"imgurl" => "desktops.jpg",
		"type" => "DesktopFeature",
		"rel" => "InternalFeature"
		),
	2 => array (
		"id" => "mastheadfireworks",
		"name" => "GenericHome2",
		"caption" => "www.whatisnext.co.uk",
		"url" => "http://www.whatisnext.co.uk", 
		"imgurl" => "fireworks.jpg",
		"type" => "GenericHome2",
		"rel" => "InternalFeature"
		),
	3 => array (
		"id" => "mastheadtorch",
		"name" => "GenericHome3",
		"caption" => "www.whatisnext.co.uk",
		"url" => "http://www.whatisnext.co.uk", 
		"imgurl" => "torch.jpg",
		"type" => "GenericHome3",
		"rel" => "InternalFeature"
		),
	4 => array (
		"id" => "mastheadpinkfireworks",
		"name" => "GenericHome4",
		"caption" => "www.whatisnext.co.uk",
		"url" => "http://www.whatisnext.co.uk", 
		"imgurl" => "pink-fireworks.jpg",
		"type" => "GenericHome4",
		"rel" => "InternalFeature"
		)
	);
	
	$a = rand(0, count($mastheads)-1);
	
	//echo '		<div id="MastHeadFeature" class="'.$mastheads[$a]['type'].'">'."\n";
	//echo '			<a id="'.$mastheads[$a]['id'].'" href="'.$mastheads[$a]['url'].'"><img src="masthead.jpg" alt="'.$mastheads[$a]['caption'].'" /></a>'."\n";
	//echo '		</div>'."\n";
	
	?>