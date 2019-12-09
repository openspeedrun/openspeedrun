<template>
    <div class="card">
        <div class="card-image" v-if='hasImageSlot'>
            <slot name="image"><slot>
        </div>

        <div class="card-header" v-if='hasHeaderSlot'>
            <slot name="header"><slot>
        </div>

        <div class="card-body" v-if='hasBodySlot'>
            <slot name="body"><slot>
        </div>

        <div class="card-footer" v-if='hasFooterSlot'>
            <slot name="footer"><slot>
        </div>
    </div>
</template>

<script lang="ts">
    import { Component, Prop, Vue } from 'vue-property-decorator';
    
    @Component({name: "card"})
    export default class Card extends Vue {
        get hasImageSlot() : boolean {
            return this.hasSlot('image');
        }
        get hasHeaderSlot() : boolean {
            return this.hasSlot('header');
        }
        get hasBodySlot() : boolean {
            return this.hasSlot('body');
        }
        get hasFooterSlot() : boolean {
            return this.hasSlot('footer');
        }

        hasSlot(name: string = "default"): boolean {
            return !!this.$slots[name] || !!this.$scopedSlots[name];
        }
    }
</script>