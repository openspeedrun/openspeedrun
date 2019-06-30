module backend.common;
import std.regex : split, regex;
import std.conv : to;

struct SRTimeStamp {
    /++
        Creates a new timestamp from an input string
    +/
    static SRTimeStamp fromString(string input) {
        string[] timeSlices = input.split(regex(`:|\.|(h )|(m )|(s )|(ms)`));
        if (timeSlices.length != 4) throw new InvalidFmtException("timestamp", "HH:MM:SS.ms");
        return SRTimeStamp(timeSlices[0].to!int, timeSlices[1].to!int, timeSlices[2].to!int, timeSlices[3].to!int);
    }

    /++
        Hours it took to complete the speedrun
    +/
    int hours;

    /++
        Minutes it took to complete the speedrun
    +/
    int minutes;

    /++
        Seconds it took to complete the speedrun
    +/
    int seconds;

    /++
        Miliseconds it took to complete the speedrun
    +/
    int msecs;

    /++
        Returns a self-parsable time format
    +/
    string toString() {
        import std.format : format;
        return "%d:%d:%d.%d".format(hours, minutes, seconds, msecs);
    }

    /++
        Returns a human readable time format
    +/
    string toHumanReadable() {
        import std.format : format;
        return "%dh %dm %ds %dms".format(hours, minutes, seconds, msecs);
    }
}

/++
    Exception that expresses that an element for an Action is already been used.
+/
class TakenException : Exception {
    this(string takenElm) {
        import std.format : format;
        super("%s is already taken!".format(takenElm));
    }
}

/++
    Exception that express that an element had the wrong format for the Action.
+/
class InvalidFmtException : Exception {
    this(string elm, string expected) {
        import std.format : format;
        super("invalid format for %s! expected: %s".format(elm, expected));
    }
}

enum ExpectedIDFmt = "a-z, A-Z, 0-9, '_', '-', '.'";

/++
    Formats ids
    IDs can contain:
     * Alpha Numeric Characters
     * _
     * -
     * .

    Spaces will automatically be converted to _
    Other characters will be discarded
+/
string formatId(string id) {
    import std.uni : isAlphaNum;
    string outId;
    foreach(c; id) {
        switch(c) {
            case ' ':
                outId ~= "_";
                break;
            case '_':
            case '-':
            case '.':
                outId ~= c;
                break;
            default:
                if (isAlphaNum(c)) {
                    outId ~= c;
                }
                break;
        }
    }
    return outId;
}