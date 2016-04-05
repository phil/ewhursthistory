if (!Mint.SI) { Mint.SI = new Object(); }
Mint.SI.Referrer = 
{
	onsave	: function() 
	{
		if (typeof Mint_SI_DocumentTitle=='undefined') { Mint_SI_DocumentTitle = document.title; }
		var referer		= (window.decodeURI)?window.decodeURI(document.referrer):document.referrer;
		var resource	= (window.decodeURI)?window.decodeURI(document.URL):document.URL;
		return '&referer=' + escape(referer) + '&resource=' + escape(resource) + '&resource_title=' + escape(Mint_SI_DocumentTitle);
	}
};
