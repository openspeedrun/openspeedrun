module frontend.common;
public import vibe.http.common;
public import vibe.http.server;

/**
    Returns the HTTPServerResponse reference from vibe

    This is a workaround to allow variable passing AND response writing (for cookies)
*/
ref HTTPServerResponse getResponse(ref HTTPServerRequest req, ref HTTPServerResponse res) {
    return res;
}