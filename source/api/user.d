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
    Data used for authentication (logging in)
+/
struct AuthData {
    /// Password to log in with
    string password;

    /// Lifetime of the wanted session
    @optional
    long lifetime = 0;
}

/++
    Data used for registration
+/
struct RegData {
    /// Email for notifications, etc.
    string email;

    /// Password to log in with
    string password;

    /// Lifetime of the wanted session
    @optional
    long lifetime = 0;
}

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
    @path("/login")
    StatusT!Token login(string authToken);


    /++
        Logs in as user account
    +/
    @method(HTTPMethod.POST)
    @path("/login/:username")
    StatusT!Token login(string _username, string password);

    /++
        Verifies a new user allowing them to create/post runs, etc.
    +/
    @method(HTTPMethod.POST)
    @path("/verify")
    @bodyParam("verifykey")
    Status verify(string verifykey);

    /++
        Gets the status of a user's JWT token
    +/
    @method(HTTPMethod.POST)
    @path("/status")
    @before!getJWTToken("token")
    Status getUserStatus(JWTToken* token);
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
    StatusT!FEUser user(string _userId);

    /++
        Endpoint changes user info
    +/
    @path("/update")
    @method(HTTPMethod.GET)
    @before!getJWTToken("token")
    Status update(JWTToken* token, User data);

    /++
        === Moderator+ ===


    +/
    @path("/ban/:userId")
    @method(HTTPMethod.POST)
    @queryParam("community", "c")
    @before!getJWTToken("token")
    Status ban(JWTToken* token, string _userId, bool community = true);

    /++
        === Moderator+ ===
    +/
    @path("/pardon/:userId")
    @method(HTTPMethod.POST)
    @before!getJWTToken("token")
    Status pardon(JWTToken* token, string _userId);

    /++
        Removes user from database with token.

        DO NOTE:
        Verify with password!
    +/
    @path("/rmuser")
    @before!getJWTToken("token")
    Status rmuser(JWTToken* token, string password);

}

enum AUTH_FAIL_MSG = "Invalid username or password";

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
    StatusT!string login(string secret) {

        // Get user instance
        User userPtr = User.getFromSecret(secret);

        // If user doesn't exist, make error
        if (userPtr is null) return StatusT!Token.error(StatusCode.StatusInvalid, AUTH_FAIL_MSG);

        // If user hasn't verified their email (and such is turned on), make error
        if (CONFIG.auth.emailVerification && !userPtr.verified) return StatusT!Token.error(StatusCode.StatusInvalid, AUTH_FAIL_MSG);

        // Start new session via JWT token
        return StatusT!Token(StatusCode.StatusOK, createToken(userPtr));
    }

    /// Login (user)
    StatusT!string login(string username, string password) {

        // Get user instance
        User userPtr = User.get(username);

        // If user doesn't exist, make error
        if (userPtr is null) return StatusT!Token.error(StatusCode.StatusInvalid, AUTH_FAIL_MSG);

        // If user hasn't verified their email (and such is turned on), make error
        if (CONFIG.auth.emailVerification && !userPtr.verified) return StatusT!Token.error(StatusCode.StatusInvalid, AUTH_FAIL_MSG);

        // If the password isn't correct, make error
        //if (!userPtr.auth.verify(password)) return StatusT!Token.error(StatusCode.StatusInvalid, AUTH_FAIL_MSG);

        // Start new session via JWT token
        return StatusT!Token(StatusCode.StatusOK, createToken(userPtr));
    }

    /// Verify user
    Status verify(string verifykey) {
        return Status(Registration.verifyUser(verifykey) ? StatusCode.StatusOK : StatusCode.StatusDenied);
    }

    Status getUserStatus(JWTToken* token) {
        if (token is null) return Status(StatusCode.StatusDenied);
        return User.getValidFromJWT(token) ? Status(StatusCode.StatusOK) : Status(StatusCode.StatusInvalid);
    }
}

@trusted
class UserEndpoint : IUserEndpoint {
    StatusT!FEUser user(string userId) {
        User user = User.get(userId);
        if (user is null) {
            return StatusT!FEUser.error(StatusCode.StatusNotFound, "user not found!");
        }
        return StatusT!FEUser(StatusCode.StatusOK, user.getInfo());
    }

    Status update(JWTToken* token, User data) {
        if (token is null) return Status(StatusCode.StatusDenied);

        return Status(StatusCode.StatusOK);
    }

    Status ban(JWTToken* token, string _userId, bool community = true) {
        if (token is null) return Status(StatusCode.StatusDenied);

        // Make sure the user has the permissions neccesary
        if (!User.getValidFromJWT(token)) return Status(StatusCode.StatusInvalid);
        User user = User.getFromJWT(token);
        if (user.power < Powers.Mod) return Status(StatusCode.StatusDenied);

        User toBan = User.get(_userId);
        if (!user.canPerformActionOn(toBan)) return Status(StatusCode.StatusDenied);

        // Ban the user
        return Status(toBan.ban(community) ? StatusCode.StatusOK : StatusCode.StatusInvalid);
    }

    Status pardon(JWTToken* token, string _userId) {
        if (token is null) return Status(StatusCode.StatusDenied);

        // Make sure the user has the permissions neccesary
        if (!User.getValidFromJWT(token)) return Status(StatusCode.StatusInvalid);
        User user = User.getFromJWT(token);
        if (user.power < Powers.Mod) return Status(StatusCode.StatusDenied);

        User toPardon = User.get(_userId);
        if (!user.canPerformActionOn(toPardon)) return Status(StatusCode.StatusDenied);

        return Status(toPardon.unban() ? StatusCode.StatusOK : StatusCode.StatusInvalid);
    }


    Status rmuser(JWTToken* token, string password) {
        if (token is null) return Status(StatusCode.StatusDenied);

        return Status(StatusCode.StatusOK);
    }
}
