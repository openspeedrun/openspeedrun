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
module backend.game;
import db;
import vibe.data.serialization;
import vibe.data.bson;
import vibe.db.mongo.collection : QueryFlags;
import vibe.db.mongo.cursor : MongoCursor;
import std.algorithm.searching : canFind;

@trusted
class Game {
private:

public:
    /++
        Gets a game via id

        Returns null if game doesn't exist with specified id.
    +/
    static Game get(string gameId) {
        return DATABASE["speedrun.games"].findOne!Game(["_id": gameId]);
    }
    /++
        Search for games, returns a cursor looking at the games.
    +/
    static MongoCursor!Game search(string queryString, int page = 0, int countPerPage = 20, bool showUnapproved = false) {
        if (queryString == "" || queryString is null) return list(page, countPerPage);

        import query : bson;

        return DATABASE["speedrun.games"].find!Game(
            bson([
                "$and": bson([
                    bson(["$or": 
                        bson([
                            bson(["_id": bson(["$regex": bson(queryString)])]),
                            bson(["name": bson(["$regex": bson(queryString)])]),
                            bson(["description": bson(["$regex": bson(queryString)])
                        ])
                    ])]),
                    bson(["approved": bson(showUnapproved)])
                ])
            ]), 
            null, 
            QueryFlags.None, 
            page*countPerPage, 
            countPerPage);
    }

    static MongoCursor!Game list(int page = 0, int countPerPage = 20, bool showUnapproved = false) {
        import query : bson;
        return DATABASE["speedrun.games"].find!Game(
            (!showUnapproved) ? bson([
                "approved": bson(true)
            ]) : Bson.emptyObject,
            null, 
            QueryFlags.None, 
            page*countPerPage, 
            countPerPage);
    }

    /++
        ID of the game
    +/
    @name("_id")
    string id;

    /++
        Wether this game has been approved
    +/
    bool approved;

    /++
        Wether ingame time should be displayed.
    +/
    bool hasIngameTimer;

    /++
        Name of the game
    +/
    @name("name")
    string gameName;

    /++
        Description of game
    +/
    string description;

    /++
        The owner of the game on-site

        owner = admin but can't be demoted
    +/
    string owner;

    /++
        List of admins
    +/
    string[] admins;

    /++
        List of mods
    +/
    string[] mods;

    /++
        FullGame Categories
    +/
    string[] fgCategories;

    /++
        Individual Level Categories
    +/
    string[] ilCategories;

    /++
        Levels
    +/
    string[] levels;

    this() {}

    this(string id, string name, string description, string adminId) {
        this.id = id;
        this.gameName = name;
        this.description = description;
        this.approved = false;
        this.owner = adminId;
        DATABASE["speedrun.games"].insert(this);
    }

    /++
        Returns true if the user with specified id is the owner of the server
    +/
    bool isOwner(string userId) {
        return owner == userId;
    }

    /++
        Returns true if the user with specified id is an admin of the server
    +/
    bool isAdmin(string userId) {
        return admins.canFind(userId) || isOwner(userId);
    }

    /++
        Returns true if the user with specified id is an moderator of the server
    +/
    bool isMod(string userId) {
        return mods.canFind(userId) || isAdmin(userId);
    }

    /++
        Accept game
    +/
    void accept() {
        approved = true;
        update();
    }

    /++
        Revoke a game's accepted status
    +/
    void revoke() {
        approved = false;
        update();
    }

    /++
        Update the game instance in the DB
    +/
    void update() {
        DATABASE["speedrun.games"].update(["_id": id], this);
    }

    /++
        Delete game
    +/
    void deleteGame() {
        DATABASE["speedrun.games"].remove(["_id": id]);
        destroy(this);
    }
}