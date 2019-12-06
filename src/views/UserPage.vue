<template>
    <div class="container" style="height: 100%;">
        <div class="columns py-2" v-if="userFound">
            <section class="column col-3">
                <div class="panel">

                    <div class="panel-header text-center">
                        <figure class="avatar avatar-xxl">
                            <img v-bind:src="avatarURL" alt="Profile Picture">
                        </figure>
                        <div class="panel-title h5"> {{ displayName }} </div>
                    </div>

                    <div class="panel-body">

                    </div>
                </div>
            </section>

            <section class="column col-9" v-if="isRunner">
                <div class="panel">
                    <div class="panel-header">
                        <div class="panel-title text-center">
                            Runs
                        </div>

                        <div class="panel-body">
                            <div class="empty">
                                <p class="empty-title h5">User has no runs</p>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section class="column col-9" v-if="!isRunner">
                <div class="panel">
                    <div class="panel-header">
                        <div class="panel-title text-center">
                            Favourites
                        </div>

                        <div class="panel-body">
                            <div class="empty">
                                <p class="empty-title h5">User has no favourites</p>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </div>

        <div v-if="isLoading">
            <div class="loading loading-lg"></div>
        </div>

        <div v-if="!isLoading">
            <div class="empty" v-if="!userFound">
                <p class="empty-title h5">User {{ username }} not found</p>
                <p class="empty-subtitle">Check if you've spelled their username correctly</p>
                <div class="empty-action">
                    <a href="/" class="btn btn-link">Back to front page</a>
                </div>
            </div>
        </div>
    </div>
</template>

<script lang="ts">
    import { Component, Prop, Vue } from 'vue-property-decorator';
    import { client } from '@/client';
    import { Pronouns, Social, Runner, UserInfo } from '@/types';


    @Component({name: "UserPage", components: { }})
    export default class UserPage extends Vue {
        @Prop({}) userInfo: UserInfo;
        @Prop({}) runnerInfo: Runner;

        @Prop({}) userFound: boolean = false;
        @Prop({}) isLoading: boolean = true;
        
        get username(): string {
            return this.$route.params.id as string;
        }

        get displayName(): string {
            return this.userInfo.display_name;
        }

        get verified(): boolean {
            return this.userInfo.verified;
        }

        get isRunner(): boolean {
            return this.runnerInfo != undefined;
        }

        get pronounSubject(): string {
            return this.userInfo.pronouns.subject;
        }

        get pronounObject(): string {
            return this.userInfo.pronouns.object;
        }

        get pronounPossesive(): string {
            return this.userInfo.pronouns.possesive;
        }

        // TODO: Make this not be a pre-defined value
        get avatarURL(): string {
            return this.userInfo.profile_picture;
        }

        mounted() {
            // Make the API call
            client.get("/api/v1/users/"+this.username).then(response => {
                console.log(response.data);
                if (response.status == 200) {
                    this.userInfo = response.data as UserInfo;
                    this.userFound = true;
                }
                this.isLoading = false;
            });
        }
        
    }
</script>