<template>
    <div class="hero" style="height: 100%;">
        <center>
            <h1>Whatever you were looking for</h1>
            <h2>It's not here...</h2>
            <a href="/">Back to Home</a>
        </center>
    </div>
</template>

<script lang="ts">
    import { Component, Prop, Vue } from 'vue-property-decorator';
    import { client } from '@/client';


    @Component({name: "NotFoundView", components: { }})
    export default class NotFoundView extends Vue {
        
    }
</script>