<template>
    <div class="container" style="height: 100%;">
        <div class="columns py-2" v-if="!!userInfo">
            <section class="column col-3">
                <div class="panel">

                    <div class="panel-header text-center">
                        <figure class="avatar avatar-xxl">
                            <img v-bind:src="avatarURL" alt="Profile Picture">
                        </figure>
                        <div class="panel-title h5"> {{ displayName }} </div>
                        <span class="chip bg-primary" v-if="pronounsEnabled">
                            <label> {{ pronounSubject }}/{{ pronounObject }}</label>
                        </span>
                    </div>

                    <div class="panel-body">
                    </div>
                </div>
            </section>

            <section class="column col-9">
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
        </div>

        <div v-if="!userInfo && isLoading">
            <div class="loading loading-lg"></div>
        </div>

        <div v-if="!userInfo && !isLoading">
            <div class="empty">
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
    import { Pronouns, Social, UserInfo } from '@/types';


    @Component({name: "UserView", components: { }})
    export default class UserView extends Vue {
        @Prop({}) userInfo: UserInfo;

        @Prop({}) isLoading: boolean = true;
        @Prop({}) username: string;

        get displayName(): string {
            return this.userInfo.display_name;
        }

        get verified(): boolean {
            return this.userInfo.verified;
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

        get pronounsEnabled(): boolean {
            return this.userInfo.pronouns_enabled;
        }

        // TODO: Make this not be a pre-defined value
        get avatarURL(): string {
            return this.userInfo.profile_picture;
        }

        mounted() {
            this.update();
        }

        updated() {
            // Otherwise the dark mode change could break this.
            // this.update();
        }

        public update() {
            this.username = this.$route.params.id as string;

            // Make the API call
            client.get("/api/v1/users/"+this.username).then(response => {
                if (response.status == 200) {
                    this.userInfo = response.data as UserInfo;
                }
                this.isLoading = false;
            });
            console.log(`Displaying user ${this.username}...`);
        }
    }
</script>