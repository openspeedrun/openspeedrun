import { Module, VuexModule, Mutation, Action } from 'vuex-module-decorators';
import { Module as Mod } from 'vuex';

@Module
export default class SRState extends VuexModule {
    token: string | null;
    username: string | null;
    profile_picture: string | null;
    display_name: string | null;
    dark_mode: boolean;

    constructor(module: Mod<ThisType<any>, any>) {
        super(module)
        this.token = localStorage.getItem('auth');
        this.username = localStorage.getItem('username');
        this.profile_picture = localStorage.getItem('profile_picture');
        this.display_name = localStorage.getItem('display_name');
        this.dark_mode = localStorage.getItem('dark-mode') == "true";
    }

    @Mutation setToken(token: string | null) { 
        this.token = token; 
        if (typeof token === "string") {
            localStorage.setItem('auth', token as string);
        } else {
            localStorage.removeItem('auth');
            localStorage.removeItem('username');
            localStorage.removeItem('profile_picture');
            localStorage.removeItem('display_name');
            localStorage.removeItem('dark-mode');
            this.username = null;
        }
    }

    @Mutation setUsername(username: string | null) {
        localStorage.setItem('username', username as string);
        this.username = username;
    }

    @Mutation setProfilePicture(picture: string | null) {
        localStorage.setItem('profile_picture', picture as string);
        this.profile_picture = picture;
    }

    @Mutation setDisplayName(displayName: string | null) {
        localStorage.setItem('display_name', displayName as string);
        this.display_name = displayName;
    }

    @Mutation setDarkMode(darkMode: boolean) {
        localStorage.setItem('dark-mode', `${darkMode}`);
        this.dark_mode = darkMode;
    }
} 