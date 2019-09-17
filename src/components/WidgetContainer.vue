<template>
    <div class="container">
        <div class="container-title">
            <h2>{{ title }}</h2>
        </div>
        <div class="container-body">
            <slot />
        </div>
    </div>
</template>

<script lang="ts">
    import { Component, Prop, Vue } from 'vue-property-decorator';

    @Component({ name: "widget-container" })
    export default class WidgetContainer extends Vue {
        @Prop({default: null}) title: string;
    }
</script>