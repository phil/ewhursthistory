<?php
$redirect = false;
$redirectLocation = "";

switch($_SERVER["HTTP_HOST"]){
	case "www.whatisnext.co.uk":
		break;
		
	case "whatisnext.co.uk":
		break;
	
	case "www.ewhursthistory.com":
		$redirect = true;
		$redirectLocation = "http://www.ewhursthistory.com/v2/";
		break;
	case "ewhursthistory.com":
		$redirect = true;
		$redirectLocation = "http://www.ewhursthistory.com/v2/";
		break;
	
	default:
		break;
}

if ( $redirect == true )
{
	header("Location: $redirectLocation");
	echo "Laoding . . . $redirectLocation";
	exit();
}

?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html lang="en" xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
	<title>whatisnext.co.uk - an online portfolio for Phil Balchin</title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<meta name="description" content="whatisnext.co.uk is an online portfolio for Phil Balchin" />
	<meta name="keywords" content="whatisnext, What Is Next, Next Century Systems, Next, XHTML, HTML, XML, CSS" />

	<meta name="author" content="Phil Balchin" />
	<meta name="Copyright" content="Copyright (c) 2006 Next Century Systems" />

	<script src="/js/scripts.js" type="text/javascript"></script>
	
	<script src="/mint/?js" type="text/javascript"></script>

	<style type="text/css">

		body {
			background: #701304 none scroll no-repeat top;
		}

		#horizon {
			position: absolute;
			top: 50%;
			left: 0px;
			width: 100%;
			margin-top: -300px;
			text-align: center;
			min-width: 800px; 
		}
		
		#wrapper {
			position: relative;
			text-align: left;
			width: 800px;
			height: 600px;
			margin: 0px auto;
		}

		h1 {
			display: none;
		}

		h2 {
			display: none;
		}
		
		#site-nav {
			margin: 0px;
			padding: 0px;

			position: absolute;
			top: 368px;
			left: 600px;

			width: 130px;

			list-style: none;
		}
		#site-nav li {
			margin: 0px 0px 7px 0px;
			padding: 0px;

			width: 130px;
			height: 23px;
			line-height: 23px;

			list-style: none;
		}
		#site-nav li.clear {
			display: none;
		}
		
		#site-nav li a, #site-nav li a:link, #site-nav li a:visited {
			margin: 0px;
			padding: 0px;

			display: block;
			
			width: 130px;
			height: 23px;
			line-height: 23px;

			background-image: none;
			text-decoration: none;
		}
		#site-nav li a span {
			margin: 0px;
			padding: 0px;
			visibility: hidden;
		}

		#journal {
			background-image: url(img/rev-nav-journal.jpg);
		}
		#journal a:link, #journal a:visited {
		}
		#journal a:hover {
			background-image: url(img/rev-nav-journal-over.jpg) !important;
		}

		#work {
			background-image: url(img/rev-nav-work.jpg);
		}
		#work a:link, #work a:visited {
		}
		#work a:hover {
			background-image: url(img/rev-nav-work-over.jpg) !important;
		}

		#photographics {
			background-image: url(img/rev-nav-photographics.jpg);
		}
		#photographics a:link, #photographics a:visited {
		}
		#photographics a:hover {
			background-image: url(img/rev-nav-photographics-over.jpg) !important;
		}

		#desktops {
			background-image: url(img/rev-nav-desktops.jpg);
		}
		#desktops a:link, #desktops a:visited {
		}
		#desktops a:hover {
			background-image: url(img/rev-nav-desktops-over.jpg) !important;
		}

		#about {
			background-image: url(img/rev-nav-about.jpg);
		}
		#about a:link, #about a:visited {
		}
		#about a:hover {
			background-image: url(img/rev-nav-about-over.jpg) !important;
		}

		#contact {
			background-image: url(img/rev-nav-contact.jpg);
		}
		#contact a:link, #contact a:visited {
		}
		#contact a:hover {
			background-image: url(img/rev-nav-contact-over.jpg) !important;
		}
		
	</style>
	
</head>

<body id="body-home">
<div id="horizon">
<div id="wrapper" class="revolution">
  <h1>whatisnext.co.uk</h1>
  <h2>The Revolution will be Standardised</h2>

  <img src="img/rev-background.jpg" alt="The revolution will be standardised"/>

	<ul id="site-nav">
		<li id="journal"><a href="/journal/"><span>Journal</span></a></li>
		<li id="work"><a href="#"><span>Work</span></a></li>
		<li id="photographics"><a href="/photographics/"><span>Photographics</span></a></li>
		<li id="desktops"><a href="/projects/desktops/"><span>Desktops</span></a></li>
		<li id="about"><a href="/about/"><span>About</span></a></li>
		<li id="contact"><a href="/about/"><span>Contact</span></a></li>
		<li class="clear"></li>
	</ul>
  
</div>
</div>
</body>
</html>
