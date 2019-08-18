module frontend.auth;
import frontend.common;
import vibe.web.web;
import vibe.web.rest;
import vibe.http.common;
import vibe.http.server;
import session;
import backend.user;
import backend.registrations;
import vibe.utils.validation;
import config;

@path("/auth")
class AuthFE {
    @path("/register")
    @before!getToken("token")
    public void getRegister(string token, string username="", string email="", string redirectTo = "/", string tag = "") {
        string errorMsg = "";
        if (SESSIONS.isValid(token)) {
            redirect(redirectTo);
            return;
        }
        render!("auth/register.dt", token, redirectTo, tag, errorMsg, username, email);
    }

    @path("/verify/:key")
    @before!getToken("token")
    public void getVerify(string token, string _key) {
        if (SESSIONS.isValid(token)) {
            redirect("/");
            return;
        }
        if (Registration.verifyUser(_key)) redirect("/auth/login?tag=verifySuccess");
        else redirect("/auth/register");
    }

    @path("/login")
    @before!getToken("token")
    public void getLogin(string token, string redirectTo = "/", string tag = "") {
        if (SESSIONS.isValid(token)) {
            redirect(redirectTo);
            return;
        }
        render!("auth/login.dt", token, redirectTo, tag);
    }

    @path("/logout")
    @before!getToken("token")
    @after!destroyToken()
    public void getLogout(string token) {
        scope(exit) redirect("/");
        if (!SESSIONS.isValid(token)) return;

        SESSIONS.kill(token);
    }

    @path("/register")
    @before!getToken("token")
    @before!getResponse("res")
    public void postRegister(ref HTTPServerResponse res, string username, string email, string password, string passwordverify, string token, string redirectTo = "/", string tag = "") {

        // Just here so templates can compile
        string errorMsg = "";

        // if the registration fails show the registration page with the tag attached
        scope(failure) render!("auth/register.dt", token, redirectTo, tag, errorMsg, username, email);

        if (SESSIONS.isValid(token)) return;

        // Validate that the passwords match
        if (password != passwordverify) {
            tag = "pwNoMatch";
            render!("auth/register.dt", token, redirectTo, tag, errorMsg, username, email);
            return;
        }

        // Make sure passwords aren't too small
        if (password.length < CONFIG.auth.minPasswordLength) {
            tag = "pwTooSmall";
            render!("auth/register.dt", token, redirectTo, tag, errorMsg, username, email);
            return;
        }

        // Make sure passwords don't get too large
        if (password.length > CONFIG.auth.maxPasswordLength) {
            tag = "pwTooLarge";
            render!("auth/register.dt", token, redirectTo, tag, errorMsg, username, email);
            return;
        }

        // Validate that the username is usable
        if (!validateUserName(username, CONFIG.auth.minUsernameLength, CONFIG.auth.maxUsernameLength)) {
            tag = "usernameInvalid";
            render!("auth/register.dt", token, redirectTo, tag, errorMsg, username, email);
            return;
        }

        // Validate that the email address is somewhat realistic
        try {
            email = validateEmail(email, CONFIG.auth.maxEmailLength);
        } catch(Exception ex) {
            tag = "emailInvalid";
            errorMsg = ex.msg;
            render!("auth/register.dt", token, redirectTo, tag, errorMsg, username, email);
            return;
        }

        // Register the user
        try {
            User.register(username, email, password);
        } catch (Exception ex) {
            tag = "takenError";
            errorMsg = ex.msg;
            render!("auth/register.dt", token, redirectTo, tag, errorMsg, username, email);
            return;
        }

        // We're successfully registered!
        redirect("/auth/login?tag=regSuccess");
    }

    @path("/login")
    @before!getToken("token")
    @before!getResponse("res")
    public void postLogin(ref HTTPServerResponse res, string username, string password, string token, string redirectTo = "/", string tag = "") {

        // if the login fails show the login page with the tag attached
        scope(failure) render!("auth/login.dt", token, redirectTo, tag);

        // Otherwise redirect to the home page
        scope(success) redirect(redirectTo);
        
        if (SESSIONS.isValid(token)) return;
        
        

        // Get user instance, if user doesn't exist return status invalid
        User userPtr = User.get(username);
        if (userPtr is null) {
            tag = "loginIncorrect";
            throw new Exception("Incorrect username or password");
        }

        // Update and destroy old sessions
        SESSIONS.update();

        // Verify password
        if (!userPtr.auth.verify(password)) {
            tag = "loginIncorrect";
            throw new Exception("Incorrect username or password");
        }

        // If the user already has a running session just send that
        // Otherwise create a new session
        if (SESSIONS.findUser(username) !is null) {
             setToken(res, SESSIONS.findUser(username).token);
        }
        setToken(res, SESSIONS.createSession(practicallyInfinite(), username).token);
    }
}