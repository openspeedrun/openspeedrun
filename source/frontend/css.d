module frontend.css;
import vibe.web.web;
import vibe.http.server;
import vibe.web.rest;
import session;
import backend.css;
import std.algorithm.searching;

@path("/css")
class CSSFE {
@after!setCSSCType:

    @path("/:gameId")
    @before!getToken("token")
    public string getSafeCSS(string token, string _gameId) {
        string gameId = _gameId.endsWith(".css") ? _gameId[0..$-4] : _gameId;

        CSS css = CSS.get(gameId);
        return (css is null ? "/* No custom CSS set! */" : css.approvedCSS);
    }

    @path("/unsafe/:gameId")
    @before!getToken("token")
    public string getUnsafeCSS(string token, string _gameId) {
        string gameId = _gameId.endsWith(".css") ? _gameId[0..$-4] : _gameId;
        CSS css = CSS.get(gameId);
        return (css is null ? "/* No custom CSS set! */" : css.css);
    }
}

string setCSSCType(string data, HTTPServerRequest req, HTTPServerResponse res) {
    res.headers["Content-Type"] = "text/css";
    return data;
}