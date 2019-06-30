module backend.runner;
import vibe.data.serialization;
import db;

class Runner {
    /++
        The user the runner object is attached to
    +/
    @name("_id")
    string user;

    /++
        country code for the country of origin
    +/
    string country;

    /++
        Account flavourtext
    +/
    string flavourText;
}