<script setup>
import { useUserStore } from './stores/user'
import { useCartStore } from './stores/cart'
import { useRoute } from 'vue-router'
import { ref, watch, onMounted } from 'vue'
import { get } from './api'

const userStore = useUserStore()
const cartStore = useCartStore()
const route = useRoute()

const tabIndex = ref(0)
const tabMap = ['/', '/cart', '/orders', '/profile']
const orderBadge = ref(0)

watch(route, (r) => { tabIndex.value = tabMap.indexOf(r.path) })

async function fetchBadges() {
  if (!userStore.loggedIn) return
  try {
    await cartStore.fetch()
    const res = await get('/orders')
    if (res.code === 200) {
      const orders = Array.isArray(res.data) ? res.data : (res.data?.list || [])
      orderBadge.value = orders.filter(o => o.status === '待付款' || o.status === '已付款' || o.status === '已发货').length
    }
  } catch {}
}

onMounted(async () => {
  if (userStore.loggedIn || userStore.username) {
    try { await userStore.fetchProfile() } catch {}
  }
  fetchBadges()
})
</script>

<template>
  <div style="min-height:100vh;background:#f5f5f5;padding-bottom:60px;">
    <router-view @login-success="fetchBadges" />
  </div>
  <van-tabbar v-model="tabIndex" route fixed safe-area-inset-bottom>
    <van-tabbar-item to="/" icon="home-o">首页</van-tabbar-item>
    <van-tabbar-item to="/cart" icon="cart-o" :badge="cartStore.totalCount || ''">购物车</van-tabbar-item>
    <van-tabbar-item to="/orders" icon="orders-o" :badge="orderBadge ? String(orderBadge) : ''">订单</van-tabbar-item>
    <van-tabbar-item to="/profile" icon="user-o">我的</van-tabbar-item>
  </van-tabbar>
</template>
