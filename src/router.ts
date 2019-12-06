import Vue from 'vue'
import Router from 'vue-router'

// Info pages
import HomeView from './views/info/HomeView.vue'
import AboutView from './views/info/AboutView.vue'

// Users pages
import UsersView from './views/users/UsersView.vue';
import UserView from './views/users/UserView.vue';

// Games pages
import GamesView from './views/games/GamesView.vue';
import GameView from './views/games/GameView.vue';

// Error pages
import NotFoundView from './views/errors/NotFoundView.vue';

Vue.use(Router)

export default new Router({
  mode: 'history',
  base: process.env.BASE_URL,
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView
    },
    {
      path: '/about',
      name: 'about',
      component: AboutView
    },
    {
      path: '/games',
      name: 'games',
      component: GamesView
    },
    {
      path: '/games/:id',
      name: 'games',
      component: GameView
    },
    {
      path: '/users',
      name: 'users',
      component: UsersView
    },
    {
      path: '/users/:id',
      name: 'user',
      component: UserView
    },
    {
      path: '*', 
      component: NotFoundView
    }
  ]
})
