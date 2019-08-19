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
import vibe.data.serialization;
import session;

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
        Logs out user
    +/
    @method(HTTPMethod.POST)
    @path("/logout")
    @bodyParam("token")
    Status logout(Token token);

    /++
        Verifies a new user allowing them to create/post runs, etc.
    +/
    @method(HTTPMethod.POST)
    @path("/verify")
    @bodyParam("verifykey")
    Status verify(string verifykey);
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
    Status update(string token, User data);

    /++
        === Moderator+ ===


    +/
    @path("/ban/:userId")
    @method(HTTPMethod.POST)
    @bodyParam("token")
    @queryParam("community", "c")
    Status ban(string _userId, string token, bool community = true);

    /++
        === Moderator+ ===
    +/
    @path("/pardon/:userId")
    @method(HTTPMethod.POST)
    @bodyParam("token")
    Status pardon(string _userId, string token);

    /++
        Removes user from database with token.

        DO NOTE:
        Verify with password!
    +/
    @path("/rmuser")
    Status rmuser(string token, string password);

}

enum AUTH_FAIL_MSG = "Invalid username or password";

/++
    Implementation of auth endpoint
+/
@trusted
class AuthenticationEndpoint : IAuthenticationEndpoint {
    StatusT!Token login(string secret) {
        import std.stdio : writeln;

        // Get user instance, if user doesn't exist return status invalid
        User userPtr = User.getFromSecret(secret);
        if (userPtr is null) return StatusT!Token.error(StatusCode.StatusInvalid, AUTH_FAIL_MSG);

        // Update and destroy old sessions
        SESSIONS.update();

        // If the user already has a running session just send that
        // Otherwise create a new session
        return StatusT!Token(StatusCode.StatusOK, SESSIONS.createSession(practicallyInfinite(), userPtr.username).token);
    }

    Status logout(Token token) {
        // Make sure the token is valid
        if (!SESSIONS.isValid(token)) 
            return Status(StatusCode.StatusInvalid);

        if (token in SESSIONS) {
            SESSIONS.kill(token);
        }
        return Status(StatusCode.StatusOK);
    }

    Status verify(string verifykey) {
        // TODO: verify a user
        return Status(StatusCode.StatusOK);
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

    Status update(string token, User data) {
        // Make sure the token is valid
        if (!SESSIONS.isValid(token)) 
            return Status(StatusCode.StatusDenied);

        return Status(StatusCode.StatusOK);
    }

    Status ban(string _userId, string token, bool community = true) {
        // Make sure the token is valid
        if (!SESSIONS.isValid(token)) 
            return Status(StatusCode.StatusDenied);

        // Make sure the user has the permissions neccesary
        if (!User.getValid(SESSIONS[token].user)) return Status(StatusCode.StatusInvalid);
        User user = User.get(SESSIONS[token].user);
        if (user.power < Powers.Mod) 
            return Status(StatusCode.StatusDenied);

        // Ban the user
        return Status(user.ban(community) ? StatusCode.StatusOK : StatusCode.StatusInvalid);
    }

    Status pardon(string _userId, string token) {
        // Make sure the token is valid
        if (!SESSIONS.isValid(token)) 
            return Status(StatusCode.StatusDenied);

        // Make sure the user has the permissions neccesary
        if (!User.getValid(SESSIONS[token].user)) return Status(StatusCode.StatusInvalid);
        User user = User.get(SESSIONS[token].user);
        if (user.power < Powers.Mod) 
            return Status(StatusCode.StatusDenied);

        return Status(user.unban() ? StatusCode.StatusOK : StatusCode.StatusInvalid);
    }


    Status rmuser(string token, string password) {
        // Make sure the token is valid
        if (!SESSIONS.isValid(token)) 
            return Status(StatusCode.StatusDenied);

        return Status(StatusCode.StatusOK);
    }
}
