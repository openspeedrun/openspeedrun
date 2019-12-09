<template>
    <router-link class="py-2" v-bind:to="'/users/' + endpoint">
        <card style="min-height: 204px;">
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
                    <div>
                        <center>
                            <span class="chip" v-bind:class="powerLevelCSS" v-if="powers > 1">
                                <label> {{ powerLevelString }}</label>
                            </span>
                        </center>
                    </div>
                </center>
            </template>
        </card>
    </router-link>
</template>

<script lang="ts">
    import { Component, Prop, Vue } from 'vue-property-decorator';
    import { Power } from '@/types';
    import { powerLevelToString, powerLevelToCSS } from '@/types';
    import Card from '@/components/Card.vue';
    
    @Component({name: "user-card", components: { Card }})
    export default class UserCard extends Vue {
        card: Card;

        get powerLevelString(): string {
            return powerLevelToString(this.powers);
        }

        get powerLevelCSS(): string {
            return powerLevelToCSS(this.powers);
        }

        @Prop({}) profilePicture: string;
        @Prop({}) displayName: string;
        @Prop({}) endpoint: string;
        @Prop({}) powers: Power;
    }
</script>