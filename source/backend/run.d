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
module backend.run;
import db;
import vibe.data.serialization;
import backend.common;
import std.datetime;

/**
    The type of a run
*/
enum RunType : ubyte {
    /**
        An Full-Game Run
    */
    FG,

    /**
        An Individual-Level Run
    */
    IL
}

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
    
    /**
        Checks wether an ID was taken
    */
    static bool has(string id) {
        return DATABASE["speedrun.runs"].count(["_id": id]) > 0;
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

    /**
        The object this run is attached to.
    */
    @name("attachedTo")
    Attachment attachedTo;

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

    /**
        Create a new Full-Game Run
    */
    this(string userId, string categoryId, ) {

        // Generate a unique ID, while ensuring uniqueness
        do { this.id = generateID(16); } while(Run.has(this.id));

        // Find a runner attached to a user, if none found create one
        

        this.userId = userId;
        this.attachedTo = new Attachment(RunType.FG, categoryId);


    }

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
        return DATABASE["speedrun.runs"].update(["_id": id], this);
    }

    /++
        Delete game
    +/
    void deleteRun() {
        DATABASE["speedrun.runs"].remove(["_id": id]);
        destroy(this);
    }
}