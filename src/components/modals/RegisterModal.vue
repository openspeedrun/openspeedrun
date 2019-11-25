<template>        
    <div class="modal active" id="modal-register" v-if="shouldShow">
        <div class="modal-overlay" aria-label="Close" v-on:click="close" />
        <div class="modal-container">
            <div class="modal-header">
                <div class="modal-title h5">Register</div>
            </div>
            <div class="modal-body">
                <div class="form-horizontal">
                    
                    <!-- Username Field -->
                    <div class="form-group">
                        <div class="col-3 col-sm-12">
                            <label class="form-label">Username</label>
                        </div>
                        <div class="col-9 col-sm-12">
                            <input class="form-input" type="text" v-model="username" />
                        </div>
                    </div>
                    <div class="form-group" v-if="missingUsername">
                        <label class="form-label text-error">Field is required</label>
                    </div>
                    
                    <!-- Email Field -->
                    <div class="form-group">
                        <div class="col-3 col-sm-12">
                            <label class="form-label">Email</label>
                        </div>
                        <div class="col-9 col-sm-12">
                            <input class="form-input" type="text" v-model="email" />
                        </div>
                    </div>
                    <div class="form-group" v-if="missingEmail">
                        <label class="form-label text-error">Field is required</label>
                    </div>

                    <!-- Password Field -->
                    <div class="form-group">
                        <div class="col-3 col-sm-12">
                            <label class="form-label">Password</label>
                        </div>
                        <div class="col-9 col-sm-12">
                            <input class="form-input" type="password" v-model="password" />
                        </div>
                    </div>

                    <!-- Password Repeat Field -->
                    <div class="form-group">
                        <div class="col-3 col-sm-12">
                            <label class="form-label">Repeat Password</label>
                        </div>
                        <div class="col-9 col-sm-12">
                            <input class="form-input" type="password" v-model="passwordRepeat" />
                        </div>
                    </div>
                    <div class="form-group" v-if="missingPassword">
                        <label class="form-label text-error">Fields are required</label>
                    </div>
                    <div class="form-group" v-if="passwordMismatch">
                        <label class="form-label text-error">Passwords do not match!</label>
                    </div>
                    <div class="form-group" v-if="generalError != undefined">
                        <label class="form-label text-error">{{ generalError }}</label>
                    </div>
                </div>
            </div>

            <!-- Register Button-->
            <div class="modal-footer">
                <slot class="float-left">
                    <!-- Place extra stuff here -->
                </slot>

                <button class="btn btn-primary" v-on:keyup.enter="register" v-on:click="register">Register</button>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
    import { Component, Prop, Vue } from 'vue-property-decorator';
    import { client } from '@/client';

    interface RegReq {
        username: string;
        email: string;
        password: string;
        rcToken: string;
    }

    @Component({name: "register-modal"})
    export default class RegisterModal extends Vue {
        @Prop({}) shouldShow: boolean;

        @Prop({}) missingUsername: boolean;
        @Prop({}) missingEmail: boolean;
        @Prop({}) missingPassword: boolean;
        @Prop({}) passwordMismatch: boolean;
        @Prop({}) generalError: string;

        @Prop({}) username: string;
        @Prop({}) email: string;
        @Prop({}) password: string;
        @Prop({}) passwordRepeat: string;

        public register() {

            // Basic field validation
            if (this.username == undefined || this.username.length == 0) {
                this.missingUsername = true;
            } else {
                this.missingUsername = false;
            }

            if (this.password == undefined || this.password.length == 0) {
                this.missingPassword = true;
            } else {
                this.missingPassword = false;
            }

            if (this.email == undefined || this.email.length == 0) {
                this.missingEmail = true;
            } else {
                this.missingEmail = false;
            }

            if (this.password != this.passwordRepeat) {
                this.passwordMismatch = true;
            } else {
                this.passwordMismatch = false;
            }

            if (this.missingUsername || this.missingEmail || this.missingPassword || this.passwordMismatch) return;

            // Make the API call
            client.post("/api/v1/auth/register", {
                username: this.username, 
                password: this.password,
                rcToken: "",
                email: this.email
            }).then(response => {
                switch(response.status) {
                    case 200:
                        console.log(response.data);
                        if (response.data.data as string == "ok") {
                            alert("Check your inbox for a verification email.");
                            this.close();
                        } else {
                            this.$store.commit('setToken', response.data as string);
                            this.$store.commit('setUsername', this.username as string);
                            this.close();
                        }
                        break;
                    default:
                        this.generalError = response.data.statusMessage as string;
                        break;
                }
            }).catch(reason => {
                alert(reason);
            });
            // this.$recaptcha('register').then((token) => {
            // });
        }

        public show() {
            this.shouldShow = true;
        }

        public close() {
            this.clear();
            this.shouldShow = false;
        }

        public clear() {
            this.username = "";
            this.password = "";
            this.passwordRepeat = "";
            this.email = "";

            this.missingUsername = false;
            this.missingPassword = false;
            this.missingEmail = false;
            this.passwordMismatch = false;
        }
    }
</script>