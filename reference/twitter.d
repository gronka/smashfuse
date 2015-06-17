import std.net.curl;
import std.uri;

pragma(lib, "curl");

/*
	To get a bearer token, just run this from your command line:

	curl https://api.twitter.com/oauth2/token -d grant_type=client_credentials -u YOUR_CONSUMER_KEY:YOUR_CONSUMER_SECRET

	and it will spit out the json. Extract the token from there and set it here.

	You can get your consumer key and secret from https://apps.twitter.com/

	BTW Your code also looked ok for doing this automatically, you just need to change the URL so like.

    auto client = HTTP("https://api.twitter.com/oauth2/token";
    client.addRequestHeader("Authorization", "Basic your_value_here");
    client.postData("grant_type=client_credentials");
    client.perform();

        and I think it would work.
*/

enum bearer_token = "get from curl or other code";

void main() {
    auto client = HTTP("https://api.twitter.com/1.1/search/tweets.json?q=" ~ std.uri.encodeComponent("#dlang")); // searching for #dlang...

    client.addRequestHeader("Authorization", "Bearer " ~ bearer_token);

    string got = "";

    client.onReceive = (ubyte[] data) {
        got ~= cast(char[]) data; // just store it all in a string to print out...
	return data.length;
    };

    client.perform();

    // when perform returns, this should be done so we will print what we got:

    import std.stdio;
    writeln(got); // should spit out a lot of tweet json! otherwise you'll get an error, ask me if you need help.
}
