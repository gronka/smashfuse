import vibe.d;

import smashfuse.smashfuse;

shared static this()
{
	auto router = new URLRouter;

	auto smashsettings = new SmashFuseSettings;
	smashsettings.configName = "smashfuse";
	smashsettings.siteUrl = URL("http://127.0.0.1:8080/");
	registerSmashFuse(smashsettings, router);


	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	listenHTTP(settings, router);

	logInfo("Please open http://127.0.0.1:8080/ in your browser.");
}

//void hello(HTTPServerRequest req, HTTPServerResponse res)
//{
	//res.writeBody("Hello, World!");
//}
