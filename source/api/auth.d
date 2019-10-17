module api.auth;
import backend.registrations;
import api.common;
import backend.user;
import config;

enum AUTH_FAIL_MSG = "Invalid username or password";
enum AUTH_VER_FAIL_MSG = "This account hasn't been verified, please check your email. (Even the spam folder)";

/++
    Endpoint for user managment
+/
@path("/auth")
interface IAuthenticationEndpoint {

    /++
        Logs in as bot account
    +/
    @method(HTTPMethod.POST)
    @path("/login/bot")
    Token login(string authToken);


    /++
        Logs in as user account
    +/
    @method(HTTPMethod.POST)
    @path("/login/user")
    @bodyParam("username", "username")
    @bodyParam("password", "password")
    Token login(string username, string password);

    /++
        Verifies a new user allowing them to create/post runs, etc.
    +/
    @method(HTTPMethod.POST)
    @path("/verify")
    @bodyParam("verifykey")
    string verify(string verifykey);

    /++
        Gets the status of a user's JWT token
    +/
    @method(HTTPMethod.POST)
    @path("/status")
    @before!getJWTToken("token")
    string getUserStatus(JWTToken* token);


    /++
        Gets the rechapta site key.
    +/
    @path("/siteKey")
    @method(HTTPMethod.GET)
    string siteKey();
}

/++
    Implementation of auth endpoint
+/
class AuthenticationEndpoint : IAuthenticationEndpoint {
private:
    string createToken(User user) {
        import vibe.data.json : serializeToJson, Json;
        JWTToken token;
        token.header.algorithm = JWTAlgorithm.HS512;
        token.payload = Json.emptyObject();
        token.payload["username"] = user.username;
        token.payload["power"] = user.power;
        token.payload["pronouns"] = serializeToJson(user.pronouns);

        // TODO: Make token expire.

        token.sign();

        return token.toString();
    }

public:
    /// Login (bot)
    Token login(string secret) {

        // Get user instance
        User userPtr = User.getFromSecret(secret);

        // If user doesn't exist, make error
        if (userPtr is null) throw new HTTPStatusException(404, AUTH_FAIL_MSG);

        // If user hasn't verified their email (and such is turned on), make error
        if (CONFIG.auth.emailVerification && !userPtr.verified) throw new HTTPStatusException(400, AUTH_VER_FAIL_MSG);

        // Start new session via JWT token
        return createToken(userPtr);
    }

    /// Login (user)
    Token login(string username, string password) {

        // Get user instance
        User userPtr = User.get(username);

        // If user doesn't exist, make error
        if (userPtr is null) throw new HTTPStatusException(HTTPStatus.unauthorized, AUTH_FAIL_MSG);

        // If user hasn't verified their email (and such is turned on), make error
        if (CONFIG.auth.emailVerification && !userPtr.verified) throw new HTTPStatusException(HTTPStatus.internalServerError, AUTH_VER_FAIL_MSG);

        // If the password isn't correct, make error
        //if (!userPtr.auth.verify(password)) throw new HTTPStatusException(HTTPStatus.unauthorized, AUTH_FAIL_MSG);

        // Start new session via JWT token
        return createToken(userPtr);
    }

    string siteKey() {
        return CONFIG.auth.recaptchaSiteKey;
    }

    /// Verify user
    string verify(string verifykey) {
        if (Registration.verifyUser(verifykey)) return StatusCode.StatusOK;
        throw new HTTPStatusException(HTTPStatus.unauthorized);
    }

    string getUserStatus(JWTToken* token) {
        if (token is null) throw new HTTPStatusException(HTTPStatus.unauthorized);
        return User.getValidFromJWT(token) ? StatusCode.StatusOK : StatusCode.StatusInvalid;
    }
}