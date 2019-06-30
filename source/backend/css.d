module backend.css;
import db;
import vibe.data.serialization;

/++
    Cascading Style-Sheet for a game page
+/
class CSS {
@trusted:
    /++
        Get CSS from database, returns null if none found
    +/
    static CSS get(string game) {
        return DATABASE["speedrun.css"].findOne!CSS(["_id": game]);
    }

    /++
        Wipe CSS for a game (if it exists)
    +/
    static void wipe(string game) {
        CSS css = get(game);
        if (css is null) return;

        css.css = "";
        css.approvedCSS = "";
        css.lastApproved = "";
        css.update();
    }

    this() {}

    this(string game, string css) {
        this.game = game;
        this.css = css;
        DATABASE["speedrun.css"].insert(this);
    }

    /++
        The game this CSS instance belongs to
    +/
    @name("_id")
    @optional
    string game;

    /++
        Approved CSS to be viewed on-site
    +/
    @optional
    string lastApproved;

    /++
        Approved CSS to be viewed on-site
    +/
    @optional
    string approvedCSS;

    /++
        CSS set by user

        THIS CSS SHOULD FOR SECURITY REASONS *NOT* BE SHOWN BY DEFAULT.
    +/
    @optional
    string css;

    /++
        Approve the CSS
    +/
    void approve() {
        lastApproved = approvedCSS;
        approvedCSS = css;
        update();
    }

    /++
        Revoke the css (reverting to last approved css)
    +/
    void revoke() {
        approvedCSS = lastApproved;
        update();
    }

    /++
        Deny css (overwriting in-review css to last approved CSS)
    +/
    void deny() {
        css = approvedCSS;
        update();
    }

    /++
        Update the game instance in the DB
    +/
    void update() {
        DATABASE["speedrun.css"].update(["_id": game], this);
    }

    /++
        Delete game
    +/
    void deleteCSS() {
        DATABASE["speedrun.css"].remove(["_id": game]);
        destroy(this);
    }
}