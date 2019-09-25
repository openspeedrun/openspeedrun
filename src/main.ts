import Vue from 'vue'
import App from '@/App.vue'
import router from '@/router'
import store from '@/store'
import Axios, * as axios from 'axios';

import { VueReCaptcha } from 'vue-recaptcha-v3';

Vue.config.productionTip = false
Vue.config.devtools = true;

// Fetch the site key from the server for recaptcha
// TODO: Bake it in?
Axios.get("/api/v1/auth/siteKey").then(response => {
  Vue.use(VueReCaptcha, { siteKey: response.data, loaderOptions: {
    userRecaptchaNet: true, autoHideBadge: true }
  });
}).finally(() => {
  new Vue({
    router,
    store,
    render: h => h(App)
  }).$mount('#app');
});