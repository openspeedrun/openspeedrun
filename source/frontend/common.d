module frontend.common;
public import vibe.http.common;
public import vibe.http.server;

ref HTTPServerResponse getResponse(ref HTTPServerRequest req, ref HTTPServerResponse res) {
    return res;
}