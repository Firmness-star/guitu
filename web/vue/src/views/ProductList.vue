<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { showToast } from 'vant'
import { get } from '../api'
import { fixImg } from '../utils/img'
import { useCartStore } from '../stores/cart'
import { useUserStore } from '../stores/user'

const route = useRoute()
const router = useRouter()
const cartStore = useCartStore()
const userStore = useUserStore()

const isSearch = computed(() => route.name === 'Search')
const categoryId = computed(() => route.params.id || null)
const keyword = computed(() => route.query.keyword || '')

const products = ref([])
const loading = ref(false)
const refreshing = ref(false)
const finished = ref(false)
const page = ref(1)
const pageSize = 20
const subCategories = ref([])
const activeSubCat = ref(null)
const parentCategoryId = ref(null)

const navTitle = computed(() => {
  if (isSearch.value) return keyword.value ? `搜索: ${keyword.value}` : '搜索'
  return '分类商品'
})

// ── fetch products ──────────────────────────────────────────────
async function fetchProducts(reset = false) {
  if (reset) {
    page.value = 1
    finished.value = false
  }
  if (finished.value && !reset) return

  loading.value = true
  try {
    const params = { page: page.value, pageSize }
    if (isSearch.value && keyword.value) {
      params.keyword = keyword.value
    } else if (categoryId.value) {
      params.categoryId = categoryId.value
    }

    const res = await get('/products', params)
    if (res.code === 200) {
      const list = res.data?.list || res.data?.products || res.data || []
      // load siblings/sub-categories
      const cats = res.data?.categories || []
      subCategories.value = []
      if (cats.length > 0 && categoryId.value) {
        const cid = Number(categoryId.value)
        // check if this is a parent category
        const parent = cats.find(c => c.id === cid)
        if (parent && parent.children && parent.children.length > 0) {
          subCategories.value = parent.children
          parentCategoryId.value = parent.id
        } else {
          // check if this is a child - find its parent and siblings
          for (const p of cats) {
            if (p.children) {
              const found = p.children.find(c => String(c.id) === String(cid))
              if (found) {
                parentCategoryId.value = p.id
                subCategories.value = p.children
                break
              }
            }
          }
        }
      }
      if (reset) {
        products.value = list
      } else {
        products.value.push(...list)
      }
      if (list.length < pageSize) finished.value = true
    }
  } catch (e) {
    console.error('Failed to fetch products:', e)
  } finally {
    loading.value = false
    refreshing.value = false
  }
}

// ── pull-to-refresh ─────────────────────────────────────────────
function onRefresh() {
  refreshing.value = true
  fetchProducts(true)
}

// ── load-more (infinite scroll) ─────────────────────────────────
function onLoadMore() {
  if (finished.value || loading.value) return
  page.value++
  fetchProducts()
}

// ── infinite scroll detection via scroll event ──────────────────
function onScroll(e) {
  const el = e.target
  if (!el) return
  const { scrollTop, scrollHeight, clientHeight } = el
  if (scrollHeight - scrollTop - clientHeight < 100) {
    onLoadMore()
  }
}

// ── navigate to product detail ──────────────────────────────────
function goProduct(id) {
  router.push(`/product/${id}`)
}

async function addToCart(item) {
  if (!userStore.loggedIn) { showToast('请先登录'); router.push('/login'); return }
  try {
    await cartStore.add(item.id, 1)
    showToast('已加入购物车')
  } catch (e) { showToast(e.message || '添加失败') }
}

function goSubCat(id) {
  parentCategoryId.value = categoryId.value ? Number(categoryId.value) : parentCategoryId.value
  activeSubCat.value = Number(id)
  router.replace(`/category/${id}`)
}

function goBackToParent() {
  activeSubCat.value = null
  if (parentCategoryId.value) {
    router.replace(`/category/${parentCategoryId.value}`)
    parentCategoryId.value = null
  } else {
    router.back()
  }
}

function goBack() {
  router.back()
}

// ── format price ────────────────────────────────────────────────
function formatPrice(val) {
  if (val == null) return ''
  return Number(val).toFixed(2)
}

// ── watchers ────────────────────────────────────────────────────
watch([categoryId, keyword], () => {
  activeSubCat.value = categoryId.value ? Number(categoryId.value) : null
  parentCategoryId.value = null
  fetchProducts(true)
}, { immediate: false })

onMounted(() => {
  if (categoryId.value) {
    activeSubCat.value = Number(categoryId.value)
  }
  fetchProducts(true)
})
</script>

<template>
  <div class="product-list-page">
    <!-- navigation bar -->
    <van-nav-bar
      :title="navTitle"
      left-arrow
      fixed
      placeholder
      safe-area-inset-top
      @click-left="goBack"
    />

    <!-- pull-to-refresh -->
    <van-pull-refresh
      v-model="refreshing"
      @refresh="onRefresh"
      success-text="刷新成功"
      style="min-height: 100vh"
    >
      <!-- Sub-category filter bar -->
      <div v-if="subCategories.length > 0" class="sub-cat-bar">
        <span
          v-for="cat in subCategories"
          :key="cat.id"
          class="sub-cat-chip"
          :class="{ active: activeSubCat === cat.id }"
          @click="goSubCat(cat.id)"
        >{{ cat.name }}</span>
      </div>

      <!-- search result count -->
      <div v-if="isSearch && keyword" class="search-result-count">
        找到 <strong>{{ products.length }}</strong> 件相关商品
      </div>

      <!-- product grid -->
      <div
        v-if="products.length > 0"
        class="product-grid"
        @scroll="onScroll"
      >
        <div
          v-for="item in products"
          :key="item.id"
          class="product-card"
          @click="goProduct(item.id)"
        >
          <div class="product-card__image">
            <img
              :src="fixImg(item.pic)"
              style="width:100%;height:100%;object-fit:cover;position:absolute;top:0;left:0"
              :alt="item.name"
              @error="$event.target.src='data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%22200%22 height=%22200%22><rect fill=%22%23f5f5f5%22 width=%22200%22 height=%22200%22/><text x=%22100%22 y=%22110%22 text-anchor=%22middle%22 fill=%22%23ccc%22 font-size=%2240%22>🌸</text></svg>'"
            />
            <!-- sold out overlay -->
            <div v-if="item.stock === 0" class="sold-out-overlay">
              <span>售罄</span>
            </div>
            <div v-if="item.stock !== 0" class="product-card-btn" @click.stop="addToCart(item)">
              <van-icon name="cart-o" size="16" />
            </div>
          </div>
          <div class="product-card__body">
            <h3 class="product-card__title">{{ item.name }}</h3>
            <p v-if="item.description" class="product-card__desc">{{ item.description }}</p>
            <div class="product-card__bottom">
              <span class="product-card__price">
                <span class="price-symbol">&yen;</span>{{ formatPrice(item.price) }}
              </span>
              <span v-if="item.sales || item.salesCount" class="product-card__sales">
                已售 {{ item.sales || item.salesCount }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- empty state -->
      <van-empty
        v-if="!loading && products.length === 0"
        description="暂无商品"
        :image="isSearch ? 'search' : 'default'"
      />

      <!-- loading -->
      <div v-if="loading && products.length === 0" class="loading-container">
        <van-loading size="24" vertical>加载中...</van-loading>
      </div>

      <!-- bottom loading indicator -->
      <div v-if="loading && products.length > 0" class="loading-more">
        <van-loading size="16" />
        <span class="loading-text">正在加载更多...</span>
      </div>

      <!-- no more data -->
      <div v-if="finished && products.length > 0" class="finished-text">
        没有更多了
      </div>
    </van-pull-refresh>
  </div>
</template>

<style scoped>
.product-list-page {
  min-height: 100vh;
  background: #f5f5f5;
}

/* Sub-category chips */
.sub-cat-bar { display:flex;gap:8px;padding:10px 12px;overflow-x:auto;-webkit-overflow-scrolling:touch;background:#fff; }
.sub-cat-bar::-webkit-scrollbar { display:none; }
.sub-cat-chip { flex-shrink:0;font-size:12px;padding:5px 14px;border-radius:16px;background:#f5f5f5;color:#666;cursor:pointer;border:1px solid #eee; }
.sub-cat-chip.active { background:#fff5f5;color:#e74c3c;border-color:#e74c3c;font-weight:600; }

/* ── product grid ─────────────────────────────────────────────── */
.product-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
  padding: 8px;
  overflow-y: auto;
  max-height: calc(100vh - 46px);
}

/* ── search result count ───────────────────────────────────────── */
.search-result-count {
  padding: 10px 14px;
  font-size: 13px;
  color: #969799;
}
.search-result-count strong { color: #ee0a24; font-weight: 700; }

/* ── product card ─────────────────────────────────────────────── */
.product-card {
  background: #fff;
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
  cursor: pointer;
  transition: transform 0.15s ease;
}

.product-card:active {
  transform: scale(0.97);
}

.product-card__image {
  position: relative;
  width: 100%;
  padding-top: 100%;
  background: #f7f8fa;
  overflow: hidden;
}

.product-card__image :deep(.van-image) {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}

.image-placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
  background: #f7f8fa;
}

.sold-out-overlay {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
}

.sold-out-overlay span {
  color: #fff;
  font-size: 14px;
  font-weight: 600;
  background: rgba(0, 0, 0, 0.6);
  padding: 4px 12px;
  border-radius: 12px;
}

.product-card-btn {
  position: absolute;
  bottom: 8px;
  right: 8px;
  width: 36px;
  height: 36px;
  background: #ee0a24;
  color: #fff;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  z-index: 3;
  transition: transform 0.2s;
  box-shadow: 0 2px 6px rgba(238, 10, 36, 0.4);
}
.product-card-btn:active { transform: scale(1.15); background: #c0392b; }

.product-card__body {
  padding: 8px 10px 10px;
}

.product-card__title {
  font-size: 13px;
  font-weight: 500;
  color: #333;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  overflow: hidden;
  margin: 0 0 4px;
  min-height: 36px;
}

.product-card__desc {
  font-size: 11px;
  color: #999;
  line-height: 1.3;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 1;
  overflow: hidden;
  margin: 0 0 6px;
}

.product-card__bottom {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.product-card__price {
  font-size: 16px;
  font-weight: 700;
  color: #ee0a24;
}

.price-symbol {
  font-size: 12px;
  font-weight: 600;
}

.product-card__sales {
  font-size: 11px;
  color: #999;
}

/* ── loading ──────────────────────────────────────────────────── */
.loading-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 300px;
}

.loading-more {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 16px 0;
}

.loading-text {
  font-size: 13px;
  color: #999;
}

/* ── finished ─────────────────────────────────────────────────── */
.finished-text {
  text-align: center;
  padding: 16px 0 24px;
  font-size: 13px;
  color: #c8c9cc;
}
</style>
