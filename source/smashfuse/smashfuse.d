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

import vibe.data.json;
import std.stdio;
import std.net.curl;
import std.array;
import arsd.oauth;

class SmashFuseSettings {
	string configName = "global";
	URL siteUrl = URL.parse("http://localhost:9090/");
}

void registerSmashFuse(SmashFuseSettings settings, URLRouter router)
{
	new SmashFuse(settings, router);
}


class SmashFuse {
	private {
		string m_subPath;
		SmashFuseSettings m_settings;

		string[string] m_gibs;
	}

	this(SmashFuseSettings settings)
	{
		m_settings = settings;

		m_subPath = settings.siteUrl.path.toString();

		enforce(m_subPath.startsWith("/") && m_subPath.endsWith("/"), "All local URLs must start with and end with '/'.");
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
		writeln(jason);
		Json results = searchYoutube(jason.query.toString());
		res.writeJsonBody(results);
	}


	//
	// smashfuse functions
	//

	Json searchYoutube(string query)
	{
		auto client = HTTP();
		writeln(query);
		string prepped_query = query.replace(" ", "+");
		//query.split(" ")[0];
		writeln(prepped_query);
		string api_url = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=" ~ prepped_query ~ "&maxResults=15&key=AIzaSyBnFg3CxLu-SjZfSgILY2qFXzMZ7BBrPgM";
		Json content = parseJsonString(cast(string)get(api_url, client));
		//writeln(content);
		return content;
	}

	string searchTwitter(string query)
	{
		auto client = HTTP();
		string api_url = "https://api.twitter.com/1.1/search/tweets.json?result_type=recent&count=5&lang=en&q=" ~ query;
		//client.addRequestHeader("Authorization", "OAuth oauth_consumer_key='consumer_key', oauth_nonce='nonce'");
		client.addRequestHeader("X-Custom-ABC", "This is the custom value");
		client.onReceiveHeader =
			(in char[] key, in char[] value) { writeln(key ~ ": " ~ value); };
		string content = cast(string)get("dlang.org", client);
		//writeln(content);
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
		res.render!("search/frontpage.dt", req, query);
	}


}

