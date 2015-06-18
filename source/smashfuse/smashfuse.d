module smashfuse.smashfuse;

import vibe.core.log;
import vibe.crypto.passwordhash;
import vibe.db.mongo.connection;
import vibe.http.auth.basic_auth;
import vibe.http.fileserver;
import vibe.http.router;
import vibe.inet.url;
import vibe.templ.diet;
import vibe.textfilter.markdown;

import std.conv;
import std.datetime;
import std.exception;
import std.string;

import std.stdio;
import std.net.curl;
import std.array;

import arsd.oauth;
import arsd.cgi;
import arsd.sha;
import arsd.curl;

import std.variant;
import std.array;
import std.digest.md;
import std.uri;

import vibe.data.json;
import std.json;

class SmashFuseSettings {
	string configName = "global";
	URL siteUrl = URL.parse("http://localhost:9090/");

	string smf_twitterApiKey = "FFJHHyCdDhQi8HCJvwErdIhBd";
	string smf_twitterApiSecret = "6R1uq1tSJrkWDcBZWq3nmYQLwSBB2C7qoUJVe1FGFypYxZvpv1";
	string smf_twitterOAuthToken = "631822296-OH8npjFx5jkHbAoiZR7YxOI5xpyRvyKavYsYlQQc";
	string smf_twitterOAuthTokenSecret = "9PT1zPyWWH6nisXloNfoRf3Bg3WvneX3xJhV3Zt6XQjU4";
	string smf_twitterBearer = "AAAAAAAAAAAAAAAAAAAAAK%2BIgAAAAAAA5HTLzOCqevKdhZdrGprIDxn6S2g%3DHfLNey6HuA26dffZ2FXJn23Q0NxihCh7XHahs4Z1AM15oitXsy";
}

void registerSmashFuse(SmashFuseSettings settings, URLRouter router)
{
	new SmashFuse(settings, router);
}


class SmashFuse {
	private {
		string m_subPath;
		SmashFuseSettings m_settings;
		string smf_twitterApiKey;
		string smf_twitterApiSecret;
		OAuthParams smf_twitterParams;
		string smf_twitterOAuthToken;
		string smf_twitterOAuthTokenSecret;
		string smf_twitterBearer;
		auto m_md5 = new MD5Digest();

		string[string] m_gibs;
	}

	this(SmashFuseSettings settings)
	{
		m_settings = settings;
		m_subPath = settings.siteUrl.path.toString();
		enforce(m_subPath.startsWith("/") && m_subPath.endsWith("/"), "All local URLs must start with and end with '/'.");

		smf_twitterApiKey = settings.smf_twitterApiKey;
		smf_twitterApiSecret = settings.smf_twitterApiSecret;

		OAuthParams smf_twitterParams = twitter(smf_twitterApiKey, smf_twitterApiSecret);

		smf_twitterOAuthToken = settings.smf_twitterOAuthToken;
		smf_twitterOAuthTokenSecret = settings.smf_twitterOAuthTokenSecret;
		smf_twitterBearer = settings.smf_twitterBearer;
	}

	this(SmashFuseSettings settings, URLRouter router)
	{
		this(settings);
		register(router);
	}

	void register(URLRouter router)
	{


		//
		// public pages
		//
		if( m_subPath.length > 1 ) router.get(m_subPath[0 .. $-1], staticRedirect(m_subPath));
		//
		// json requests
		//
		router.post(m_subPath ~ "json/refreshSearch", &jsonRefreshSearch);


		router.get(m_subPath, &frontpage);
		router.post(m_subPath ~ "search", &frontpageSearch);
		router.get(m_subPath ~ "search", &frontpageSearch);

		auto fsettings = new HTTPFileServerSettings;
		fsettings.serverPathPrefix = m_subPath;
		router.get(m_subPath ~ "*", serveStaticFiles("public", fsettings));

	}




	//
	// json
	//

	protected void jsonRefreshSearch(HTTPServerRequest req, HTTPServerResponse res)
	{
		Json jason = req.json;
		string query = jason.query.toString();
		Json sources = jason.sources.toString();
		writeln(query);
		writeln(sources);
		Json results = "";
		auto temp = cast(string)sources;
		auto sourceList = temp.split("\"");
		//writeln(sourceList);

		ResultItem[] resultsUnsorted;

		// contact API's
		foreach (source; sourceList) {
			switch(source)
			{
				case "[":
				case "]":
				case ", ":
				default:
					writeln("case default");
					break;
				case "youtube":
					//writeln("case youtube");
					resultsUnsorted ~= searchYoutube(query);
					break;
				case "twitter":
					//writeln("case twitter");
					resultsUnsorted ~= searchTwitter(query);
					break;

			}
		}


		//writeln(resultsUnsorted);
		results = serializeToJson(resultsUnsorted);
		//writeln(results);
		//Json results = searchYoutube(jason.query.toString());
		//writeln(c_twitterApiKey);
		//Json results = searchTwitter(query);
		res.writeJsonBody(results);
	}


	//
	// smashfuse functions
	//

	ResultItem[] searchTwitter(string query) {
		//string api_url = "https://api.twitter.com/1.1/application/rate_limit_status.json";
		// for getting bearer token
		//auto client = HTTP("https://api.twitter.com/oauth2/token");
		//client.addRequestHeader("Authorization", "Basic ");
		//client.postData("grant_type=client_credentials");
		string api_url = "https://api.twitter.com/1.1/search/tweets.json?result_type=recent&count=8&lang=en&q=" ~ std.uri.encodeComponent(query);
		auto client = HTTP(api_url);
		client.addRequestHeader("Authorization", "Bearer " ~ smf_twitterBearer);
		string got = "";
		client.onReceive = (ubyte[] data) {
			got ~= cast(char[]) data;
			return data.length;
		};
		client.perform();
		Json content = parseJsonString(got);
		//writeln(content);
		ResultItem[] results;
		foreach(item; content.statuses) {
			try {
				foreach (string key, value; item) {
					writefln("%s: %s", key, value);
				}
				ResultItem newItem;
				newItem.title = "none";
				try {
					newItem.thumbUrl = cast(string)item.entities.media[0].media_url_https ~ ":small";
				} catch {
					try {
						newItem.thumbUrl = cast(string)item.user.profile_banner_url ~ "/mobile";
					} catch{
						try {
							newItem.thumbUrl = replace(cast(string)item.user.profile_image_url_https, "normal", "400x400");
						}
						catch {
							newItem.thumbUrl = "none";
						}
					}
				}
				newItem.poster = cast(string)item.user.screen_name;
				newItem.posterLink = "https://twitter.com/" ~ cast(string)item.user.screen_name;
				newItem.link = "https://twitter.com/" ~ cast(string)newItem.poster ~ "/status/" ~ cast(string)item.id_str;
				newItem.source = "twitter";

				//auto text = cast(string)item.text;
				//string[] wordArray = text.split(" ");
				//for (int i = 0; i < wordArray.length; i++) {
					//if (wordArray[i][0] == '#'){
						//string target = wordArray[i][1..$];
						//wordArray.insertInPlace(i, "<a href=\"https://twitter.com/hashtag/" ~ target ~ "\">");
						//wordArray.insertInPlace(i+2, "</a>");
						//i += 2;
					//} else if (wordArray[i][0] == '@') {
						//string target = wordArray[i][1..$];
						//wordArray.insertInPlace(i, "<a href=\"https://twitter.com/" ~ target ~ "\">");
						//wordArray.insertInPlace(i+2, "</a>");
						//i += 2;
					////} else if (wordArray[i][0..3] == "http"){
						////TODO: take entities.urls list to find urls in the string and 
						//// add links around them
						////writeln(wordArray[i]);
					//}
				//}
				//writeln(wordArray);
				//newItem.description = wordArray.join(" ");

				newItem.description = cast(string)item.text;
				newItem.descriptionHashed = toHexString(m_md5.digest(newItem.description));

				results ~= newItem;
			} catch {
				ResultItem newItem;
				newItem.health = "dead";
			}
		}

		return results;
	}

	ResultItem[] searchYoutube(string query) { 
			//foreach (string key, value; item) {
				//writefln("%s: %s", key, value);
			//}
		auto client = HTTP();
		string prepped_query = std.uri.encodeComponent(query.replace(" ", "+"));
		string api_url = "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=8&key=AIzaSyBnFg3CxLu-SjZfSgILY2qFXzMZ7BBrPgM&q=" ~ prepped_query;
		Json content = parseJsonString(cast(string)get(api_url, client));
		ResultItem[] results;
		foreach (item; content.items) { 
			try {
				ResultItem newItem;
				//writeln(item);
				newItem.title = cast(string)item.snippet.title;
				newItem.poster = cast(string)item.snippet.channelTitle;
				//newItem.thumbUrl = cast(string)item.snippet.thumbnails.default.url;
				newItem.thumbUrl = cast(string)item.snippet.thumbnails.medium.url;
				newItem.source = "youtube";

				try {
					newItem.link = "https://www.youtube.com/watch?v=" ~ cast(string)item.id.videoId;
				} catch {
					try {
						newItem.link = "https://www.youtube.com/channel/" ~ cast(string)item.id.channelId;
					}
					catch {
						newItem.link = "none";
					}
				}

				newItem.description = cast(string)item.snippet.description;
				newItem.descriptionHashed = toHexString(m_md5.digest(newItem.description));

				results ~= newItem;
			} catch {
				ResultItem newItem;
				newItem.health = "dead";
			}
		}

		return results;
	}


	Json JSONFACTORY(Json content, string source) {
		switch(source)
		{
			default:
			case "youtube":
				break;
		}
		return content;
	}

	//
	// public pages
	//

	protected void frontpage(HTTPServerRequest req, HTTPServerResponse res)
	{
		res.render!("landing/frontpage.dt", req);
	}

	protected void frontpageSearch(HTTPServerRequest req, HTTPServerResponse res)
	{
		string query = req.query["q"];
		//string results = searchTwitter(query);
		//Json ytresults = searchYoutube(query);
		//Json results = searchTwitter(smf_twitterParams, smf_twitterOAuthToken, smf_twitterOAuthTokenSecret, query);
		searchTwitter(query);
		res.render!("search/frontpage.dt", req, query);
	}


}


struct ResultItem {
	string health;
	string thumbUrl;
	string title;
	string description;
	string link;
	string posterLink;
	string refLink;
	string source;
	string poster;
	//ubyte[16] descriptionHashed;
	string descriptionHashed;
	//string sortVal;
}
