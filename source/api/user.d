/+
    Copyright © Clipsey 2019
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
+/
module api.user;
import api.common;
import vibe.web.rest;
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
        Logs in user
    +/
    @method(HTTPMethod.POST)
    @path("/login/:username")
    @bodyParam("data")
    StatusT!Token login(string _username, AuthData data);

    /++
        Logs out user
    +/
    @method(HTTPMethod.POST)
    @path("/logout")
    @bodyParam("token")
    Status logout(Token token);

    /++
        Registers a new user

        DO NOTE: 
        A user is not the same as a runner.
        A user will be converted to a runner when they post their first run.
    +/
    @method(HTTPMethod.POST)
    @path("/register/:username")
    @bodyParam("data")
    Status register(string _username, RegData data);

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
        Endpoint changes user info
    +/
    @path("/update")
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
    StatusT!Token login(string username, AuthData data) {
        import std.stdio : writeln;

        // Get user instance, if user doesn't exist return status invalid
        User userPtr = User.get(username);
        if (userPtr is null) return StatusT!Token.error(StatusCode.StatusInvalid, AUTH_FAIL_MSG);

        // Update and destroy old sessions
        SESSIONS.update();

        // Verify password
        if (!userPtr.auth.verify(data.password)) return StatusT!Token.error(StatusCode.StatusDenied, AUTH_FAIL_MSG);

        // If the user already has a running session just send that
        // Otherwise create a new session
        if (SESSIONS.findUser(username) !is null) {
            return StatusT!Token(StatusCode.StatusOK, SESSIONS.findUser(username).token);
        }
        return StatusT!Token(StatusCode.StatusOK, SESSIONS.createSession(data.lifetime.lifetimeFromLong, username).token);
    }

    Status logout(Token token) {
        // Make sure the token is valid
        if (!SESSIONS.isValid(token)) 
            return Status(StatusCode.StatusInvalid);

        if (token in SESSIONS) {
            SESSIONS.kill(token);
        }
        return Status(StatusCode.StatusInvalid);
    }

    Status register(string username, RegData data) {
        try {
            User.register(username, data.email, data.password);
            return Status(StatusCode.StatusOK);
        } catch(Exception ex) {
            return Status.error(StatusCode.StatusOK, ex.msg);
        }
    }

    Status verify(string verifykey) {
        // TODO: verify auser
        return Status(StatusCode.StatusOK);
    }
}

@trusted
class UserEndpoint : IUserEndpoint {
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
