<template>
    <div class="container" style="height: 100%;">
        <div class="columns py-2" v-if="userDefined && !isLoading">
            <section class="column col-3">
                <div class="panel">

                    <div class="panel-header text-center">
                        <figure class="avatar avatar-xxl">
                            <img v-bind:src="userInfo.profile_picture" alt="Profile Picture">
                        </figure>
                        <div class="panel-title h5"> {{ userInfo.display_name }} </div>
                        <span class="chip bg-primary" v-if="userInfo.pronouns_enabled">
                            <label> {{ userInfo.pronouns.subject }}/{{ userInfo.pronouns.object }}</label>
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

        <div v-if="!userDefined && isLoading">
            <div class="loading loading-lg"></div>
        </div>

        <div v-if="!userDefined && !isLoading">
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
    import { NavigationGuard } from 'vue-router';
    import { client } from '@/client';
    import { Pronouns, Social, UserInfo } from '@/types';
    import { Route, RawLocation, Next } from 'vue-router';


    @Component<UserView>({name: "UserView", components: { }, 
        beforeRouteUpdate(to: Route, from: Route, next: Next) {
            next();
            console.log("Showing " + to.params.id);
            this.update(to.params.id);
        }
    })
    export default class UserView extends Vue {
        userInfo: UserInfo;
        isLoading: boolean = true;

        userDefined(): boolean {
            return this.userInfo != undefined;
        }

        mounted() {
            this.update(this.$route.params.id as string);
        }

        public update(endpoint: string) {
            this.isLoading = true;

            // Make the API call
            client.get("/api/v1/users/"+endpoint).then(response => {
                if (response.status == 200) {
                    this.userInfo = response.data as UserInfo;

                    // Fallback: If no profile picture is found, use the neumann pfp.
                    if (!this.userInfo.profile_picture) {
                        this.userInfo.profile_picture = "/static/app/assets/neumann.png";
                    }
                    console.log("Found user...");
                }
                this.isLoading = false;
                console.log(`Displaying user ${this.userInfo.display_name}...`);
            });
        }
    }
</script>