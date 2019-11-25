<template>        
    <div class="modal active" id="modal-register" v-if="shouldShow">
        <div class="modal-overlay" aria-label="Close" v-on:click="close" />
        <div class="modal-container">
            <div class="modal-header">
                <div class="modal-title h5">{{ modalTitle }}</div>
            </div>
            <div class="modal-body">
                <div class="form-horizontal">
                <slot>
                    <label>{{ modalBody }}</label>
                </slot>
                </div>
            </div>

            <!-- Close Button-->
            <div class="modal-footer">
                <slot name="footer"></slot>
            </div>
        </div>
    </div>
</template>


<script lang="ts">
    import { Component, Prop, Vue } from 'vue-property-decorator';

    @Component({name: "modal"})
    export default class Modal extends Vue {
        @Prop({}) modalTitle: string;
        @Prop({}) modalBody: string;

        constructor() {
            super();
        }

        static newModal(title: string, body: string) : Modal {
            var modal = new Modal();
            modal.modalTitle = title;
            modal.modalBody = body;
            return modal;
        }
    }
</script>