<template>
    <header class="navbar bg-secondary">
        <section class="navbar-section">
            <router-link class="navbar-brand mr-2" v-bind:to="'/'">
                <img src="/static/app/assets/logo.png" style="height: 48px; width: auto;" />
            </router-link>
            <router-link class="btn btn-link btn-lg" v-bind:to="'/games'">Games</router-link>
            <router-link class="btn btn-link btn-lg" v-bind:to="'/runs'">Runs</router-link>
        </section>
        <section class="navbar-section">
            <div name="user-section" v-if="username != null">
                <div class="dropdown dropdown-right" style="padding-right: 4px;">
                    <a href="#" class="btn btn-link btn-lg dropdown-toggle" tabindex="0">
                        <label class="text-left" style="padding-right: 4px;">{{ username }}</label>
                        <figure class="avatar">
                            <img src="https://pbs.twimg.com/profile_images/1149808989963788289/WurVlxeK_400x400.jpg">
                            <i class="avatar-presence online"></i>
                        </figure>
                    </a>

                    <!--The user menu-->
                    <ul class="menu text-left">
                        <li class="menu-item">
                            <a v-bind:href="'/users/' + username">
                                Profile
                            </a>
                        </li>
                        <li class="menu-item">
                            <a href="#" v-on:keyup.enter="logout" v-on:click="logout">
                                Logout
                            </a>
                        </li>
                    </ul>

                </div>
            </div>
            <div class="btn btn-link btn-lg" @click="showLogin" v-if="username == null">Log In</div>

            <LoginModal ref="loginModal">
                <a class="btn btn-link" @click="showRegister">Don't have an account?</a>
            </LoginModal>
            <RegisterModal ref="registerModal" />
        </section>
    </header>
</template>

<script lang="ts">
    import { Component, Prop, Ref, Vue } from 'vue-property-decorator';
    import LoginModal from '@/components/modals/LoginModal.vue';
    import RegisterModal from '@/components/modals/RegisterModal.vue';
    import store from '@/store';

    @Component({name: "navbar", components: { LoginModal, RegisterModal }})
    export default class Navbar extends Vue {
        @Ref() loginModal: LoginModal;
        @Ref() registerModal: RegisterModal;

        get username(): string {
            return this.$store.state.srstate.username;
        }

        public showLogin() {
            (this.$refs["loginModal"] as LoginModal).show();
        }

        public closeLogin() {
            (this.$refs["loginModal"] as LoginModal).close();
        }

        public showRegister() {
            this.closeLogin();
            (this.$refs["registerModal"] as RegisterModal).show();
        }

        public logout() {
            this.$store.commit('setToken', null);
        }
    }
</script>