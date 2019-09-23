import Vue from 'vue'
import Vuex from 'vuex'
import srstate from '@/srstate'

Vue.use(Vuex)

const store = new Vuex.Store({
  state: {},
  modules: {
    srstate
  }
});

export default store;