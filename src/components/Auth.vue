<template>
    <div class="content">
        <input type="text" placeholder="Username or Email" v-model="username" />
        <br />
        <input type="password" placeholder="Password" v-model="password" />
        <button v-on:keyup.enter="login" v-on:click="login">Login</button>
    </div>
</template>


<script lang="ts">
    import { Component, Prop, Vue } from 'vue-property-decorator';
    import { client } from '@/client';


    interface AuthReq {
        username: string;
        password: string;
    }

    @Component({name: "auth"})
    export default class Auth extends Vue {
        @Prop({}) username: string;
        @Prop({}) password: string;

        /**
         * Called on form submit
         */
        public login() {
            client.post("/api/v1/auth/login/user", {
                    username: this.username,
                    password: this.password
                }).then(response => {
                    if (response.status != 200) {
                        alert(response.data.statusMessage);
                    } else {
                        this.$store.commit('setToken', response.data as string);
                        this.$store.commit('setUsername', this.username as string);
                    }
            });
        }

        public logout() {
            this.$store.commit('setToken', null);
        }
    }
</script>