function onloadEventHandler()
{
	//Scripts to load at startup
}

function setCookie(sName,sValue)
{
	document.cookie = sName + "=" + escape(sValue);
}
function getCookie(sName)
{
	// cookies are separated by semicolons
  var aCookie = document.cookie.split("; ");
  for (var i=0; i < aCookie.length; i++)
  {
    // a name/value pair (a crumb) is separated by an equal sign
    var aCrumb = aCookie[i].split("=");
    if (sName == aCrumb[0]) 
      return unescape(aCrumb[1]);
  }

  // a cookie with the requested name does not exist
  return null;

}

window.onload = onloadEventHandler;