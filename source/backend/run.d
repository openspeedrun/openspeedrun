module backend.run;
import db;
import vibe.data.serialization;
import backend.common;

/++
    A run
+/
class Run {
@trusted:
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
        How long the run took to complete
    +/
    SRTimeStamp timeStamp;

    /++
        Link to video proof of completion
    +/
    string videoLink;

    /++
        User-set description
    +/
    string description;

    /++
        Wether the run has been verified by a game moderator
    +/
    bool verified = false;
}