module backend.common;

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