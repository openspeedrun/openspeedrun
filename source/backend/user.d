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
module backend.user;
import vibe.data.serialization;
import vibe.data.bson;
import std.algorithm;
import std.base64;
import session;
import db;
import crypt;
import std.range;
import std.algorithm;
import backend.common;

/++
    User authentication info
+/
struct UserAuth {
public:
    /++
        Salt of password
    +/
    string salt;

    /++
        Hash of password
    +/
    string hash;

    /++
        Create new userauth instance from password

        Gets hashed with scrypt.
    +/
    this(string password) {
        auto hashcomb = hashPassword(password);
        hash = Base64.encode(hashcomb.hash);
        salt = Base64.encode(hashcomb.salt);
    }

    /++
        Verify that the password is correct
    +/
    bool verify(string password) {
        return verifyPassword(password, Base64.decode(this.hash), Base64.decode(this.salt));
    }
}

/++
    The power level of a user
+/
enum Powers : ushort {
    Admin =   9001u,
    Mod =       42u,
    User =       1u,
    Banned =      0u
}

/++
    A user
+/
class User {
@trusted public:

    static User register(string username, string email, string password) {
        if (nameTaken(username)) throw new TakenException("name");
        if (emailTaken(email)) throw new TakenException("email");
        
        string properUsername = formatId(username);
        if (properUsername == "") throw new InvalidFmtException("username", ExpectedIDFmt);

        DATABASE["speedrun.users"].insert(new User(properUsername, email, UserAuth(password)));
        return User.get(username);
    }

    /++
        Returns true if a user exists.
    +/
    static bool exists(string username) {
        return DATABASE["speedrun.users"].count(["_id": username]) > 0;
    }

    /++
        Gets user from database

        returns null if no user was found
    +/
    static User get(string username) {
        return DATABASE["speedrun.users"].findOne!User(["_id": username]);
    }

    /++
        Gets wether the user is valid on the site

        Validity:
        * Is a user
        * Has verified their email
    +/
    static bool getValid(string username) {
        User user = get(username);
        if (user is null) return false;
        return user.verified;
    }

    /++
        Returns true if there's a user with specified username
    +/
    static bool nameTaken(string username) {
        return DATABASE["speedrun.users"].count(["_id": username]) > 0;
    }

    /++
        Returns true if there's a user with specified username
    +/
    static bool emailTaken(string email) {
        return DATABASE["speedrun.users"].count(["email": email]) > 0;
    }

    /++
        User's username (used during login)
    +/
    @name("_id")
    string username;

    /++
        User's email (used during registration and to send notifications, etc.)
    +/
    @name("email")
    string email;

    /++
        User's display name
    +/
    @name("display_name")
    string displayName;

    /++
        Wether the user has verified their email
    +/
    @name("verified")
    bool verified;

    /++
        The power level of a user

        THIS SHOULD ONLY BE CHANGED BY SITE ADMINS
    +/
    @name("power")
    @optional
    Powers power = Powers.User;

    /++
        User's authentication info
    +/
    @name("auth")
    UserAuth auth;

    /++
        For serialized instances
    +/
    this() { }

    /++
        User on account creation
    +/
    this(string username, string email, UserAuth auth) {
        this.username = username;
        this.email = email;
        this.displayName = username;
        this.verified = false;
        this.power = Powers.User;
        this.auth = auth;
    }

    /++
        Delete the user from the database
    +/
    void deleteUser() {
        DATABASE["speedrun.users"].remove(["_id": username]);
        destroy(this);
    }

    /++
        Returns true if social actions are permitted.

        Social actions are NOT permitted if the user has been social-banned.
    +/
    bool socialPermitted() {
        return power > Powers.Banned;
    }

    /++
        Bans a user.

        Set community to true for a community ban.
        Otherwise a total ban will be done.

        Returns true if successful, otherwise returns false.
    +/
    bool ban(bool community) {
        if (!exists(username)) return false;

        if (community) {
            power = Powers.Banned;
            update();
            return true;
        }
        this.deleteUser();
        return true;
    }

    /++
        Unbans a user

        Unban only works on community bans!

        Returns true if successful, otherwise returns false.
    +/
    bool unban() {
        if (!exists(username)) return false;
        User user = User.get(username);
        user.power = Powers.User;
        return true;
    }

    /++
        Applies changes to database.
    +/
    void update() {
        DATABASE["speedrun.users"].update(["_id": username], this);
    }
}

/++
    Frontend representation of a user.
+/
struct FEUser {

}
