module backend.category;
import db;
import vibe.data.serialization;

/++
    Category for Full Game runs
+/
class Category {
    
    /++
        ID of the category
    +/
    @name("_id")
    string id;

    /++
        ID of game this category belongs to
    +/
    @name("gameId")
    string gameId;

    /++
        Display name of category
    +/
    string displayName;

}

/++
    Category for Individual Level runs
+/
class ILCategory {

}