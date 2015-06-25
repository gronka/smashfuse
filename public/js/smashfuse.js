var c_QUERY = $('#query').html();
var sources = {
	all: {
		active: true
	},
	youtube: {
		active: true
	},
	twitter: {
		active: true
	}
};



function debounce(func, wait, immediate) {
	var timeout;
	return function() {
		var context = this, args = arguments
		clearTimeout(timeout);
		timeout = setTimeout(function() {
			timeout = null;
			if (!immediate) func.apply(context, args);
		}, wait);
		if (immediate && !timeout) func.apply(context, args);
	};
}

function genQueryStreamItem(result, el) {
	if (result.health == "dead") return;

	var div = document.createElement('div');
	var img = document.createElement('img');
	var title = document.createElement('h4');
	var a = document.createElement('a');
	var p = document.createElement('p');

	var imglink = document.createElement('a');
	var titlelink = document.createElement('a');

	var social = document.createElement("div");
	social.className = "qsi-social";
	var socialDirectLink = document.createElement("a");
	socialDirectLink.href = result.link;
	//socialDirectLink.textContent = "Direct";
	var socialDirectLinkImage = document.createElement("img");

	div.setAttribute('data-sr', '');
	title.className = "qsi-title";
	p.className = "qsi-p";
	img.src = result.thumbUrl;

	switch(result.source) {
		default:
			break;
		case "youtube":
			div.className = "query-stream-item query-stream-item-youtube";
			title.textContent = result.title;
			titlelink.href = result.link;
			titlelink.appendChild(title);

			p.textContent = result.description;

			a.href = result.link;
			a.textContent = "link";
			imglink.href = result.link;
			imglink.appendChild(img);

			socialDirectLink.className = "qsi-social-direct-link-youtube";
	socialDirectLinkImage.src = "https://www.youtube.com/yt/brand/media/image/yt-brand-flattype-2.png";
	socialDirectLink.appendChild(socialDirectLinkImage);

			div.appendChild(imglink);
			div.appendChild(titlelink);
			div.appendChild(p);
			//div.appendChild(a);
			break;
		case "twitter":
			div.className = "query-stream-item query-stream-item-twitter";
			title.textContent = result.poster;

			titlelink.href = result.posterLink;
			titlelink.appendChild(title);
			var descWords = result.description.split(" ");
			for (var i = 0; i < descWords.length; i++) {
				var word = descWords[i];
				if (word[0] == "#") {
					var hashlink = document.createElement("a");
					hashlink.href = "https://twitter.com/hashtag/" + word + "?src=hash";
					//alert(word);
				} else if (word[0] == "@") {
					//alert(word);
				}
			}

			//alert(descArray);
			p.textContent = result.description;

			a.href = result.link;
			a.textContent = "link";
			imglink.href = result.link;
			imglink.appendChild(img);
			socialDirectLink.className = "qsi-social-direct-link-twitter";
	socialDirectLinkImage.src = "https://g.twimg.com/dev/documentation/image/Twitter_logo_blue_48.png";
	socialDirectLink.appendChild(socialDirectLinkImage);
			//alert(result.);
			//
			if (result.thumbUrl != "none") {
				div.appendChild(imglink);
			}
			div.appendChild(titlelink);
			div.appendChild(p);
			//div.appendChild(a);
			break;

	}
	// fill social section
	social.appendChild(socialDirectLink);
	var socialShareText = document.createElement("p");
	socialShareText.textContent = "Share";
	socialShareText.className = "qsi-share-text";
	social.appendChild(socialShareText);
	var socialFacebookShareLink = document.createElement("a");
	socialFacebookShareLink.href = "https://www.facebook.com/sharer.php?u=http://smashfuse.com/search?q=" + c_QUERY + "&t=" + c_QUERY + " http://smashfuse.com";
	socialFacebookShareLink.className = "qsi-share-facebook";
	//socialFacebookShareLink.textContent = "facebook";
	var socialFacebookShareImage = document.createElement("img");
	socialFacebookShareImage.src = "/images/dcsns-light/facebook.png";
	socialFacebookShareLink.appendChild(socialFacebookShareImage);
	social.appendChild(socialFacebookShareLink);

	var socialTwitterShareLink = document.createElement("a");
	socialTwitterShareLink.className = "qsi-share-twitter";
	//socialTwitterShareLink.textContent = "twitter";
	socialTwitterShareLink.href = "https://twitter.com/share?via=SmashFuse&url=http://smashfuse.com/search?q=" + c_QUERY + "&text=" + c_QUERY;
	var socialTwitterShareImage = document.createElement("img");
	socialTwitterShareImage.src = "/images/dcsns-light/twitter.png";
	socialTwitterShareLink.appendChild(socialTwitterShareImage);

	social.appendChild(socialTwitterShareLink);

	var socialGooglePlusShareLink = document.createElement("a");
	socialGooglePlusShareLink.className = "qsi-share-google-plus";
	socialGooglePlusShareLink.href = "https://plus.google.com/share?url=http://smashfuse.com/search?q=" + c_QUERY;
	//socialGooglePlusShareLink.textContent = "G+";
	var socialGooglePlusShareImage = document.createElement("img");
	socialGooglePlusShareImage.src = "/images/dcsns-light/google.png";
	socialGooglePlusShareLink.appendChild(socialGooglePlusShareImage);
	social.appendChild(socialGooglePlusShareLink);

	div.appendChild(social);
	//TODO: unique border colors?
	// like, blue for facebook, red for pinterest, etc?
	el.appendChild(div);
}

function addResultsToStreamFromData(data, el) {
	//TODO: this code will change when we change the server response
	var results = data;
	results.sort(function(a, b) {
		if (a.descriptionHashed < b.descriptionHashed) return -1;
		if (a.descriptionHashed > b.descriptionHashed) return 1;
		return 0;
	})
	for (var i = 0; i < results.length; i++) {
		var result = results[i];
		genQueryStreamItem(result, el);
	}
	window.sr = new scrollReveal();
}

//params: query, element
function genQueryStreamItemTest() {
	var el = document.getElementById('query-stream-block');
	var div = document.createElement('div');
	div.className = "query-stream-item";
	div.setAttribute('data-sr', '');

	var img = document.createElement('img');
	img.src = "http://www.jqueryscript.net/images/Lightweight-Animated-Scroll-To-Top-Plugin-scrollUp.jpg";
	img.width = "150";
	//divheight = Math.floor((Math.random() * 200) + 200);
	//img.height = divheight;

	var title = document.createElement('h4');
	title.textContent = "Example result";
	title.className = "qsi-title";

	var a = document.createElement('a');
	a.href = "https://google.com";
	a.textContent = "link";

	div.appendChild(img);
	div.appendChild(title);
	div.appendChild(a);

	//TODO: unique border colors?
	// like, blue for facebook, red for pinterest, etc?

	el.appendChild(div);


}

document.getElementById("filter-toggle-youtube").onclick = function() {
	// TODO: hide function
	sources.youtube.active = !sources.youtube.active;
	if (sources.youtube.active === true) {
		this.style.color = "green";
		var resultItems = document.getElementsByClassName("query-stream-item-youtube");
		for (var i=0, item; item = resultItems[i]; i++){
			item.style.visibility = "visible";
		}
	} else if (sources.youtube.active === false) {
		this.style.color = "red";
		var resultItems = document.getElementsByClassName("query-stream-item-youtube");
		for (var i=0, item; item = resultItems[i]; i++){
			item.style.visibility = "hidden";
			item.style.zindex = "5";
			//item.style.backgroundColor = "red";
		}
	}
	window.sr = new scrollReveal();
};
document.getElementById("filter-toggle-twitter").onclick = function() {
	// TODO: hide function
	sources.twitter.active = !sources.twitter.active;
	if (sources.twitter.active === true) {
		this.style.color = "green";
	} else if (sources.twitter.active === false) {
		this.style.color = "red";
	}
};

function addQueryStreamItemTest() {
	genQueryStreamItemTest();
}
// without debounce, clicking too rapidly will intterupt 
// creation of query-stream-items

//document.getElementById("query-stream-apply-filters").onclick = function() {
	//addQueryStreamItemTest();
	//window.sr = new scrollReveal();
//};



$(function() {
	function refreshSearch(query, el) {
		//TODO:
		//always get all sources, then hide and show?
		//or select sources before querying? probably the former...
		var sourceGet = [];
		if (sources.youtube.active === true) {
			sourceGet.push("youtube");
		}
		if (sources.twitter.active === true) {
			sourceGet.push("twitter");
		}
		$.ajax({
			url: '/json/refreshSearch',
			data: JSON.stringify({query: query,
													  sources: sourceGet
													  }),
			success: function(data) {
				addResultsToStreamFromData(data, el);
			}
		});
	}

	document.getElementById("query-stream-waypoint-button").onclick = function() {
		refreshSearch($('#query').html(), document.getElementById('query-stream-block'));
	};




	// cache the window object
	$window = $(window);

	$('section[data-type="background"]').each(function(){
	 // declare the variable to affect the defined data-type
	 var $scroll = $(this);
									 
		$(window).scroll(function() {
			// HTML5 proves useful for helping with creating JS functions!
			// also, negative value because we're scrolling upwards                             
			var yPos = -($window.scrollTop() / $scroll.data('speed')); 
			 
			// background position
			var coords = '50% '+ yPos + 'px';

			// move the background
			$scroll.css({ backgroundPosition: coords });    
		}); // end window scroll
	});  // end section function



		//var el = document.getElementById('query-stream-block');
		//refreshSearch(query, $('#query-stream-block'));
		//var el = document.getElementById('query-stream-block');
		//refreshSearch(query, $('#query-stream-block'));

	$(window).bind("load", function() {
		$.ajaxSetup({
			type: 'POST',
			dataType: 'json',
			//xhrFields: with credentials
			async: true,
			contentType: 'application/json; charset=utf-8',
			error: function() {
				alert("An error occurred.");
			}
		});


		//var waypoint = new Waypoint({
			//element: document.getElementById('query-stream-waypoint'),
			//handler: function(direction) {
				//if (direction == "down") {
					//refreshSearch($('#query').html(), document.getElementById('query-stream-block'));
				//}
				////alert(direction);
			//}, 
			//offset: 'bottom-in-view'
			////offset: '80%'
		//})

		refreshSearch($('#query').html(), document.getElementById('query-stream-block'));
	});


});
