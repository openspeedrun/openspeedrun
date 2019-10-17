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
import backend.user;
import config;


/++
    User endpoint for user settings
+/
@path("/users")
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

class UserEndpoint : IUserEndpoint {
public:
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
