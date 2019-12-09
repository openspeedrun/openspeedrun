<template>
    <div>
        <header class="navbar bg-tertiary px-2 py-2">
            <section class="navbar-section">

            </section>
            <section class="navbar-section">
                <div class="input-group input-inline">
                    <input class="form-input" type="text" placeholder="Search" v-model="searchTerm">
                    <button class="btn btn-primary input-group-btn" @click="search">
                        <i class="icon icon-search" />
                    </button>
                </div>
            </section>
        </header>

        <div class="container">
            <div class="columns">
                <user-card class="column col-2" v-for="user in users" v-bind:key="user.id"
                    v-bind:profile-picture="user.profile_picture"
                    v-bind:display-name="user.display_name"
                    v-bind:endpoint="user.id"
                />
            </div>
        </div>
    </div>   
</template>

<script lang="ts">
    import { Component, Prop, Vue } from 'vue-property-decorator';
    import { client } from '@/client';
    import { AxiosRequestConfig } from 'axios';
    import { Pronouns, Social, UserInfo } from '@/types';

    import UserCard from '@/components/cards/UserCard.vue';

    @Component({name: "UsersView", components: { UserCard }})
    export default class UsersView extends Vue {
        users: UserInfo[];
        searchTerm: string;
        page: number;

        mounted() {
            this.search();
        }

        public search() {
            client.get(`/api/v1/users/search/${!!this.page ? this.page : 0}`, {
                params: {
                    query: !!this.searchTerm ? this.searchTerm : ""
                }
            }).then(response => {
                if (response.status == 200) {
                    this.users = response.data as UserInfo[];
                    console.log(this.users);
                    this.$forceUpdate();
                }
                console.log(response);
            });
        }
    }
</script>