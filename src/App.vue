<template>
  <div id="app">
    <link rel="shortcut icon" href="/static/assets/favicon.png" />
    <Navbar />
    <transition name="fade" mode="out-in">
      <router-view />
    </transition>
    <footer>
      <center>
        <p>OpenSpeedRun © 2019</p>
        <p style="font-size: 12px">This site is protected by reCAPTCHA, Google's Privacy Policy and Terms of Service apply.</p>
        <a href="https://github.com/openspeedrun/openspeedrun">Fork on GitHub!</a>
      </center>
    </footer>
  </div>
</template>

<style>
.fade-enter-active, .fade-leave-active {
  transition: opacity .5s;
}
.fade-enter, .fade-leave-to /* .fade-leave-active below version 2.1.8 */ {
  opacity: 0;
}
</style>

<script lang="ts">

import { Component, Vue } from 'vue-property-decorator';
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