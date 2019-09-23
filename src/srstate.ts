import { Module, VuexModule, Mutation, Action } from 'vuex-module-decorators';

@Module
export default class SRState extends VuexModule {
  token: string;

  @Mutation setToken(token: string) { this.token = token; console.log("Saved JWT auth token!"); }
  @Mutation getToken(): string { return this.token; }
}