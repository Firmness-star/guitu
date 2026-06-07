<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showToast, showConfirmDialog } from 'vant'
import { get, post, del } from '../api'
import { fixImg } from '../utils/img'
import { useCartStore } from '../stores/cart'
import { useUserStore } from '../stores/user'

const router = useRouter()
const cartStore = useCartStore()
const userStore = useUserStore()

const favorites = ref([])
const loading = ref(true)

async function fetchFavorites() {
  loading.value = true
  try {
    const res = await get('/favorites')
    if (res.code === 200) {
      favorites.value = res.data?.list || res.data || []
    }
  } catch (e) {
    showToast(e.message || '加载失败')
  } finally {
    loading.value = false
  }
}

async function removeFav(productId) {
  try { await showConfirmDialog({ title: '取消收藏', message: '确定取消收藏该商品吗？' }) } catch { return }
  try {
    const res = await del(`/favorites?productId=${productId}`)
    if (res.code === 200) {
      favorites.value = favorites.value.filter(f => f.productId !== productId)
      showToast('已取消收藏')
    }
  } catch (e) { showToast(e.message || '操作失败') }
}

async function addToCart(item) {
  if (!userStore.loggedIn) { showToast('请先登录'); router.push('/login'); return }
  try {
    await cartStore.add(item.productId, 1)
    showToast('已加入购物车')
  } catch (e) { showToast(e.message || '添加失败') }
}

function goProduct(id) { router.push('/product/' + id) }

onMounted(() => {
  if (!userStore.loggedIn) { router.replace('/login'); return }
  fetchFavorites()
})
</script>

<template>
  <div class="favorites-page">
    <van-nav-bar title="我的收藏" left-arrow fixed placeholder safe-area-inset-top @click-left="router.back" />

    <div v-if="loading" style="display:flex;align-items:center;justify-content:center;padding:120px 0;">
      <van-loading type="spinner" size="28" color="#ee0a24" />
    </div>

    <van-empty v-else-if="!favorites.length" description="还没有收藏商品" image="search">
      <van-button type="primary" round @click="router.push('/')">去逛逛</van-button>
    </van-empty>

    <div v-else class="fav-list">
      <div v-for="item in favorites" :key="item.productId" class="fav-card">
        <div class="fav-img" @click="goProduct(item.productId)">
          <img :src="fixImg(item.productPic)" :alt="item.productName" class="fav-img-el"
            @error="$event.target.src='data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%22100%22 height=%22100%22><rect fill=%22%23f5f5f5%22 width=%22100%22 height=%22100%22 rx=%228%22/><text x=%2250%22 y=%2260%22 text-anchor=%22middle%22 fill=%22%23ccc%22 font-size=%2230%22>🌸</text></svg>'" />
        </div>
        <div class="fav-info" @click="goProduct(item.productId)">
          <div class="fav-name">{{ item.productName }}</div>
          <div class="fav-price">&yen;{{ Number(item.productPrice || 0).toFixed(2) }}</div>
        </div>
        <div class="fav-actions">
          <van-button size="small" round type="danger" plain @click="removeFav(item.productId)">取消</van-button>
          <van-button size="small" round type="primary" @click="addToCart(item)">加购</van-button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.favorites-page { min-height: 100vh; background: #f5f5f5; padding-bottom: 20px; }
.fav-list { padding: 8px 12px; }
.fav-card { display: flex; align-items: center; gap: 12px; background: #fff; border-radius: 10px; padding: 12px; margin-bottom: 10px; }
.fav-img { flex-shrink: 0; width: 80px; height: 80px; border-radius: 8px; overflow: hidden; cursor: pointer; }
.fav-img-el { width: 80px; height: 80px; object-fit: cover; display: block; }
.fav-info { flex: 1; min-width: 0; cursor: pointer; }
.fav-name { font-size: 14px; font-weight: 500; color: #333; line-height: 1.4; overflow: hidden; text-overflow: ellipsis; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; margin-bottom: 6px; }
.fav-price { font-size: 16px; font-weight: 700; color: #ee0a24; }
.fav-actions { display: flex; gap: 8px; flex-shrink: 0; flex-direction: column; }
</style>
