import vibe.d;

import smashfuse.smashfuse;

shared static this()
{
	import etc.linux.memoryerror;
	static if (is(typeof(registerMemoryErrorHandler)))
	registerMemoryErrorHandler();


	auto router = new URLRouter;

	auto smashsettings = new SmashFuseSettings;
	smashsettings.configName = "smashfuse";
	smashsettings.siteUrl = URL("http://127.0.0.1:9090/");
	registerSmashFuse(smashsettings, router);


	auto settings = new HTTPServerSettings;
	settings.port = 9090;
	listenHTTP(settings, router);

	logInfo("Hosting on http://127.0.0.1:9090/");
}

//void hello(HTTPServerRequest req, HTTPServerResponse res)
//{
	//res.writeBody("Hello, World!");
//}
