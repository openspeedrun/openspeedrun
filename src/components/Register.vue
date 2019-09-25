<template>
    <div class="content">
        <input type="text" placeholder="Username" v-model="username" />
        <br />
        <input type="text" placeholder="Email Address" v-model="email" />
        <br />
        <input type="password" placeholder="Password" v-model="password" />
        <br />
        <input type="password" placeholder="Repeat Password" v-model="passwordRepeat" />
        <br />
        <button v-on:keyup.enter="login" v-on:click="login">Register</button>
    </div>
</template>


<script lang="ts">
    import { Component, Prop, Vue } from 'vue-property-decorator';
    import { client } from '@/client';


    interface RegReq {
        username: string;
        email: string;
        password: string;
        recaptchaToken: string;
    }

    @Component({name: "auth"})
    export default class Register extends Vue {
        @Prop({}) username: string;
        @Prop({}) email: string;
        @Prop({}) password: string;
        @Prop({}) passwordRepeat: string;

        @Prop({}) errorMessage: string;

        /**
         * Called on form submit
         */
        public login() {
            if (this.password != this.passwordRepeat) {
                alert("Passwords do not match!");
                return;
            }

            this.$recaptcha('register').then((token) => {
                client.post("/api/v1/auth/register", {
                    username: this.username, 
                    password: this.password,
                    recaptchaToken: token,
                    email: this.email
                }).then(response => {
                    if (response.data.status != "ok") {
                        alert(response.data.message);
                    } else {
                        localStorage.setItem('auth', response.data.data);
                    }
                }).catch(reason => {
                    alert(reason);
                });
            });
        }
    }
</script>