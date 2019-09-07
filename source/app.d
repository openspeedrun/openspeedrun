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
import session;
import config;
import backend.mail;

void main()
{
    URLRouter router = new URLRouter;

    // Create a new session manager
    logInfo("Warming up session manager...");
    SESSIONS = new SessionManagerImpl();

    logInfo("Loading configuration...");
    CONFIG = loadConfigSDLFile!ServerConfig("osrconfig", true);

    logInfo("Setting up email service...");
    EMAILER = new MailService(CONFIG.smtp.toClientSettings(), CONFIG.smtp.getAddress());

    // Set up API routes
    if (CONFIG.enableREST) {
        logInfo("Binding REST API...");
        router.registerRestInterface!IAuthenticationEndpoint(new AuthenticationEndpoint(), "/api/v1");
        router.registerRestInterface!IUserEndpoint(new UserEndpoint(), "/api/v1");
        router.registerRestInterface!ICSSEndpoint(new CSSEndpoint(), "/api/v1");
        router.registerRestInterface!IGameEndpoint(new GameEndpoint(), "/api/v1");
    }
   

    // Frontend
    logInfo("Binding frontend...");
    router.any("/", (req, res) {
        res.render!("app.dt", req, res);
    });
    
	// Static files
    logInfo("Binding static file server...");
	auto fsettings = new HTTPFileServerSettings;
	fsettings.serverPathPrefix = "/static";
	router.get("/static/*", serveStaticFiles("static/", fsettings));

    // Launch server.
    logInfo("Launching server...");
    listenHTTP(CONFIG.bindAddress, router);
    logInfo("Server started on %s!...", CONFIG.bindAddress);
    runApplication();
}
