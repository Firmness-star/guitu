import { createRouter, createWebHashHistory } from 'vue-router'

const routes = [
  { path: '/', name: 'Home', component: () => import('../views/Home.vue'), meta: { title: '🌸 归途' } },
  { path: '/category/:id', name: 'Category', component: () => import('../views/ProductList.vue'), meta: { title: '分类商品' } },
  { path: '/search', name: 'Search', component: () => import('../views/ProductList.vue'), meta: { title: '搜索' } },
  { path: '/product/:id', name: 'ProductDetail', component: () => import('../views/ProductDetail.vue'), meta: { title: '商品详情' } },
  { path: '/cart', name: 'Cart', component: () => import('../views/Cart.vue'), meta: { title: '购物车' } },
  { path: '/checkout', name: 'Checkout', component: () => import('../views/Checkout.vue'), meta: { title: '确认订单' } },
  { path: '/orders', name: 'Orders', component: () => import('../views/Orders.vue'), meta: { title: '我的订单' } },
  { path: '/payment', name: 'Payment', component: () => import('../views/Payment.vue'), meta: { title: '支付' } },
  { path: '/login', name: 'Login', component: () => import('../views/Login.vue'), meta: { title: '登录' } },
  { path: '/register', name: 'Register', component: () => import('../views/Register.vue'), meta: { title: '注册' } },
  { path: '/profile', name: 'Profile', component: () => import('../views/Profile.vue'), meta: { title: '个人中心' } },
  { path: '/address', name: 'Address', component: () => import('../views/Address.vue'), meta: { title: '收货地址' } },
  { path: '/order-success', name: 'OrderSuccess', component: () => import('../views/OrderSuccess.vue'), meta: { title: '下单成功' } },
  { path: '/payment-success', name: 'PaymentSuccess', component: () => import('../views/PaymentSuccess.vue'), meta: { title: '支付成功' } },
  { path: '/security', name: 'Security', component: () => import('../views/Security.vue'), meta: { title: '安全中心' } },
  { path: '/message', name: 'Message', component: () => import('../views/Message.vue'), meta: { title: '留言板' } }
]

const router = createRouter({
  history: createWebHashHistory(),
  routes,
  scrollBehavior() {
    return { top: 0, behavior: 'smooth' }
  }
})

export default router
