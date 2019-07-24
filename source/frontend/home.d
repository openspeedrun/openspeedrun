module frontend.home;
import vibe.web.web;

class HomeFE {
    @path("/")
    public void getHome() {
        render!("home.dt");
    }
}