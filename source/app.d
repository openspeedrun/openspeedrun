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
import std.stdio;
import vibe.d;
import api;
import frontend;
import session;

void main()
{
    // Create a new session manager
    SESSIONS = new SessionManagerImpl();

    // Set up API routes
    URLRouter router = new URLRouter;
    router.registerRestInterface!IAuthenticationEndpoint(new AuthenticationEndpoint(), "/api/v1");
    router.registerRestInterface!IUserEndpoint(new UserEndpoint(), "/api/v1");
    

    // Frontend
    router.registerWebInterface!HomeFE(new HomeFE);
    
	// Static files
	auto fsettings = new HTTPFileServerSettings;
	fsettings.serverPathPrefix = "/static";
	router.get("/static/*", serveStaticFiles("static/", fsettings));

    // TODO: move these to backend impl
    // router.registerRestInterface!ICSSEndpoint(new CSSEndpoint(), "/api/v1");
    // router.registerRestInterface!IGameEndpoint(new GameEndpoint(), "/api/v1");

    // Set up frontend routes
    // TODO: make frontend

    // Launch server.
    listenHTTP("127.0.0.1:8080", router);
    runApplication();
}
