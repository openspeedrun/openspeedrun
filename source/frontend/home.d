module frontend.home;
import vibe.web.web;
import vibe.web.rest;
import session;

class HomeFE {
    @path("/")
    @before!getToken("token")
    public void getHome(string token) {
        render!("home.dt", token);
    }
}