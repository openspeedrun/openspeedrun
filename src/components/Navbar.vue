<template>
    <div class="navbar" style="height: 64px;">
        <a class="navItem navLogo" href="/">
            <img src="@/assets/logo.png" \>
        <a/>

        <a class="navButton"><p>Games</p></a>
        <a class="navButton"><p>Runs</p></a>
        <div class="spacer" />

        <slot name="user-section">USER</slot>

    </div>
</template>

<script lang="ts">
    import { Component, Prop, Vue } from 'vue-property-decorator';

    @Component
    export default class Navbar extends Vue {
        @Prop() private title: string | undefined = undefined;

        constructor(title: string) {
            super();
            this.title = title;
        }
    }
</script>