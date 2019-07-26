module frontend.auth;
import frontend.common;
import vibe.web.web;
import vibe.web.rest;
import vibe.http.common;
import vibe.http.server;
import session;
import backend.user;

@path("/auth")
class AuthFE {
    
    @path("/login")
    @before!getToken("token")
    public void getLogin(string token) {
        if (SESSIONS.isValid(token)) {
            redirect("/");
            return;
        }
        render!("auth/login.dt", token);
    }

    @path("/logout")
    @before!getToken("token")
    @after!destroyToken()
    public void getLogout(string token) {
        scope(exit) redirect("/");
        if (!SESSIONS.isValid(token)) return;

        SESSIONS.kill(token);
    }

    @path("/login")
    @before!getToken("token")
    @before!getResponse("res")
    public void postLogin(ref HTTPServerResponse res, string username, string password, string token) {
        // Just exposing the variable to the template.
        bool failure = true;
        scope(failure) render!("auth/login.dt", token, failure);
        scope(success) redirect("/");
        
        if (SESSIONS.isValid(token)) return;
        
        

         // Get user instance, if user doesn't exist return status invalid
        User userPtr = User.get(username);
        if (userPtr is null) throw new Exception("AUTH_FAIL_MSG");

        // Update and destroy old sessions
        SESSIONS.update();

        // Verify password
        if (!userPtr.auth.verify(password)) throw new Exception("AUTH_FAIL_MSG");

        // If the user already has a running session just send that
        // Otherwise create a new session
        if (SESSIONS.findUser(username) !is null) {
             setToken(res, SESSIONS.findUser(username).token);
        }
        setToken(res, SESSIONS.createSession(practicallyInfinite(), username).token);
    }
}