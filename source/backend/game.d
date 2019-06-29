module backend.game;
import db;
import vibe.db.mongo.collection : QueryFlags;
import vibe.db.mongo.cursor : MongoCursor;
import std.algorithm.searching : canFind;
import vibe.data.serialization;

@trusted
class Game {
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
    static MongoCursor!Game search(string query, int page = 0, int countPerPage = 20) {
        return DATABASE["speedrun.games"].find!Game(
            [
                "$or": [
                    ["_id": [ "$regex": query ]],
                    ["name": [ "$regex": query ]],
                    ["description": [ "$regex": query ]]
                ]
            ], 
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
        Update the game instance in the DB
    +/
    void update() {
        DATABASE["speedrun.games"].update(["_id": id], this);
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
        Delete game
    +/
    void deleteGame() {
        DATABASE["speedrun.games"].remove(["_id": id]);
        destroy(this);
    }
}