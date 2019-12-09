<template>
    <router-link class="py-2" v-bind:to="'/users/' + endpoint">
        <card>
            <template v-slot:image>
                <div class="px-2 py-2">
                    <center>
                        <figure class="avatar avatar-xxl avatar-force-radius">
                            <img v-bind:src="profilePicture" alt="Profile picture of {{ displayName }}">
                        </figure>
                    </center>
                </div>
            </template>

            <template v-slot:header>
                <center>
                    <div class="card-title h5 text-center">{{ displayName }}</div>
                </center>
            </template>
        </card>
    </router-link>
</template>

<script lang="ts">
    import { Component, Prop, Vue } from 'vue-property-decorator';
    import Card from '@/components/Card.vue';
    
    @Component({name: "user-card", components: { Card }})
    export default class UserCard extends Vue {
        card: Card;

        @Prop({}) profilePicture: string;
        @Prop({}) displayName: string;
        @Prop({}) endpoint: string;
    }
</script>