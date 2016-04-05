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

$HeadTitle = "";
$HeadDescription = "";
$HeadKeywords = "";

include($_SERVER['DOCUMENT_ROOT'] . "/ssi/htmlhead.php");

?>
<body id="body-home">

<? include($_SERVER['DOCUMENT_ROOT'] . "/ssi/skiptocontent.php") ?>
  
<div id="content-wrapper" class="section-wrapper">
  <div id="content" class="section">
    <div id="feature-link"><a id="feature-link-newclearsun" class="full-link" href="/index.php"><span>The New Clear Sun</span></a></div>
  </div>
</div> 

<div id="launcher-wrapper" class="section-wrapper">
  <div id="launcher" class="section">
    <div id="launcher-home" class="launcher-item">
      <h2><a class="launcher-link" href="/index.php"><span>whatisnext.co.uk</span></a></h2>
      <p>Whatisnext.co.uk is the online portfolio for Next Century Systems, a small web development and design company from the Surrey Hills</p>
      <p>t: +44 01483 277342</p>
      <p>e: info@whatisnext.co.uk</p>
      <p>Hullbrook Cottage<br />
      Cranleigh Road<br />
      Ewhurst<br />
      Surrey. GU6 7RN<br />
      UK</p>
      <p class="more-information"><a href="/about/">More</a></p>
    </div>

    <div id="launcher-work" class="launcher-item">
      <h2><a class="launcher-link" href="/work/"><span>Work</span></a></h2>
      <ul>
        <li><a href="#"><span>AKG</span></a></li>
        <li><a href="#"><span>Ewhurst History Society</span></a></li>
      </ul>
    </div>

    <div id="launcher-projects"  class="launcher-item">
      <h2><a class="launcher-link" href="/projects/"><span>Projects</span></a></h2>
      <ul>
        <li><a href="/projects/desktops/"><span>Desktops</span></a></li>
      </ul>
    </div>

    <div id="launcher-journal"  class="launcher-item">
      <h2><a class="launcher-link" href="/journal/"><span>Journal</span></a></h2>
      <? include($_SERVER['DOCUMENT_ROOT'] . "/journal/archive-top5.php") ?>
    </div>

  </div>
  
  <div class="section-end"></div>
  
</div>
</body>
</html>
