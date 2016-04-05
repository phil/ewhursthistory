
function LoadPageIndex(PageNavigationElement)
{
	var H2 = document.getElementsByTagName("h2");
	var ContainsLinks = false;

	var thisDL = document.createElement("dl");
	var thisDT = document.createElement("dt");
	var thisH3 = document.createElement("h3");
		thisH3.innerHTML = "Table of Contents";
	thisDT.appendChild(thisH3);
	thisDL.appendChild(thisDT);
	
	for ( i=0; i< H2.length; i++)
	{
		var thisDD = document.createElement("dd");
		if ( H2[i].childNodes[0] )
		{
			switch ( H2[i].childNodes[0].tagName )
			{
				case "A":
					thisA = document.createElement("a");
						thisA.href = "#" + H2[i].childNodes[0].name;
						thisA.innerHTML = H2[i].childNodes[0].innerHTML;
					thisDD.appendChild(thisA);
					var ContainsLinks = true;
					break;
				case "a":
					thisA = document.createElement("a");
						thisA.href = "#" + H2[i].childNodes[0].name;
						thisA.innerText = H2[i].childNodes[0].innerHTML;
					thisDD.appendChild(thisA);
					var ContainsLinks = true;
					break;

				default:
					thisDD.innerHTML = H2[i].innerHTML;
					var ContainsLinks = true;
					break;
			}
			
		}
		else
		{
			thisDD.innerHTML = H2[i].innerHTML;
		}
		thisDL.appendChild(thisDD);
	}

	
	if ( ContainsLinks )
	{
		PageNavigationElement.appendChild(thisDL);
	}
}

function LoadPageExternalLinks(PageNavigationElement)
{
	var aLinks = document.getElementsByTagName("a");
	var ContainsLinks = false;

	var thisDL = document.createElement("dl");
	var thisDT = document.createElement("dt");
	var thisH3 = document.createElement("h3");
		thisH3.innerHTML = "External Links";
	thisDT.appendChild(thisH3);
	thisDL.appendChild(thisDT);
	
	for ( i=0; i< aLinks.length; i++)
	{
		var thisDD = document.createElement("dd");
		if ( aLinks[i].getAttribute("rel") == "external")
		{
			
			var thisA = document.createElement("a");
			thisA.href = aLinks[i].href;
			thisA.rel = "externalx";
			thisA.innerHTML = aLinks[i].innerHTML;

			thisDD.appendChild(thisA);

			thisDL.appendChild(thisDD);
			ContainsLinks = true;
		}

		
	}

	if ( ContainsLinks )
	{
		PageNavigationElement.appendChild(thisDL);
	}
}

