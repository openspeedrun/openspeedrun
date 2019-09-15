<template>
    <div class="container">
        <div class="container-title" v-if="title !== undefined">
            {{ title }}
        <div/>
        <slot></slot>
    </div>
</template>

<script lang="ts">
    import { Component, Prop, Vue } from 'vue-property-decorator';

    @Component
    export default class Container extends Vue {
        @Prop() private title: string | undefined = undefined;

        constructor(title: string) {
            super();
            this.title = title;
        }
    }
</script>