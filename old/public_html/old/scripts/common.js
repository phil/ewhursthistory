function AttachOpenBehaviourToLinks()
{
	aElements = document.getElementsByTagName("a");
	
	for ( i = 0; i < aElements.length; i++ )
	{
		if ( aElements[i].rel.toLowerCase() == "external" )
		{
			aElements[i].target = "_blank";
		}
	}
}

function LoadPage()
{
	AttachOpenBehaviourToLinks();	
}
window.onload = LoadPage;
