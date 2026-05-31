<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { showToast } from 'vant'
import { get } from '../api'
import { fixImg } from '../utils/img'

const router = useRouter()

const loading = ref(true)
const refreshing = ref(false)
const keyword = ref('')
const banners = ref([])
const categories = ref([])
const products = ref([])
const hotProducts = ref([])
const currentBanner = ref(0)
let bannerTimer = null
const displayLimit = ref(20)
const displayProducts = computed(() => products.value.slice(0, displayLimit.value))
const showBackTop = ref(false)

function onScroll() {
  const scrollY = window.scrollY
  const docHeight = document.documentElement.scrollHeight - window.innerHeight
  showBackTop.value = scrollY > 500
  // auto-load when within 300px of bottom
  if (docHeight - scrollY < 300 && displayLimit.value < products.value.length) {
    loadMore()
  }
}

function scrollToTop() {
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

function loadMore() {
  displayLimit.value = Math.min(displayLimit.value + 20, products.value.length)
}

async function fetchHomeData() {
  try {
    const productRes = await get('/products')
    if (productRes.code === 200) {
      products.value = productRes.data.list || []
      categories.value = productRes.data.categories || []
      hotProducts.value = productRes.data.hotProducts || []
      banners.value = productRes.data.banners || []
      startBannerAutoplay()
    }
  } catch (err) {
    showToast(err.message || '加载失败')
  } finally {
    loading.value = false
    refreshing.value = false
  }
}

function startBannerAutoplay() {
  stopBannerAutoplay()
  if (banners.value.length <= 1) return
  bannerTimer = setInterval(() => {
    currentBanner.value = (currentBanner.value + 1) % banners.value.length
  }, 3000)
}

function stopBannerAutoplay() {
  if (bannerTimer) { clearInterval(bannerTimer); bannerTimer = null }
}

function goBanner(banner) {
  if (banner.productId > 0) {
    router.push('/product/' + banner.productId)
  }
}

function onRefresh() {
  refreshing.value = true
  fetchHomeData()
}

function goSearch() {
  const kw = keyword.value.trim()
  if (kw) router.push({ path: '/search', query: { keyword: kw } })
}

function goProduct(id) { router.push('/product/' + id) }
function goCategory(id) { router.push('/category/' + id) }

onMounted(() => {
  fetchHomeData()
  window.addEventListener('scroll', onScroll)
})

onUnmounted(() => {
  stopBannerAutoplay()
  window.removeEventListener('scroll', onScroll)
})
</script>

<template>
  <div class="home-page">
    <!-- Search Bar -->
    <form class="search-bar" @submit.prevent="goSearch">
      <van-search v-model="keyword" placeholder="搜索鲜花、花束..." shape="round" background="transparent" @search="goSearch" />
    </form>

    <!-- Loading -->
    <div v-if="loading" style="display:flex;flex-direction:column;align-items:center;justify-content:center;padding:120px 0;gap:12px;">
      <van-loading type="spinner" size="32" color="#e74c3c" />
      <span style="font-size:13px;color:#999;">加载中...</span>
    </div>

    <van-pull-refresh v-else v-model="refreshing" @refresh="onRefresh" success-text="刷新成功">
      <!-- Banner Carousel -->
      <div v-if="banners.length" class="banner-section">
        <div class="banner-wrapper" @mouseenter="stopBannerAutoplay" @mouseleave="startBannerAutoplay" style="position:relative;height:200px;">
          <div
            v-for="(banner, idx) in banners"
            :key="banner.id"
            class="banner-slide"
            :style="{ opacity: idx === currentBanner ? 1 : 0 }"
            @click="goBanner(banner)"
          >
            <img :src="fixImg(banner.imgUrl)" alt="轮播海报" />
          </div>
        </div>
        <div v-if="banners.length > 1" class="banner-dots">
          <span
            v-for="(b, idx) in banners"
            :key="idx"
            class="banner-dot"
            :class="{ active: idx === currentBanner }"
            @click="currentBanner = idx"
          />
        </div>
      </div>

      <!-- Category Grid -->
      <div v-if="categories.length" class="category-section">
        <van-grid :column-num="5" :border="false" :gutter="8">
          <van-grid-item
            v-for="cat in categories"
            :key="cat.id"
            :text="cat.name"
            icon="flower-o"
            @click="goCategory(cat.id)"
          />
        </van-grid>
      </div>

      <!-- Hot Products -->
      <div v-if="hotProducts.length" class="hot-section">
        <div class="section-title-bar">
          <span class="section-title">🔥 热卖推荐</span>
        </div>
        <div class="hot-scroll">
          <div v-for="item in hotProducts" :key="item.id" class="hot-card" @click="goProduct(item.id)">
            <img :src="fixImg(item.pic)" class="hot-img" @error="$event.target.src='data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%22140%22 height=%22160%22><rect fill=%22%23f5f5f5%22 width=%22140%22 height=%22160%22/><text x=%2250%25%22 y=%2250%25%22 text-anchor=%22middle%22 dy=%22.3em%22 fill=%22%23ccc%22 font-size=%2230%22>🌸</text></svg>'" />
            <div class="hot-name">{{ item.name }}</div>
            <div class="hot-price">¥{{ item.price.toFixed(2) }}</div>
            <div class="hot-sales">已售 {{ item.sales }}</div>
          </div>
        </div>
      </div>

      <!-- All Products with van-list -->
      <div v-if="products.length" class="product-section">
        <div class="section-title-bar">
          <span class="section-title">全部商品</span>
          <span class="section-subtitle">共 {{ products.length }} 件</span>
        </div>
        <div class="product-grid">
          <div v-for="item in displayProducts" :key="item.id" class="product-card" @click="goProduct(item.id)">
            <div class="product-img-wrapper">
              <img :src="fixImg(item.pic)" class="product-img" @error="$event.target.src='data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%22200%22 height=%22150%22><rect fill=%22%23f5f5f5%22 width=%22200%22 height=%22150%22/><text x=%2250%25%22 y=%2250%25%22 text-anchor=%22middle%22 dy=%22.3em%22 fill=%22%23ccc%22 font-size=%2240%22>🌸</text></svg>'" />
              <span v-if="item.sales > 100" class="product-ribbon">畅销</span>
              <span v-if="item.isLowStock" class="product-ribbon product-ribbon-warn">库存紧张</span>
            </div>
            <div class="product-info">
              <div class="product-name">{{ item.name }}</div>
              <div class="product-desc">{{ item.intro }}</div>
              <div class="product-bottom">
                <span class="product-price">¥{{ item.price.toFixed(2) }}</span>
                <span class="product-sales">已售 {{ item.sales }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <van-empty v-if="!products.length && !hotProducts.length" description="暂无商品" />
    </van-pull-refresh>

    <!-- Back to Top -->
    <transition name="fade">
      <div v-show="showBackTop" class="back-top-btn" @click="scrollToTop">
        <van-icon name="back-top" size="22" />
      </div>
    </transition>

    <!-- Footer -->
    <div class="home-footer">
      <p>🌸 归途花店 · 让每一束花传递温暖</p>
      <p style="font-size:11px;color:#bbb;margin-top:4px;">© 2026 归途花店 · 保留所有权利</p>
    </div>
  </div>
</template>

<style scoped>
.home-page { min-height:100vh;background:#f5f5f5; }
.search-bar { padding:8px 12px;background:#fff; }

/* ============= Banner Carousel (opacity fade, matches JSP) ============= */
.banner-section { max-width:1200px;margin:12px auto 0;padding:0 12px; }
.banner-wrapper { position:relative;border-radius:12px;overflow:hidden; }
.banner-slide { position:absolute;top:0;left:0;width:100%;transition:opacity 0.5s ease; }
.banner-slide img { width:100%;height:200px;object-fit:cover;cursor:pointer;border-radius:12px; }
.banner-dots { display:flex;justify-content:center;gap:8px;margin-top:10px;padding-bottom:4px; }
.banner-dot { width:8px;height:8px;border-radius:50%;background:#ccc;cursor:pointer;transition:all 0.3s; }
.banner-dot.active { background:#e74c3c;width:20px;border-radius:4px; }

/* ============= Category ============= */
.category-section { margin:12px;background:#fff;border-radius:12px;padding:8px 0; }

/* ============= Section Title ============= */
.section-title-bar { display:flex;align-items:center;justify-content:space-between;padding:13px 14px 8px; }
.section-title { font-size:18px;font-weight:700;color:#333; }
.section-subtitle { font-size:12px;color:#999; }

/* ============= Hot Products (horizontal scroll) ============= */
.hot-section { margin:0 12px;background:#fff;border-radius:12px;padding-bottom:14px; }
.hot-scroll { display:flex;gap:10px;overflow-x:auto;padding:0 12px 8px;-webkit-overflow-scrolling:touch; }
.hot-scroll::-webkit-scrollbar { display:none; }
.hot-card { flex-shrink:0;width:140px;cursor:pointer; }
.hot-name { font-size:13px;color:#333;margin-top:6px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap; }
.hot-price { font-size:16px;font-weight:700;color:#e74c3c;margin-top:2px; }
.hot-sales { font-size:11px;color:#bbb;margin-top:1px; }

/* ============= Product Grid ============= */
.product-section { margin:12px;background:#fff;border-radius:12px;padding-bottom:12px; }
.product-grid { display:grid;grid-template-columns:repeat(2,1fr);gap:10px;padding:0 12px 8px; }
.product-card { background:#fff;border-radius:10px;overflow:hidden;box-shadow:0 1px 4px rgba(0,0,0,0.06);cursor:pointer;transition:transform 0.2s; }
.product-card:active { transform:scale(0.97); }
.product-img-wrapper { position:relative;overflow:hidden;aspect-ratio:4/3;background:#f7f8fa; }
.product-img { width:100%;height:100%;object-fit:cover;display:block; }
.hot-img { width:100%;height:160px;object-fit:cover;border-radius:10px;display:block;background:#f7f8fa; }
.back-top-btn { position:fixed;bottom:80px;right:16px;width:44px;height:44px;background:#e74c3c;color:#fff;border-radius:50%;display:flex;align-items:center;justify-content:center;box-shadow:0 2px 8px rgba(0,0,0,0.2);cursor:pointer;z-index:99; }
.product-ribbon { position:absolute;top:6px;right:-28px;width:90px;background:linear-gradient(135deg,#e74c3c,#ff6b6b);color:#fff;text-align:center;padding:3px 0;font-size:11px;font-weight:600;transform:rotate(45deg);z-index:1; }
.product-ribbon-warn { background:linear-gradient(135deg,#f39c12,#e67e22); }
.product-info { padding:10px; }
.product-name { font-size:14px;font-weight:600;color:#333;overflow:hidden;text-overflow:ellipsis;white-space:nowrap; }
.product-desc { font-size:12px;color:#999;line-height:1.4;margin-top:4px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap; }
.product-bottom { display:flex;align-items:center;justify-content:space-between;margin-top:8px; }
.product-price { font-size:16px;font-weight:700;color:#e74c3c; }
.product-sales { font-size:11px;color:#bbb; }

/* ============= Footer ============= */
.home-footer { text-align:center;padding:24px 0;color:#999;font-size:12px; }
</style>
