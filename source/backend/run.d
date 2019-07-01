module backend.run;
import db;
import vibe.data.serialization;
import backend.common;
import std.datetime;

/++
    A run
+/
class Run {
@trusted:
    /++
        Returns run instance if exists.
    +/
    static Run get(string runId) {
        return DATABASE["speedrun.runs"].findOne!Run(["_id": runId]);
    }

    /++
        ID of the run
    +/
    @name("_id")
    string id;

    /++
        ID of the runner
    +/
    @name("runnerId")
    string runnerId;

    /++
        ID of the category
    +/
    @name("catId")
    string categoryId;

    /++
        Date and time this run was posted
    +/
    DateTime postDate;

    /++
        How long the run took to complete in real-time
    +/
    SRTimeStamp timeStamp;
    
    /++
        How long the run took to complete in In-Game time
    +/
    SRTimeStamp timeStampIG;

    /++
        Link to video proof of completion
    +/
    string videoLink;

    /++
        User-set description
    +/
    string description;

    /++
        The different setups assigned to this run
        (Stuff like console, region, etc.)
    +/
    string[] setups;

    /++
        Wether the run has been verified by a game moderator
    +/
    bool verified = false;

    /++
        Accept a run
    +/
    void accept() {
        verified = true;
        update();
    }

    /++
        Revoke a run
    +/
    void revoke() {
        verified = false;
        update();
    }

    /++
        Deny a run
    +/
    void deny() {
        deleteRun();
    }

    /++
        Update the data in the database
    +/
    void update() {
        return DATABASE["speedrun.runs"].update(["_id": runId], this);
    }

    /++
        Delete game
    +/
    void deleteRun() {
        DATABASE["speedrun.runs"].remove(["_id": id]);
        destroy(this);
    }
}