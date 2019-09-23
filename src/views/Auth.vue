<template>
    <div class="content">
        <link rel="shortcut icon" href="/static/assets/favicon.png" />
        <title>Log In to OpenSpeedRun</title>

        <!-- TODO: Make home page -->
        <input type="text" placeholder="Username" v-model="username" />
        <input type="password" placeholder="Password" v-model="password" />
        <button v-on:keyup.enter="login" v-on:click="login">Login</button>
    </div>
</template>


<script lang="ts">
    import { Component, Prop, Vue } from 'vue-property-decorator';
    import Axios, * as axios from 'axios';
    import store from '@/store';


    class AuthData {
        password: string;

        constructor(pwd: string) {
            this.password = pwd;
        }
    }

    @Component({name: "auth"})
    export default class Auth extends Vue {
        @Prop({}) username: string;
        @Prop({}) password: string;

        /**
         * Called on form submit
         */
        public login() {
            Axios.post("/api/v1/auth/login/"+this.username, 
                new AuthData(this.password)).then(response => {
                    if (response.data.status != "ok") {
                        alert(response.data.message);
                    } else {
                        store.commit('setToken', response.data.data);
                    }
                });
        }
    }
</script>