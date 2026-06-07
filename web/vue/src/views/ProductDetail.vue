<script setup>
import { ref, computed, onMounted, nextTick, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { showToast, showSuccessToast, showFailToast, showImagePreview } from 'vant'
import { get, post, del } from '../api'
import { fixImg } from '../utils/img'
import { useCartStore } from '../stores/cart'
import { useUserStore } from '../stores/user'

// ── Vant 组件注册 ──
import {
  NavBar,
  Swipe,
  SwipeItem,
  Stepper,
  Button,
  List,
  Cell,
  CellGroup,
  Rate,
  Field,
  Form,
  Tag,
  Skeleton,
  Divider,
  Empty,
  Popup,
  ActionBar,
  ActionBarButton,
  PullRefresh,
  Icon,
  Loading
} from 'vant'

const route = useRoute()
const router = useRouter()
const cartStore = useCartStore()
const userStore = useUserStore()

// ── State ──
const product = ref(null)
const loading = ref(true)
const refreshing = ref(false)
const quantity = ref(1)
const isFavorited = ref(false)
const favLoading = ref(false)

// ── Comments ──
const comments = ref([])
const commentLoading = ref(false)
const commentFinished = ref(false)
const commentPage = ref(1)
const commentPageSize = 10

// ── Comment form ──
const showCommentPopup = ref(false)
const commentForm = ref({ content: '', rating: 5 })
const submitting = ref(false)
const cartLoading = ref(false)

// ── Related products ──
const relatedProducts = ref([])

// ── Image preview ──
const images = computed(() => {
  if (!product.value) return []
  const pics = []
  if (product.value.pic) pics.push(fixImg(product.value.pic))
  return pics
})

const inStock = computed(() => product.value?.stock > 0 ?? false)
const stockLow = computed(() => {
  if (!product.value) return false
  const s = product.value.stock
  return s > 0 && s < 20
})

const avgRating = computed(() => {
  if (!comments.value.length) return 0
  const sum = comments.value.reduce((s, c) => s + (c.rating || 0), 0)
  return (sum / comments.value.length).toFixed(1)
})

// ── 监听路由参数变化 ──
watch(() => route.params.id, () => {
  resetState()
  window.scrollTo(0, 0)
  nextTick(() => window.scrollTo(0, 0))
  loadAll()
})

function resetState() {
  product.value = null
  comments.value = []
  commentPage.value = 1
  commentFinished.value = false
  relatedProducts.value = []
  quantity.value = 1
}

// ── Lifecycle ──
onMounted(() => {
  // 强制滚动到顶部，确保页面跳转后不会停在底部/评价区
  window.scrollTo(0, 0)
  nextTick(() => window.scrollTo(0, 0))
  loadAll()
})

// ── Methods ──
async function loadAll() {
  loading.value = true
  await Promise.all([fetchProduct(), fetchComments()])
  loading.value = false
}

async function onRefresh() {
  refreshing.value = true
  comments.value = []
  commentPage.value = 1
  commentFinished.value = false
  await loadAll()
  refreshing.value = false
}

async function fetchProduct() {
  try {
    const res = await get('/product/detail', { id: route.params.id })
    if (res.code === 200) {
      product.value = res.data.product || res.data
      relatedProducts.value = (res.data.hotProducts || []).slice(0, 6)
      checkFavorite()
    } else {
      showFailToast(res.message || '商品不存在')
    }
  } catch (e) {
    showFailToast(e.message || '网络错误')
  }
}

async function checkFavorite() {
  if (!userStore.loggedIn) return
  try {
    const res = await get('/favorites')
    if (res.code === 200) {
      const list = res.data?.list || res.data || []
      isFavorited.value = list.some(f => f.productId === product.value?.id)
    }
  } catch {}
}

async function toggleFavorite() {
  if (!userStore.loggedIn) {
    showToast({ message: '请先登录', icon: 'warning-o' })
    setTimeout(() => router.push('/login'), 800)
    return
  }
  favLoading.value = true
  try {
    if (isFavorited.value) {
      const res = await del(`/favorites?productId=${product.value.id}`)
      if (res.code === 200) { isFavorited.value = false; showToast('已取消收藏') }
    } else {
      const body = new URLSearchParams()
      body.append('productId', String(product.value.id))
      const res = await post('/favorites', body)
      if (res.code === 200) { isFavorited.value = true; showToast('已添加收藏') }
      else showToast(res.message || '收藏失败')
    }
  } catch (e) { showToast(e.message || '操作失败') }
  finally { favLoading.value = false }
}

async function fetchComments() {
  commentLoading.value = true
  try {
    const res = await get('/comments', {
      productId: route.params.id,
      page: commentPage.value,
      pageSize: commentPageSize
    })
    if (res.code === 200) {
      const list = res.data.list || res.data || []
      comments.value = [...comments.value, ...list]
      if (list.length < commentPageSize) commentFinished.value = true
    } else {
      commentFinished.value = true
    }
  } catch {
    commentFinished.value = true
  } finally {
    commentLoading.value = false
  }
}

function onLoadComments() {
  commentPage.value++
  fetchComments()
}

// ── Image preview ──
function previewImage(index = 0) {
  if (!images.value.length) return
  showImagePreview({
    images: images.value,
    startPosition: index,
    closeable: true,
    closeIconPosition: 'top-right'
  })
}

// ── Add to cart ──
async function addToCart() {
  if (!userStore.loggedIn) {
    showToast({ message: '请先登录', icon: 'warning-o' })
    setTimeout(() => router.push('/login'), 800)
    return
  }
  if (!inStock.value) {
    showToast({ message: '商品暂时缺货', icon: 'info-o' })
    return
  }
  cartLoading.value = true
  try {
    const res = await post('/cart', {
      productId: product.value.id,
      quantity: quantity.value
    })
    if (res.code === 200) {
      showSuccessToast({
        message: `已加入购物车 ×${quantity.value}`,
        icon: 'cart-o',
        duration: 1500
      })
      cartStore.fetch()
    } else {
      showFailToast(res.message || '加入失败')
    }
  } catch (e) {
    showFailToast(e.message || '网络错误')
  } finally {
    cartLoading.value = false
  }
}

function buyNow() {
  if (!userStore.loggedIn) {
    showToast({ message: '请先登录', icon: 'warning-o' })
    setTimeout(() => router.push('/login'), 800)
    return
  }
  if (!inStock.value) {
    showToast({ message: '商品暂时缺货', icon: 'info-o' })
    return
  }
  router.push({
    path: '/checkout',
    query: {
      productId: product.value.id,
      quantity: quantity.value
    }
  })
}

function goBack() {
  if (window.history.length > 1) {
    router.back()
  } else {
    router.push('/')
  }
}

function goProduct(id) {
  comments.value = []
  commentPage.value = 1
  commentFinished.value = false
  commentLoading.value = false
  loading.value = true
  router.push('/product/' + id)
}

// ── Comment submit ──
function openCommentForm() {
  if (!userStore.loggedIn) {
    showToast({ message: '请先登录', icon: 'warning-o' })
    setTimeout(() => router.push('/login'), 800)
    return
  }
  commentForm.value = { content: '', rating: 5 }
  showCommentPopup.value = true
}

async function submitComment() {
  if (!commentForm.value.content.trim()) {
    showToast('请输入评论内容')
    return
  }
  submitting.value = true
  try {
    const res = await post('/comments', {
      productId: product.value.id,
      content: commentForm.value.content,
      rating: commentForm.value.rating
    })
    if (res.code === 200) {
      showSuccessToast('评论成功')
      showCommentPopup.value = false
      comments.value = []
      commentPage.value = 1
      commentFinished.value = false
      fetchComments()
    } else {
      showFailToast(res.message || '评论失败')
    }
  } catch (e) {
    showFailToast(e.message || '网络错误')
  } finally {
    submitting.value = false
  }
}

// ── Helpers ──
function formatTime(t) {
  if (!t) return ''
  return t.replace('T', ' ').substring(0, 16)
}
</script>

<template>
  <div class="product-page">
    <!-- NavBar -->
    <NavBar
      :title="product?.name || '商品详情'"
      left-arrow
      @click-left="goBack"
      @click-right="showToast('分享功能开发中')"
      class="product-navbar"
    >
      <template #right>
        <Icon name="share-o" size="20" />
      </template>
    </NavBar>

    <PullRefresh v-model="refreshing" @refresh="onRefresh" success-text="刷新成功" success-duration="1000">
      <!-- Loading -->
      <div v-if="loading" class="skeleton-wrap">
        <Skeleton title :row="12" />
      </div>

      <!-- Content -->
      <template v-else-if="product">
        <!-- ═══ Image Section ═══ -->
        <div class="image-section">
          <Swipe
            v-if="images.length > 0"
            :autoplay="4000"
            indicator-color="white"
            :duration="500"
            class="product-swipe"
            @click="previewImage(0)"
          >
            <SwipeItem v-for="(img, idx) in images" :key="idx">
              <div class="swipe-item-inner">
                <img :src="img" class="product-image" alt="商品图片" />
                <div class="image-zoom-hint">
                  <Icon name="photo-o" size="14" /> 点击查看大图
                </div>
              </div>
            </SwipeItem>
          </Swipe>
          <Empty v-else description="暂无图片" class="no-image" />
        </div>

        <!-- ═══ Info Card ═══ -->
        <div class="info-card">
          <div class="info-header">
            <div class="info-header-top">
              <h1 class="product-name">{{ product.name }}</h1>
              <div class="fav-btn" :class="{ favorited: isFavorited }" @click="toggleFavorite">
                <van-icon :name="isFavorited ? 'like' : 'like-o'" size="22" :loading="favLoading" />
              </div>
            </div>
            <div class="price-row">
              <span class="price-symbol">¥</span>
              <span class="price-value">{{ product.price.toFixed(2) }}</span>
            </div>
          </div>

          <!-- Stock & Sales -->
          <div class="meta-row">
            <div class="meta-item">
              <span class="meta-label">销量</span>
              <span class="meta-value">{{ product.sales || 0 }}件</span>
            </div>
            <div class="meta-divider" />
            <div class="meta-item">
              <span class="meta-label">库存</span>
              <Tag
                :type="inStock ? (stockLow ? 'warning' : 'success') : 'danger'"
                size="medium"
                round
              >
                {{ inStock ? (stockLow ? '库存紧张' : '库存充足') : '暂时缺货' }}
              </Tag>
            </div>
            <div class="meta-divider" />
            <div class="meta-item">
              <span class="meta-label">评分</span>
              <span class="meta-value">
                <Rate :model-value="Number(avgRating)" readonly :size="14" allow-half />
              </span>
            </div>
          </div>

          <!-- Description -->
          <div v-if="product.intro" class="desc-section">
            <div class="desc-title">商品描述</div>
            <p class="desc-text">{{ product.intro }}</p>
          </div>

          <!-- Quantity -->
          <div class="qty-section">
            <span class="qty-label">数量</span>
            <Stepper
              v-model="quantity"
              :min="1"
              :max="product.stock || 1"
              :disabled="!inStock"
              integer
              button-size="28"
              input-width="44"
              theme="round"
            />
            <span class="qty-hint" v-if="inStock">最多 {{ product.stock }} 件</span>
            <span class="qty-hint" v-else>暂时缺货</span>
          </div>
        </div>

        <!-- ═══ Divider ═══ -->
        <Divider class="section-divider">
          <span class="divider-text"><Icon name="chat-o" /> 用户评价</span>
        </Divider>

        <!-- ═══ Comments Section ═══ -->
        <div class="comment-section-card">
          <!-- Comment stats -->
          <div class="comment-stats-bar">
            <div class="comment-stats-left">
              <span class="comment-avg-score">{{ avgRating }}</span>
              <div class="comment-stars-area">
                <Rate :model-value="Number(avgRating)" readonly :size="14" allow-half />
                <span class="comment-count">{{ comments.length }}条评价</span>
              </div>
            </div>
            <Button
              size="small"
              round
              type="primary"
              plain
              icon="plus"
              @click="openCommentForm"
              class="write-review-btn"
            >
              写评价
            </Button>
          </div>

          <!-- Comment list -->
          <List
            v-model:loading="commentLoading"
            :finished="commentFinished"
            finished-text="— 没有更多了 —"
            :immediate-check="false"
            error-text="加载失败，点击重试"
            @load="onLoadComments"
            class="comment-list"
          >
            <template v-if="comments.length">
              <div v-for="c in comments" :key="c.id || c.commentId" class="comment-item">
                <div class="comment-top">
                  <div class="comment-user-avatar">
                    {{ (c.username || '匿')[0] }}
                  </div>
                  <div class="comment-user-info">
                    <span class="comment-username">{{ c.username || '匿名用户' }}</span>
                    <div class="comment-meta">
                      <Rate v-model="c.rating" readonly :size="12" />
                      <span class="comment-time">{{ formatTime(c.createTime) }}</span>
                    </div>
                  </div>
                </div>
                <div class="comment-body">{{ c.content }}</div>
              </div>
            </template>
            <div v-else-if="!commentLoading" class="comment-empty">
              <Empty description="暂无评价" :image-size="60" />
              <Button size="small" round type="primary" @click="openCommentForm" class="first-review-btn">
                成为第一个评价的人
              </Button>
            </div>
          </List>
        </div>

        <!-- ═══ Related Products ═══ -->
        <Divider class="section-divider" v-if="relatedProducts.length">
          <span class="divider-text"><Icon name="fire-o" /> 热销推荐</span>
        </Divider>

        <div class="related-section" v-if="relatedProducts.length">
          <div class="related-scroll">
            <div
              v-for="item in relatedProducts"
              :key="item.id"
              class="related-card"
              @click="goProduct(item.id)"
            >
              <div class="related-img-wrap">
                <img :src="fixImg(item.pic)" :alt="item.name" class="related-img" />
                <div class="related-sales-badge">已售 {{ item.sales }}</div>
              </div>
              <div class="related-info">
                <div class="related-name">{{ item.name }}</div>
                <div class="related-price">
                  <span class="rp-symbol">¥</span>
                  <span class="rp-value">{{ item.price.toFixed(2) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Bottom spacer for ActionBar -->
        <div class="bottom-spacer" />
      </template>

      <!-- Not found -->
      <Empty v-else description="商品不存在" class="not-found">
        <Button type="primary" round @click="router.push('/')">返回首页</Button>
      </Empty>
    </PullRefresh>

    <!-- ═══ Bottom ActionBar (两个购买按钮并排) ═══ -->
    <ActionBar safe-area-inset-bottom class="product-action-bar" v-if="product">
      <ActionBarButton
        text="加入购物车"
        :disabled="!inStock"
        :loading="cartLoading"
        @click="addToCart"
        class="btn-cart"
      />
      <ActionBarButton
        text="立即购买"
        :disabled="!inStock"
        @click="buyNow"
        class="btn-buy"
      />
    </ActionBar>

    <!-- ═══ Comment form popup ═══ -->
    <Popup
      v-model:show="showCommentPopup"
      position="bottom"
      round
      :style="{ minHeight: '45%' }"
      safe-area-inset-bottom
      closeable
      close-icon-position="top-right"
    >
      <div class="comment-form-wrap">
        <h3 class="comment-form-title">发表评价</h3>

        <div class="cf-row">
          <span class="cf-label">商品评分</span>
          <Rate v-model="commentForm.rating" :size="28" void-icon="star-o" icon="star" color="#ff7a45" />
        </div>

        <Field
          v-model="commentForm.content"
          type="textarea"
          rows="5"
          placeholder="分享您的使用体验，帮助其他小伙伴做出选择～"
          maxlength="500"
          show-word-limit
          autosize
        />

        <div class="cf-actions">
          <Button round plain @click="showCommentPopup = false" class="cf-cancel">取消</Button>
          <Button
            round
            type="primary"
            :loading="submitting"
            :disabled="!commentForm.content.trim()"
            @click="submitComment"
            class="cf-submit"
          >
            提交评价
          </Button>
        </div>
      </div>
    </Popup>
  </div>
</template>

<style scoped>
/* ═══════════════════════════════════════
   归途花店 · 移动端商品详情页
   2026 现代设计语言
   ═══════════════════════════════════════ */

.product-page {
  min-height: 100vh;
  background: #f5f5f5;
  padding-bottom: 0;
  animation: pageEnter 0.35s ease-out;
}

@keyframes pageEnter {
  from { opacity: 0; transform: translateY(12px); }
  to   { opacity: 1; transform: translateY(0); }
}

/* ── NavBar ── */
.product-navbar {
  position: sticky;
  top: 0;
  z-index: 100;
  background: rgba(255, 255, 255, 0.92);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
}

/* ── Skeleton ── */
.skeleton-wrap {
  padding: 16px;
  background: #fff;
}

/* ── Image Section ── */
.image-section {
  background: #fff;
  position: relative;
}

.product-swipe {
  width: 100%;
  height: 375px;
  cursor: pointer;
}

.swipe-item-inner {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #fafafa;
  position: relative;
}

.product-image {
  width: 100%;
  height: 100%;
  object-fit: contain;
  transition: transform 0.3s ease;
}

.image-zoom-hint {
  position: absolute;
  bottom: 12px;
  right: 12px;
  background: rgba(0, 0, 0, 0.45);
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
  color: #fff;
  font-size: 12px;
  padding: 4px 12px;
  border-radius: 20px;
  display: flex;
  align-items: center;
  gap: 4px;
  opacity: 0.7;
}

.no-image {
  height: 375px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

/* ── Info Card ── */
.info-card {
  background: #fff;
  margin: 0;
  padding: 20px 16px 16px;
  border-radius: 16px 16px 0 0;
  margin-top: -16px;
  position: relative;
  z-index: 2;
  box-shadow: 0 -4px 12px rgba(0, 0, 0, 0.04);
}

.info-header {
  margin-bottom: 14px;
}

.product-name {
  font-size: 20px;
  font-weight: 700;
  color: #1a1a1a;
  line-height: 1.4;
  margin: 0;
  letter-spacing: 0.3px;
  flex: 1;
}
.info-header-top { display: flex; align-items: flex-start; gap: 10px; margin-bottom: 12px; }
.fav-btn {
  flex-shrink: 0;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: #f5f5f5;
  cursor: pointer;
  color: #999;
  transition: all 0.2s;
}
.fav-btn:active { transform: scale(0.9); }
.fav-btn.favorited { background: #fff0f0; color: #ee0a24; }

.price-row {
  display: flex;
  align-items: baseline;
  gap: 2px;
}

.price-symbol {
  font-size: 18px;
  font-weight: 700;
  color: #ee0a24;
  line-height: 1;
}

.price-value {
  font-size: 32px;
  font-weight: 800;
  color: #ee0a24;
  line-height: 1;
  letter-spacing: -1px;
}

/* ── Meta Row ── */
.meta-row {
  display: flex;
  align-items: center;
  background: #f8f9fa;
  border-radius: 12px;
  padding: 12px 16px;
  margin-bottom: 14px;
}

.meta-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.meta-label {
  font-size: 12px;
  color: #969799;
}

.meta-value {
  font-size: 14px;
  font-weight: 600;
  color: #323233;
}

.meta-divider {
  width: 1px;
  height: 28px;
  background: #e8e8e8;
}

/* ── Description ── */
.desc-section {
  padding: 14px 0;
  border-top: 1px solid #f0f0f0;
  margin-bottom: 4px;
}

.desc-title {
  font-size: 14px;
  font-weight: 600;
  color: #323233;
  margin-bottom: 8px;
}

.desc-text {
  font-size: 14px;
  color: #646566;
  line-height: 1.7;
  margin: 0;
}

/* ── Quantity ── */
.qty-section {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 0;
  border-top: 1px solid #f0f0f0;
}

.qty-label {
  font-size: 14px;
  font-weight: 600;
  color: #323233;
  min-width: 40px;
}

.qty-hint {
  font-size: 12px;
  color: #969799;
  margin-left: auto;
}

/* ── Divider ── */
.section-divider {
  margin: 20px 0 0;
  color: #969799;
}

.divider-text {
  font-size: 14px;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 6px;
  color: #323233;
}

/* ── Comment Section ── */
.comment-section-card {
  background: #fff;
  padding: 16px;
  margin: 0 0 0;
}

.comment-stats-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
  padding-bottom: 16px;
  border-bottom: 1px solid #f0f0f0;
}

.comment-stats-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.comment-avg-score {
  font-size: 36px;
  font-weight: 800;
  color: #ff7a45;
  line-height: 1;
}

.comment-stars-area {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.comment-count {
  font-size: 12px;
  color: #969799;
}

.write-review-btn {
  flex-shrink: 0;
  min-height: 36px;
}

/* ── Comment List ── */
.comment-list {
  min-height: 100px;
}

.comment-item {
  padding: 14px 0;
  border-bottom: 1px solid #f5f5f5;
  transition: background 0.2s;
}

.comment-item:last-child {
  border-bottom: none;
}

.comment-item:active {
  background: #fafafa;
}

.comment-top {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
}

.comment-user-avatar {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: linear-gradient(135deg, #ff7a45, #ee0a24);
  color: #fff;
  font-size: 14px;
  font-weight: 600;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.comment-user-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.comment-username {
  font-size: 14px;
  font-weight: 600;
  color: #323233;
}

.comment-meta {
  display: flex;
  align-items: center;
  gap: 8px;
}

.comment-time {
  font-size: 12px;
  color: #c8c9cc;
}

.comment-body {
  font-size: 14px;
  color: #323233;
  line-height: 1.6;
  padding-left: 46px;
}

.comment-empty {
  padding: 20px 0;
}

.first-review-btn {
  display: block;
  margin: 0 auto;
}

/* ── Related Products ── */
.related-section {
  background: #fff;
  padding: 16px;
  margin-bottom: 0;
}

.related-scroll {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
}

.related-card {
  background: #fff;
  border-radius: 12px;
  overflow: hidden;
  border: 1px solid #f0f0f0;
  transition: all 0.25s ease;
  cursor: pointer;
}

.related-card:active {
  transform: scale(0.96);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
}

.related-img-wrap {
  position: relative;
  width: 100%;
  aspect-ratio: 1;
  overflow: hidden;
  background: #fafafa;
}

.related-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.related-card:active .related-img {
  transform: scale(1.05);
}

.related-sales-badge {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(to top, rgba(0,0,0,0.6), transparent);
  color: #fff;
  font-size: 11px;
  padding: 18px 8px 4px;
  text-align: right;
}

.related-info {
  padding: 8px 8px 10px;
}

.related-name {
  font-size: 12px;
  color: #323233;
  font-weight: 500;
  line-height: 1.3;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  margin-bottom: 6px;
  min-height: 31px;
}

.related-price {
  display: flex;
  align-items: baseline;
  gap: 1px;
}

.rp-symbol {
  font-size: 11px;
  font-weight: 700;
  color: #ee0a24;
}

.rp-value {
  font-size: 16px;
  font-weight: 800;
  color: #ee0a24;
}

/* ── Bottom Spacer ── */
.bottom-spacer {
  height: 60px;
}

/* ── ActionBar (双按钮并排占据全宽) ── */
.product-action-bar {
  z-index: 99;
  box-shadow: 0 -2px 12px rgba(0, 0, 0, 0.08);
}

.product-action-bar .van-action-bar__button {
  flex: 1;
}

.btn-cart {
  --van-action-bar-button-default-color: #fff;
  --van-action-bar-button-default-background: #f5f5f5;
  --van-action-bar-button-default-font-size: 15px;
  color: #323233;
  min-height: 48px;
  border-radius: 0;
}

.btn-cart:active {
  --van-action-bar-button-default-background: #e8e8e8;
}

.btn-buy {
  --van-action-bar-button-default-color: #fff;
  --van-action-bar-button-default-background: linear-gradient(135deg, #ff6b6b, #ee0a24);
  --van-action-bar-button-default-font-size: 16px;
  min-height: 48px;
  font-weight: 700;
  letter-spacing: 1px;
  border-radius: 0;
}

.btn-buy:active {
  --van-action-bar-button-default-background: linear-gradient(135deg, #ee0a24, #c0392b);
}

/* ── Comment Form Popup ── */
.comment-form-wrap {
  padding: 24px 20px 32px;
}

.comment-form-title {
  text-align: center;
  font-size: 18px;
  font-weight: 700;
  color: #323233;
  margin: 0 0 20px;
}

.cf-row {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
  padding: 0 4px;
}

.cf-label {
  font-size: 14px;
  font-weight: 600;
  color: #646566;
  white-space: nowrap;
}

.cf-actions {
  display: flex;
  gap: 12px;
  margin-top: 20px;
}

.cf-cancel,
.cf-submit {
  flex: 1;
  min-height: 44px;
  font-size: 15px;
  font-weight: 600;
}

/* ── Not found ── */
.not-found {
  margin-top: 80px;
}

/* ═══════════════════════════════════════
   Responsive Adjustments (320px-430px)
   ═══════════════════════════════════════ */

@media (max-width: 360px) {
  .product-swipe {
    height: 300px;
  }

  .product-name {
    font-size: 17px;
  }

  .price-value {
    font-size: 26px;
  }

  .comment-avg-score {
    font-size: 28px;
  }

  .related-scroll {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 420px) {
  .product-swipe {
    height: 420px;
  }
}
</style>
