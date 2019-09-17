<template>
    <div class="navbar" style="height: 64px;">
        <router-link class="navItem navLogo" v-bind:to="'/'">
            <img src="/static/app/assets/logo.png" />
        </router-link>

        <div class="nav-gradin" />
        <a class="nav-button"><p>Games</p></a>
        <a class="nav-button"><p>Runs</p></a>
        <div class="nav-gradout" />

        <div class="spacer" />

        <div class="nav-gradin" />
        <slot name="user-section">
            <a class="s-nav-button">
                <div class="nav-item-wrapper">
                    <div class="avatar-small">
                        <img class="avatar-img" src="https://pbs.twimg.com/profile_images/1149808989963788289/WurVlxeK_400x400.jpg" />
                    </div>
                </div>
            </a>
        </slot>

    </div>
</template>

<script lang="ts">
    import { Component, Prop, Vue } from 'vue-property-decorator';

    @Component({
        name: "navbar"
    })
    export default class Navbar extends Vue {
    }
</script>