<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { showToast, showSuccessToast, showFailToast } from 'vant'
import { get, post } from '../api'
import { fixImg } from '../utils/img'
import { useCartStore } from '../stores/cart'
import { useUserStore } from '../stores/user'

import {
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
  ActionBarIcon,
  ActionBarButton
} from 'vant'

const route = useRoute()
const router = useRouter()
const cartStore = useCartStore()
const userStore = useUserStore()

// ── Product ──
const product = ref(null)
const loading = ref(true)
const quantity = ref(1)

// ── Comments ──
const comments = ref([])
const commentLoading = ref(false)
const commentFinished = ref(false)
const commentPage = ref(1)

// ── Comment form popup ──
const showCommentPopup = ref(false)
const commentForm = ref({ content: '', rating: 5 })

// ── Computed ──
const images = computed(() => {
  if (!product.value) return []
  if (product.value.pic) return [product.value.pic]
  return []
})

const inStock = computed(() => {
  if (!product.value) return false
  return product.value.stock > 0
})

// ── Lifecycle ──
onMounted(() => {
  fetchProduct()
  fetchComments()
})

// ── Methods ──
async function fetchProduct() {
  loading.value = true
  try {
    const res = await get('/product/detail', { id: route.params.id })
    if (res.code === 200) {
      product.value = res.data.product || res.data
    } else {
      showFailToast(res.message || '商品不存在')
    }
  } catch (e) {
    showFailToast(e.message || '网络错误')
  } finally {
    loading.value = false
  }
}

async function addToCart() {
  if (!userStore.loggedIn) {
    router.push('/login')
    return
  }
  try {
    const res = await post('/cart', {
      productId: product.value.id,
      quantity: quantity.value
    })
    if (res.code === 200) {
      showSuccessToast('已加入购物车')
      cartStore.fetch()
    } else {
      showFailToast(res.message || '加入失败')
    }
  } catch (e) {
    showFailToast(e.message || '网络错误')
  }
}

function buyNow() {
  if (!userStore.loggedIn) {
    router.push('/login')
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

// ── Comments ──
async function fetchComments() {
  commentLoading.value = true
  try {
    const res = await get('/comments', {
      productId: route.params.id,
      page: commentPage.value,
      pageSize: 10
    })
    if (res.code === 200) {
      const list = res.data.list || res.data || []
      comments.value = [...comments.value, ...list]
      if (list.length < 10) commentFinished.value = true
    }
  } catch (e) {
    // silently fail for comments
  } finally {
    commentLoading.value = false
  }
}

function onLoadComments() {
  commentPage.value++
  fetchComments()
}

function openCommentForm() {
  if (!userStore.loggedIn) {
    router.push('/login')
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
  }
}
</script>

<template>
  <div class="product-detail">
    <!-- Loading skeleton -->
    <template v-if="loading">
      <Skeleton title :row="2" />
      <Skeleton title :row="4" style="margin-top:16px" />
    </template>

    <!-- Content -->
    <template v-else-if="product">
      <!-- Image area -->
      <div class="image-section">
        <Swipe v-if="images.length > 1" :autoplay="3000" indicator-color="white" class="product-swipe">
          <SwipeItem v-for="(img, idx) in images" :key="idx">
            <img :src="fixImg(img)" fit="cover" class="product-image" />
          </SwipeItem>
        </Swipe>
        <img
          v-else-if="images.length === 1"
          :src="fixImg(images[0])"
          fit="cover"
          class="product-image"
        />
        <Empty v-else description="暂无图片" class="no-image" />
      </div>

      <!-- Basic info -->
      <CellGroup inset style="margin-top:12px">
        <Cell :title="product.name" :label="product.intro || ''">
          <template #title>
            <span class="product-name">{{ product.name }}</span>
          </template>
        </Cell>
        <Cell>
          <template #title>
            <span class="price-label">价格</span>
          </template>
          <template #value>
            <span class="price-value">&yen;{{ product.price }}</span>
          </template>
        </Cell>
        <Cell title="库存">
          <template #value>
            <Tag :type="inStock ? 'success' : 'danger'" size="medium">
              {{ inStock ? '有货 (' + product.stock + ')' : '缺货' }}
            </Tag>
          </template>
        </Cell>
        <Cell title="数量">
          <template #value>
            <Stepper
              v-model="quantity"
              :min="1"
              :max="product.stock || 1"
              :disabled="!inStock"
              integer
            />
          </template>
        </Cell>
      </CellGroup>

      <!-- Detail description -->
      <CellGroup inset style="margin-top:12px" v-if="product.detail">
        <Cell title="商品详情" />
        <div class="detail-content" v-html="product.detail" />
      </CellGroup>

      <!-- Comment section -->
      <Divider>用户评价</Divider>

      <div class="comment-actions">
        <Button type="primary" size="small" @click="openCommentForm">写评价</Button>
      </div>

      <List
        v-model:loading="commentLoading"
        :finished="commentFinished"
        finished-text="没有更多了"
        @load="onLoadComments"
      >
        <template v-if="comments.length">
          <CellGroup inset>
            <Cell v-for="c in comments" :key="c.id || c.commentId">
              <template #title>
                <div class="comment-header">
                  <span class="comment-user">{{ c.username || c.userName || '匿名' }}</span>
                  <Rate v-model="c.rating" readonly :size="14" />
                </div>
              </template>
              <template #label>
                <div class="comment-content">{{ c.content }}</div>
                <div class="comment-time">{{ c.createTime || c.time || '' }}</div>
              </template>
            </Cell>
          </CellGroup>
        </template>
        <Empty v-else-if="!commentLoading" description="暂无评价" />
      </List>

      <!-- Bottom action bar -->
      <div style="height:70px" />
      <ActionBar safe-area-inset-bottom>
        <ActionBarIcon icon="cart-o" text="购物车" to="/cart" />
        <ActionBarIcon icon="chat-o" text="客服" />
        <ActionBarButton
          type="danger"
          color="linear-gradient(to right, #ff6034, #ee0a24)"
          text="加入购物车"
          @click="addToCart"
          :disabled="!inStock"
        />
        <ActionBarButton
          type="primary"
          color="linear-gradient(to right, #07c160, #10aeff)"
          text="立即购买"
          @click="buyNow"
          :disabled="!inStock"
        />
      </ActionBar>
    </template>

    <!-- Not found -->
    <Empty v-else description="商品不存在" style="margin-top:100px">
      <Button type="primary" @click="router.push('/')">返回首页</Button>
    </Empty>

    <!-- Comment form popup -->
    <Popup
      v-model:show="showCommentPopup"
      position="bottom"
      round
      :style="{ height: '50%' }"
      safe-area-inset-bottom
    >
      <div class="comment-form">
        <h3>发表评价</h3>
        <div class="rating-row">
          <span>评分：</span>
          <Rate v-model="commentForm.rating" />
        </div>
        <Field
          v-model="commentForm.content"
          type="textarea"
          rows="4"
          placeholder="说点什么吧..."
          maxlength="500"
          show-word-limit
        />
        <div class="comment-form-btns">
          <Button round @click="showCommentPopup = false">取消</Button>
          <Button round type="primary" @click="submitComment">提交</Button>
        </div>
      </div>
    </Popup>
  </div>
</template>

<style scoped>
.product-detail {
  min-height: 100vh;
  background: #f5f5f5;
}

.image-section {
  background: #fff;
}

.product-swipe,
.product-image {
  width: 100%;
  height: 375px;
}

.no-image {
  padding: 60px 0;
  background: #fff;
}

.product-name {
  font-size: 18px;
  font-weight: 700;
  color: #323233;
  line-height: 1.4;
}

.price-label {
  font-size: 14px;
  color: #969799;
}

.price-value {
  font-size: 22px;
  font-weight: 700;
  color: #ee0a24;
}

.detail-content {
  padding: 12px 16px;
  font-size: 14px;
  color: #646566;
  line-height: 1.6;
  background: #fff;
  word-break: break-all;
}

.detail-content :deep(img) {
  max-width: 100%;
  height: auto;
}

.comment-actions {
  display: flex;
  justify-content: flex-end;
  padding: 0 16px 8px;
}

.comment-header {
  display: flex;
  align-items: center;
  gap: 8px;
}

.comment-user {
  font-size: 14px;
  font-weight: 600;
  color: #323233;
}

.comment-content {
  font-size: 14px;
  color: #323233;
  line-height: 1.5;
  margin-top: 6px;
}

.comment-time {
  font-size: 12px;
  color: #c8c9cc;
  margin-top: 4px;
}

/* Comment form popup */
.comment-form {
  padding: 20px 16px;
}

.comment-form h3 {
  text-align: center;
  font-size: 18px;
  margin: 0 0 16px;
  color: #323233;
}

.rating-row {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
  font-size: 14px;
  color: #646566;
}

.comment-form-btns {
  display: flex;
  gap: 12px;
  margin-top: 16px;
}
</style>
