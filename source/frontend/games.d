module frontend.games;
import vibe.web.web;
import vibe.web.rest;
import session;

@path("/games")
class GamesFE {
    @path("/")
    @before!getToken("token")
    public void getGames(string token, string searchTerm = "", bool showUnapproved = false) {
        render!("games/list.dt", token, searchTerm, showUnapproved);
    }

    @path("/:gameId")
    @before!getToken("token")
    public void getGame(string token, string _gameId, string category="") {

        // To give it a more friendly name within the template.
        immutable(string) gameId = _gameId;
        render!("games/game/view.dt", token, gameId, category);
    }
}