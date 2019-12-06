import { Module, VuexModule, Mutation, Action } from 'vuex-module-decorators';
import { Module as Mod } from 'vuex';

@Module
export default class SRState extends VuexModule {
    token: string | null;
    username: string | null;
    profile_picture: string | null;

    constructor(module: Mod<ThisType<any>, any>) {
        super(module)
        this.token = localStorage.getItem('auth');
        this.username = localStorage.getItem('username');
        this.profile_picture = localStorage.getItem('profile_picture');
    }

    @Mutation setToken(token: string | null) { 
        this.token = token; 
        if (typeof token === "string") {
            localStorage.setItem('auth', token as string);
        } else {
            localStorage.removeItem('auth');
            localStorage.removeItem('username')
            localStorage.removeItem('profile_picture')
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
} 