<template>
    <div class="container">
        <div class="container-title" v-if="title !== null">
            {{ title }}
        </div>
        <slot></slot>
    </div>
</template>

<script lang="ts">
    import { Component, Prop, Vue } from 'vue-property-decorator';

    @Component
    export default class WidgetContainer extends Vue {
        title: string | null = null;
    }
</script>