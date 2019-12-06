<template>
    <div class="modal active" id="modal-login" v-if="shouldShow">
        <div class="modal-overlay" aria-label="Close" v-on:click="close" />
        <div class="modal-container">
            <div class="modal-header">
                <div class="modal-title h5">Login</div>
            </div>
            <div class="modal-body">
                <div class="form-horizontal">
                    <!-- Username Field -->
                    <div class="form-group">
                        <div class="col-3 col-sm-12">
                            <label class="form-label">Username or Email</label>
                        </div>
                        <div class="col-9 col-sm-12">
                            <input class="form-input" type="text" v-model="username" />
                        </div>
                    </div>
                    <div class="form-group" v-if="missingUsername">
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
                    <div class="form-group" v-if="missingPassword">
                        <label class="form-label text-error">Field is required</label>
                    </div>

                    <!-- Error Text -->
                    <div class="form-group" v-if="invalidCred">
                        <label class="form-label text-error">Invalid username or password</label>
                    </div>
                </div>
            </div>

            <!-- Login Button-->
            <div class="modal-footer">
                <slot>
                    <!-- Place extra stuff here -->
                </slot>
                <button class="btn btn-primary" v-on:keyup.enter="login" v-on:click="login">Login</button>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
    import { Component, Prop, Vue } from 'vue-property-decorator';
    import { client } from '@/client';
    import { Pronouns, Social, UserInfo } from '@/types';

    interface AuthReq {
        username: string;
        password: string;
    }

    @Component({name: "login-modal"})
    export default class LoginModal extends Vue {
        @Prop({}) shouldShow: boolean;

        @Prop({}) missingUsername: boolean;
        @Prop({}) missingPassword: boolean;
        @Prop({}) invalidCred: boolean;

        @Prop({}) username: string;
        @Prop({}) password: string;

        /**
         * Called on form submit
         */
        public login() {

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

            if (this.missingUsername || this.missingPassword) return;

            // Make the API call
            client.post("/api/v1/auth/login/user", {
                    username: this.username,
                    password: this.password
                }).then(response => {
                    if (response.status != 200) {
                        this.invalidCred = true;
                    } else {
                        this.$store.commit('setToken', response.data as string);
                        this.$store.commit('setUsername', this.username as string);

                        // Get extra user data
                        client.get("/api/v1/users/"+this.username).then(response => {
                            if (response.status == 200) {
                                let userInfo: UserInfo = response.data as UserInfo;
                                this.$store.commit('setProfilePicture', userInfo.profile_picture as string);
                                this.$store.commit('setDisplayName', userInfo.display_name as string);
                            }
                        });

                        this.close();
                    }
            });
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
            this.missingUsername = false;
            this.missingPassword = false;
            this.invalidCred = false;
        }
    }
</script>