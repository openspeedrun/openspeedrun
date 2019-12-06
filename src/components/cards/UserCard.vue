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

    @Component({name: "user-card"})
    export default class UserCard extends Vue {

    }
</script>