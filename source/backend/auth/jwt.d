module backend.auth.jwt;
import backend.common : generateID;
import secured.mac;
import vibe.data.json;
import vibe.data.serialization;
import std.base64 : Base64URLNoPadding;
import secured.hash : HashAlgorithm;

// Following is some helper functions to make sure the implementation is consistent

private ubyte[] defaultKey;

static this() {
    defaultKey = generateID(32);
}

/// Encode a string to a base64 string that is compatible
string b64Encode(string data) {
    return Base64URLNoPadding.encode(data);
}

/// Encode a byte array to a base64 string that is compatible
string b64Encode(ubyte[] data) {
    return Base64URLNoPadding.encode(data);
}

/// Decode a base64 string to a series of bytes
ubyte[] b64Decode(string b64) {
    return Base64URLNoPadding.decode(b64);
}

/// Convert a string to an array of bytes
ubyte[] stringToBytes(string utf8) {
    import std.string : representation;
    return utf8.representation;
}

/// Convert an array of bytes to a string
string bytesToString(ubyte[] bytes) {
    return cast(string)bytes;
}

/**
    The signature algorithm for the token
*/
enum JWTAlgorithm : string {
    HS256 = "HS256",
    HS384 = "HS384",
    HS512 = "HS512"
}

/**
    The header of a JSON web token
*/
struct JWTHeader {
    /// The algorithm for the signature
    @name("alg")
    JWTAlgorithm algorithm;

    /// Type is generally Json Web Token
    @name("typ")
    string type = "JWT";

    string toString() {
        return serializeToJson(this);
    }
}

/**
    A JSON Web Token
*/
struct JWTToken {
public:
    /**
        The header of a JWT Token
    */
    JWTHeader header;

    /**
        The payload of a JWT token
    */
    Json payload;

    /**
        The saved signature of a JWT Token
    */
    string signature;

    /**
        Creates a token instance from an already completed token (used to verify tokens)
    */
    this(string jwtToken) {
        import std.array : split;

        // If the structure is invalid throw an exception        
        if (!validateJWTStructure(jwtToken)) throw new Exception("Invalid JWT structure!");

        // Split from the '.' character, then decode the segments of the token
        string[] parts = jwtToken.split('.');
        header = deserializeJson!JWTHeader(parts[0].b64Decode.bytesToString());
        payload = parseJsonString(parts[1].b64Decode.bytesToString());
        signature = parts[2].b64Decode.bytesToString();
    }

    /**
        Creates a new JWT Token
    */
    this(T)(JWTHeader header, T payload) {
        this.header = header;
        this.payload = payload;
    }

    /**
        Sign the JWT Token
    */
    void sign(ubyte[] secret) {
        signature = genSignature(header, payload, secret);
    }

    /**
        Sign the JWT Token with the randomly generated default key
    */
    void sign() {
        sign(defaultKey);
    }

    /**
        Verifies that the token isn't expired and hasn't been tampered with
    */
    bool verify(ubyte[] secret) {
        import std.datetime : Clock, toUnixTime;

        // Get expiry time from json
        immutable(Json) exp = payload["exp"];

        // Make sure that the expiry time actually exists.
        if (exp !is null && exp.type != Json.Type.Null) {
            
            // Verify that the expiry time is an int (unix time)
            if (exp.type != Json.Type.int_) return false;

            immutable(long) expiryTime = exp.to!long;
            immutable(long) currentTime = Clock.currStdTime().toUnixTime!long;

            // The token has expired.
            if (currentTime >= expiryTime) return false;
        }

        // Finally check the signature
        return verifySignature(this, secret);
    }

    /**
        Verifies that the token isn't expired and hasn't been tampered with with the randomly generated default key
    */
    bool verify() {
        return verify(defaultKey);
    }
    
    /** 
        Output the final JWT token
    */
    string toString() const {
        // return the fo
        return "%s.%s.%s".format(header.toString().b64Encode(), payload.toString().b64Encode(), signature);
    }
}

/**
    Validates the structure of the JWT token
*/
bool validateJWTStructure(string jwtString) {
    import std.algorithm.searching : count;
    if (jwtString.count(".") != 2) return false;
}

/**
    Generate a signature for a JWT token
*/
string genSignature(T)(JWTHeader header, Json payload, ubyte[] secret) {
    string toSign = "%s.%s".format(header.toString().b64Encode(), payload.toString().b64Encode());

    // All the signing here does somewhat the same, just passes a different SHA algorithm in
    switch(header.algorithm) {
        case JWTAlgorithm.HS256:
            return hmac_ex(secret, stringToBytes(toSign), HashAlgorithm.SHA2_256).b64Encode();
        case JWTAlgorithm.HS384:
            return hmac_ex(secret, stringToBytes(toSign), HashAlgorithm.SHA2_384).b64Encode();
        case JWTAlgorithm.HS512:
            return hmac_ex(secret, stringToBytes(toSign), HashAlgorithm.SHA2_512).b64Encode();
    }
}

/**
    Verify that the jwt hasn't been tampered with
*/
bool verifySignature(string token, ubyte[] secret) {
    return verifySignature(JWTToken(token), secret);
}

/**
    Verify that the jwt hasn't been tampered with
*/
bool verifySignature(JWTToken token, ubyte[] secret) {
    string toSign = "%s.%s".format(token.header.toString().b64Encode(), token.payload.toString().b64Encode());

    // All the verifications here does somewhat the same, just passes a different SHA algorithm in
    switch(token.header.algorithm) {
        case JWTAlgorithm.HS256:
            return hmac_verify_ex(token.signature.b64Decode, secret, stringToBytes(toSign), HashAlgorithm.SHA2_256);
        case JWTAlgorithm.HS384:
            return hmac_verify_ex(token.signature.b64Decode, secret, stringToBytes(toSign), HashAlgorithm.SHA2_384);
        case JWTAlgorithm.HS512:
            return hmac_verify_ex(token.signature.b64Decode, secret, stringToBytes(toSign), HashAlgorithm.SHA2_512);
    }
}