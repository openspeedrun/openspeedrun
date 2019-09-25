import { Module, VuexModule, Mutation, Action } from 'vuex-module-decorators';
import { Module as Mod } from 'vuex';

@Module
export default class SRState extends VuexModule {
    token: string | null;
    username: string | null;

    constructor(module: Mod<ThisType<any>, any>) {
        super(module)
        this.token = localStorage.getItem('auth');
        this.username = localStorage.getItem('username');
    }

    @Mutation setToken(token: string | null) { 
        this.token = token; 
        if (typeof token === "string") {
            localStorage.setItem('auth', token as string);
        } else {
            localStorage.removeItem('auth');
            localStorage.removeItem('username')
            this.username = null;
        }
    }

    @Mutation setUsername(username: string | null) {
        localStorage.setItem('username', username as string);
        this.username = username;
    }
} 