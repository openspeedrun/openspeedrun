/+
    Copyright © Clipsey 2019
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
+/
module api.user;
import api.common;
import vibe.web.rest;
import vibe.http.common;
import backend.user;
import backend.registrations;
import vibe.data.serialization;
import backend.auth.jwt;
import config;

/++
    Endpoint for user managment
+/
@path("/auth")
@trusted
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
    User endpoint for user settings
+/
@path("/users")
@trusted
interface IUserEndpoint {

    /++
        Gets user info
    +/
    @path("/:userId")
    @method(HTTPMethod.GET)
    FEUser user(string _userId);

    /++
        Endpoint changes user info
    +/
    @path("/update")
    @method(HTTPMethod.GET)
    @before!getJWTToken("token")
    string update(JWTToken* token, User data);

    /++
        === Moderator+ ===


    +/
    @path("/ban/:userId")
    @method(HTTPMethod.POST)
    @queryParam("community", "c")
    @before!getJWTToken("token")
    string ban(JWTToken* token, string _userId, bool community = true);

    /++
        === Moderator+ ===
    +/
    @path("/pardon/:userId")
    @method(HTTPMethod.POST)
    @before!getJWTToken("token")
    string pardon(JWTToken* token, string _userId);

    /++
        Removes user from database with token.

        DO NOTE:
        Verify with password!
    +/
    @path("/rmuser")
    @before!getJWTToken("token")
    string rmuser(JWTToken* token, string password);

}

enum AUTH_FAIL_MSG = "Invalid username or password";
enum AUTH_VER_FAIL_MSG = "This account hasn't been verified, please check your email. (Even the spam folder)";

/++
    Implementation of auth endpoint
+/
@trusted
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

@trusted
class UserEndpoint : IUserEndpoint {
    FEUser user(string userId) {
        User user = User.get(userId);
        if (user is null) throw new HTTPStatusException(404, "user not found!");
        return user.getInfo();
    }

    string update(JWTToken* token, User data) {
        if (token is null) throw new HTTPStatusException(HTTPStatus.unauthorized);

        return StatusCode.StatusOK;
    }

    string ban(JWTToken* token, string _userId, bool community = true) {
        if (token is null) throw new HTTPStatusException(HTTPStatus.unauthorized);

        // Make sure the user has the permissions neccesary
        if (!User.getValidFromJWT(token)) throw new HTTPStatusException(HTTPStatus.unauthorized);
        User user = User.getFromJWT(token);
        if (user.power < Powers.Mod) throw new HTTPStatusException(HTTPStatus.unauthorized);

        User toBan = User.get(_userId);
        if (!user.canPerformActionOn(toBan)) throw new HTTPStatusException(HTTPStatus.unauthorized);

        if (!toBan.ban(community)) throw new HTTPStatusException(HTTPStatus.internalServerError);

        // Ban the user
        return StatusCode.StatusOK;
    }

    string pardon(JWTToken* token, string _userId) {
        if (token is null) throw new HTTPStatusException(HTTPStatus.unauthorized);

        // Make sure the user has the permissions neccesary
        if (!User.getValidFromJWT(token)) throw new HTTPStatusException(HTTPStatus.unauthorized);
        User user = User.getFromJWT(token);
        if (user.power < Powers.Mod) throw new HTTPStatusException(HTTPStatus.unauthorized);

        // Get the user and try to perform the action
        User toPardon = User.get(_userId);
        if (!user.canPerformActionOn(toPardon)) throw new HTTPStatusException(HTTPStatus.unauthorized);
        if (!toPardon.unban()) throw new HTTPStatusException(HTTPStatus.internalServerError);

        return StatusCode.StatusOK;
    }


    string rmuser(JWTToken* token, string password) {
        if (token is null) throw new HTTPStatusException(HTTPStatus.unauthorized);

        return StatusCode.StatusOK;
    }
}
