<template>
    <div class="container">

    </div>   
</template>

<script lang="ts">
    import { Component, Prop, Vue } from 'vue-property-decorator';
    import { client } from '@/client';
    import { Pronouns, Social, UserInfo } from '@/types';


    @Component({name: "UsersView", components: { }})
    export default class UsersView extends Vue {
        
    }
</script>