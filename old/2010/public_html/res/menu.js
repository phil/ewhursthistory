function JMenu(siteLevel, parent)
{
	//Properties
	this.SiteLevel = siteLevel;
	this.SiteLevelAsString = GetSiteLevelAsString(SiteLevel);
	this.ParentElement = parent;

	this.MenuItems = new Array();
	
	this.MenuItemHome = document.createElement("a");
		this.MenuItemHome.innerHTML = "Home";
		this.MenuItemHome.href      = this.SiteLevelAsString + "index.html";
	this.MenuItems[0] = this.MenuItemHome;

	//Ewhurst Publications From our Archives Research Other Sites 

	this.MenuItemEwhurst = document.createElement("a");
		this.MenuItemEwhurst.innerHTML = "About Ewhurst";
		this.MenuItemEwhurst.href      = this.SiteLevelAsString + "about/ewhurst.html";
	this.MenuItems[1] = this.MenuItemEwhurst;

	this.MenuItemNews = document.createElement("a");
		this.MenuItemNews.innerHTML = "News";
		this.MenuItemNews.href      = this.SiteLevelAsString + "news/index.html";
	this.MenuItems[2] = this.MenuItemNews;

	this.MenuItemPublications = document.createElement("a");
		this.MenuItemPublications.innerHTML = "Our Publications";
		this.MenuItemPublications.href      = this.SiteLevelAsString + "publications/index.html";
	this.MenuItems[3] = this.MenuItemPublications;

	this.MenuItemResearch = document.createElement("a");
		this.MenuItemResearch.innerHTML = "Research";
		this.MenuItemResearch.href      = this.SiteLevelAsString + "research/index.html";
	this.MenuItems[4] = this.MenuItemResearch;

	this.MenuItemAbout = document.createElement("a");
		this.MenuItemAbout.innerHTML = "About Us";
		this.MenuItemAbout.href      = this.SiteLevelAsString + "about/historysociety.html";
	this.MenuItems[5] = this.MenuItemAbout;

	// Methods

	this.Render = function()
	{	
		var MenuUL = document.createElement("ul");
		
		for ( i = 0; i < this.MenuItems.length; i++ )
		{
			var MenuLI = document.createElement("li");
				MenuLI.appendChild(this.MenuItems[i]);
			MenuUL.appendChild(MenuLI);
		}
		this.ParentElement.appendChild(MenuUL);
	}

	
}

function GetSiteLevelAsString(SiteLevel)
{
	var internal = "";
	if ( this.SiteLevel == 0 )
	{
		internal = "";
	}
	else
	{
		var i =  this.SiteLevel;
		for( var j=1; j <= i; j++)
		{
			internal += "../";
		}
	}
	return internal;
}