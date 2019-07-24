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
module backend.runner;
import vibe.data.serialization;
import db;

struct Social {
    /**
        Name of social site
    */
    string name;

    /**
        Link to social site
    */
    string link;
}

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

    /**
        Social places
    */
    Social[] social;

    static Runner get(string id) {
        return DATABASE["speedrun.runners"].findOne!Runner(["_id": id]);
    }

    static Runner getOrCreate(string id) {
        Runner runner = get(id);
        if (runner is null) {
            runner = new Runner;
            runner.user = id;
            DATABASE["speedrun.runners"].insert(runner);
        }
        return runner;
    }
}