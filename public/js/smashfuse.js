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
	var div = document.createElement('div');
	var img = document.createElement('img');
	var title = document.createElement('h4');
	var a = document.createElement('a');
	var p = document.createElement('p');

	// assume the search engines have already sorted results by 
	// importance, so iterate through 
	// for...in does not preserve order

	div.className = "query-stream-item";
	div.setAttribute('data-sr', '');

	//img.src = "http://www.jqueryscript.net/images/Lightweight-Animated-Scroll-To-Top-Plugin-scrollUp.jpg";
	img.src = result.thumbnails.default.url;
	img.width = "150";
	//divheight = Math.floor((Math.random() * 200) + 200);
	//img.height = divheight;

	title.textContent = result.title;
	title.className = "qsi-title";
	p.textContent = result.description;
	p.className = "qsi-p";

	if (typeof(x) != "undefined") {
		a.href = "https://www.youtube.com/watch?v=" + result.id.videoId;
	} else {
		a.href = "https://www.youtube.com/watch?v=" + result.channelId;
	}
	a.textContent = "link";

	div.appendChild(img);
	div.appendChild(title);
	div.appendChild(p);
	div.appendChild(a);

	//TODO: unique border colors?
	// like, blue for facebook, red for pinterest, etc?

	el.appendChild(div);

}
function addResultsToStreamFromData(data, el) {
	//TODO: this code will change when we change the server response
	var results = data.items;
	for (var i = 0; i < results.length; i++) {
		var result = results[i].snippet;
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
	sources.youtube.active = !sources.youtube.active;
};
document.getElementById("filter-toggle-twitter").onclick = function() {
	sources.twitter.active = !sources.twitter.active;
};

function addQueryStreamItemTest() {
	genQueryStreamItemTest();
}
document.getElementById("add-query-stream-item").onclick = function() {
	addQueryStreamItemTest();
	window.sr = new scrollReveal();
};

// without debounce, clicking too rapidly will intterupt 
// creation of query-stream-items
document.getElementById("query-stream-refresh").onclick = debounce(function() {
	addQueryStreamItemTest();
	addQueryStreamItemTest();
	addQueryStreamItemTest();
	addQueryStreamItemTest();
	addQueryStreamItemTest();
	addQueryStreamItemTest();
	addQueryStreamItemTest();
		var oauth = new OAuth.OAuth(
				'https://api.twitter.com/oauth/request_token',
				'https://api.twitter.com/oauth/access_token',
				'fwnqoQLXJEgntvvMX3Q',
				'e7IZTDgcrlv0JJAXaMdsgo4gNcBreW1DuxQi3aFtM',
				'1.0A',
				null,
				'HMAC-SHA1'
		);
		alert(oauth);
	window.sr = new scrollReveal();
}, 400);

document.getElementById("query-stream-apply-filters").onclick = function() {
	addQueryStreamItemTest();
	window.sr = new scrollReveal();
};



$(function() {
	function refreshSearch(query, el) {
		$.ajax({
			url: '/json/refreshSearch',
			data: JSON.stringify({query: query}),
			success: function(data) {
				addResultsToStreamFromData(data, el);
			}
		});
	}

	document.getElementById("query-stream-apply-filters").onclick = function() {
		var el = document.getElementById('query-stream-block');
		var query = $('#query').html();
		refreshSearch(query, el);
		addQueryStreamItemTest();
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


		var query = $('#query').html();

		//var el = document.getElementById('query-stream-block');
		//refreshSearch(query, $('#query-stream-block'));
		var el = document.getElementById('query-stream-block');
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
	});

		var el = document.getElementById('query-stream-block');
		var query = $('#query').html();
		refreshSearch(query, $('#query-stream-block'));


});
