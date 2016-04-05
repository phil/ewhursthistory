function display_menu(i){
	var levelCount = "../";
	
	if ( i == "0" ){
		levelCount = "";
	} else {
		var intCount2 =  i;
			for( var intCount=1; intCount < intCount2; intCount++){
				levelCount += "../";
			}
	}
	document.write ('<table border="1" width="100%" bordercolor="#808080" bordercolorlight="#FFFFFF" cellspacing="2" cellpadding="0"><tr>');
	document.write ('<td align="Center"><a href="' + levelCount + 'ewhurst/ewhurst.htm">Ewhurst</a></td>');
	document.write ('<td align="Center"><a href="' + levelCount + 'publications/pub.htm">Publications</a></td>');
	document.write ('<td align="Center"><a href="' + levelCount + 'archives/archive.htm">From our Archives</a></td>');
	document.write ('<td align="Center"><a href="' + levelCount + 'research/research.htm">Research</a></td>');
	document.write ('<td align="Center"><a href="' + levelCount + 'other_sites/other_sites.htm">Other Sites</a></td>');
	document.write ('</tr><table>');
}



function display_footer(i){
	var levelCount = "../";
	
	if ( i == "0" ){
		levelCount = "";
	} else {
		var intCount2 =  i;
			for( var intCount=1; intCount < intCount2; intCount++){
				levelCount += "../";
			}
	}
	document.write ('<table border="0" width="100%" cellsopaceing="2" cellpadding="0"><tr>');
	document.write ('<td><img src="' + levelCount + 'resources/logo1.jpg" width="98" height="144" align="Baseline" border="0" naturalsizeflag="3">');
	document.write ('<td>If you would like to contact us to purchase any of our publications or if you would like to share information with us about local history please e-mail us at <strong><a href="mailto:ewhurst.history@ukgateway.net" target="_top">ewhurst.history@ukgateway.net</a></strong></td>');
	document.write ('</tr></table>');

}