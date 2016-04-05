$(document).ready(function(){
  
  
  
});

function showPhotoDetails()
{
	$("div.details-text").slideDown("slow");
	$("a.show-details-trigger").fadeOut();
}

function hidePhotoDetails()
{
	$("div.details-text").slideUp("slow");
	$("a.show-details-trigger").fadeIn();
}