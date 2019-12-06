<template>
    <div class="hero">
        <h1>About OSR</h1>
        <p>
            OpenSpeedRun is an open source speedrunning leaderboard.
            <br />
            The project is still in development and a lot of features will be missing for a bit.
        </p>
    </div>

    <!-- <div class="content">
        <link rel="shortcut icon" href="/static/assets/favicon.png" />
        <title>OpenSpeedRun - About</title>

        <div class="contentBodyLeft" />

        <div class="contentBody">
            <widget-container title="About OSR">
                <p>
                    OpenSpeedRun is an open source speedrunning leaderboard.
                    <br />
                    The project is still in development and a lot of features will be missing for a bit.
                </p>

                <h2>Technologies Used</h2>

                <br />

                <h3>Backend</h3>
                <ul>
                    <li><a href="https://dlang.org">DLang</a></li>
                    <li><a href="http://vibed.org/">Vibe.d</a></li>
                </ul>

                <br />

                <h3>Frontend</h3>
                <ul>
                    <li><a href="https://www.typescriptlang.org/">Typescript</a></li>
                    <li><a href="https://vuejs.org/">Vue.js</a></li>
                </ul>
            </widget-container>
        </div>

        <div class="contentBodyRight" />

    </div> -->
</template>

<script lang="ts">
import WidgetContainer from '@/components/WidgetContainer.vue'
export default {
    name: 'AboutView',
    components: {
        WidgetContainer
    }
}
</script>