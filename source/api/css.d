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
module api.css;
import vibe.web.rest;
import vibe.http.common;
import api.common;
import api.game;
import backend.user;
import backend.game;
import backend.css;
import backend.auth.jwt;

/++
    Custom user-set cssFighting twitter because it's a
+/


@path("/css")
interface ICSSEndpoint {
    /++
        Gets the user-set CSS.

        By default it will ONLY show approved css.

        User can decide to show pending css on their own discretion
    +/
    @method(HTTPMethod.GET)
    @path("/:gameId")
    string css(string _gameId, bool showPending = false);

    /++
        Sets the user-set CSS.
        
        Only admins of the game can set the CSS
    +/
    @method(HTTPMethod.POST)
    @path("/:gameId")
    @before!getJWTToken("token")
    Status setCSS(JWTToken* token, string _gameId, string data);

    /++
        === Moderator+ ===

        Approves the pending CSS for the specified game; if any

    +/
    @method(HTTPMethod.POST)
    @path("/accept/:gameId")
    @before!getJWTToken("token")
    Status acceptCSS(JWTToken* token, string _gameId);

    /++
        === Moderator+ ===

        Denies the pending CSS for the specified game; if any

        This WILL delete the CSS off the server.
    +/
    @method(HTTPMethod.POST)
    @path("/deny/:gameId")
    @before!getJWTToken("token")
    Status denyCSS(JWTToken* token, string _gameId);

    /++
        === Moderator+ ===

        Deletes ALL CSS from a game.

        This is a moderation functionality for use if approved CSS has been compromised (XSS)
    +/
    @method(HTTPMethod.POST)
    @path("/wipe/:gameId")
    @before!getJWTToken("token")
    Status wipeCSS(JWTToken* token, string _gameId);
}

class CSSEndpoint : ICSSEndpoint {
    string css(string _gameId, bool showPending = false) {
        // Make sure Game exists.
        if (Game.get(_gameId) is null) return StatusCode.StatusInvalid;

        // Get CSS and return string with CSS data.
        CSS css = CSS.get(_gameId);
        if (css is null) return "/* No custom CSS set! */";
        return showPending ? css.css : css.approvedCSS;
    }

    Status setCSS(JWTToken* token, string _gameId, string data) {
        import std.algorithm.searching : canFind;

        // Make sure the token is valid
        if (token is null) return Status(StatusCode.StatusDenied);

        // Make sue that the user is valid
        if (!User.getValidFromJWT(token)) return Status(StatusCode.StatusInvalid);
        User user = User.getFromJWT(token);

        // Make sure the game exists
        Game game = Game.get(_gameId);
        if (game is null) return Status(StatusCode.StatusInvalid);

        // Make sure the user is an admin of the game
        if (!game.isAdmin(user.username))
            return Status(StatusCode.StatusDenied);

        CSS css = CSS.get(_gameId);

        if (css !is null) {
            // Get already existing CSS and set the pending css to new value
            css.css = data;
            css.update();
            return Status(StatusCode.StatusOK);
        } else {

            // Create new CSS.
            new CSS(_gameId, data);
        }
        return Status(StatusCode.StatusOK);
    }

    Status acceptCSS(JWTToken* token, string _gameId) {
        if (token is null) return Status(StatusCode.StatusDenied);
        
        // Make sure the game exists
        if (Game.get(_gameId) is null) return Status(StatusCode.StatusInvalid);

        // Make sure the user has the permissions to accept the CSS
        if (!User.getValidFromJWT(token)) return Status(StatusCode.StatusInvalid);
        User user = User.getFromJWT(token);
        if (user.power < Powers.Mod) 
            return Status(StatusCode.StatusDenied);

        CSS css = CSS.get(_gameId);
        if (css is null) return Status(StatusCode.StatusNotFound);
        css.approve();

        return Status(StatusCode.StatusInvalid);
    }

    Status denyCSS(JWTToken* token, string _gameId) {
        if (token is null) return Status(StatusCode.StatusDenied);
        
        // Make sure the game exists
        if (Game.get(_gameId) is null) return Status(StatusCode.StatusInvalid);

        // Make sure the user has the permissions to accept the CSS
        if (!User.getValidFromJWT(token)) return Status(StatusCode.StatusInvalid);
        User user = User.getFromJWT(token);
        if (user.power < Powers.Mod) 
            return Status(StatusCode.StatusDenied);

        CSS css = CSS.get(_gameId);
        if (css is null) return Status(StatusCode.StatusNotFound);
        css.deny();

        return Status(StatusCode.StatusInvalid);
    }

    Status wipeCSS(JWTToken* token, string _gameId) {
        if (token is null) return Status(StatusCode.StatusDenied);
        
        // Make sure the game exists
        if (Game.get(_gameId) is null) return Status(StatusCode.StatusInvalid);

        // Make sure the user has the permissions to accept the CSS
        User user = User.getFromJWT(token);
        if (user.power < Powers.Mod) 
            return Status(StatusCode.StatusDenied);

        CSS.wipe(_gameId);

        return Status(StatusCode.StatusInvalid);
    }
}