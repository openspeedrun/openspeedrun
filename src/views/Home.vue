<template>
    <div class="content">
        <link rel="shortcut icon" href="/static/assets/favicon.png" />
        <title>OpenSpeedRun - Home</title>

        <!-- TODO: Make home page -->
        <p>
            This is the home page for OpenSpeedRun, it's pretty barren right now
        </p>

        <div class="contentBody">
            <Auth />
            <br />
            <Register />
        </div>
    </div>
</template>

<script lang="ts">
import Auth from '@/components/Auth.vue';
import Register from '@/components/Register.vue';

export default {
    name: 'Home',
    components: {
        Auth,
        Register
    }
}
</script>