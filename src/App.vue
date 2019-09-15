<template>
  <div id="app">
    <Navbar />
    <router-view/>
  </div>
</template>

<script lang="ts">
import { Component, Vue} from 'vue-property-decorator';
import Navbar from '@/components/Navbar.vue'
import WidgetContainer from '@/components/WidgetContainer.vue'
import Home from '@/views/Home.vue'

@Component({
  components: {
    Navbar
  }
})
export default class App extends Vue {}
</script>