<script setup>
import { ref, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import {
  NavBar, Tabs, Tab, PullRefresh, List,
  Empty, Tag, Image, Button, showToast, showDialog
} from 'vant'
import { get, post, put } from '../api'
import { fixImg } from '../utils/img'
import { useUserStore } from '../stores/user'

const router = useRouter()
const userStore = useUserStore()

if (!userStore.loggedIn) {
  router.replace('/login')
}

// ── Tab config ──
const tabs = [
  { title: '全部', status: '' },
  { title: '待付款', status: '待付款' },
  { title: '已付款', status: '已付款' },
  { title: '已发货', status: '已发货' },
  { title: '已收货', status: '已收货' },
  { title: '已取消', status: '已取消' }
]
const activeTab = ref(0)
const currentStatus = computed(() => tabs[activeTab.value].status)

// ── Data state ──
const orders = ref([])
const refreshing = ref(false)
const loading = ref(false)
const finished = ref(false)
const fetched = ref(false)
const page = ref(0)
const PAGE_SIZE = 10

const displayOrders = computed(() =>
  orders.value.slice(0, (page.value + 1) * PAGE_SIZE)
)

// ── API helpers (form-encoded body for Java req.getParameter) ──
function formBody(obj) {
  const p = new URLSearchParams()
  for (const [k, v] of Object.entries(obj)) {
    if (v != null) p.append(k, v)
  }
  return p
}

// ── Fetch ──
async function fetchOrders() {
  const params = {}
  if (currentStatus.value) params.status = currentStatus.value
  try {
    const res = await get('/orders', params)
    if (res.code === 200) {
      orders.value = Array.isArray(res.data) ? res.data : []
    } else {
      showToast(res.message || '加载失败')
      orders.value = []
    }
  } catch {
    showToast('网络异常，请重试')
    orders.value = []
  }
}

// ── Refresh ──
async function onRefresh() {
  refreshing.value = true
  try {
    page.value = 0
    finished.value = false
    fetched.value = false
    await fetchOrders()
    fetched.value = true
    finished.value = orders.value.length === 0
  } finally {
    refreshing.value = false
  }
}

// ── Load more (client-side pagination) ──
async function onLoad() {
  if (refreshing.value) return

  if (!fetched.value) {
    loading.value = true
    try {
      await fetchOrders()
      fetched.value = true
      page.value = 0
      finished.value = orders.value.length === 0
    } finally {
      loading.value = false
    }
    return
  }

  loading.value = true
  await new Promise(r => setTimeout(r, 300))
  page.value++
  loading.value = false
  finished.value = displayOrders.value.length >= orders.value.length
}

// ── Tab switch ──
function onTabChange(index) {
  activeTab.value = index
  orders.value = []
  page.value = 0
  finished.value = false
  fetched.value = false
}

// ── Actions ──
async function payOrder(orderId) {
  try {
    await showDialog({ title: '确认支付', message: '确认支付该订单？' })
  } catch { return }

  const res = await post('/payment', formBody({ orderId }))
  if (res.code === 200) {
    showToast('支付成功')
    onRefresh()
  } else {
    showToast(res.message || '支付失败')
  }
}

async function cancelOrder(orderId) {
  try {
    await showDialog({ title: '取消订单', message: '确认取消该订单？' })
  } catch { return }

  const res = await put('/order/status', formBody({ orderId, action: 'cancel' }))
  if (res.code === 200) {
    showToast('已取消')
    onRefresh()
  } else {
    showToast(res.message || '操作失败')
  }
}

async function confirmOrder(orderId) {
  try {
    await showDialog({ title: '确认收货', message: '确认已收到商品？' })
  } catch { return }

  const res = await put('/order/status', formBody({ orderId, action: 'confirm' }))
  if (res.code === 200) {
    showToast('已确认收货')
    onRefresh()
  } else {
    showToast(res.message || '操作失败')
  }
}

// ── Helpers ──
function formatTime(val) {
  if (!val) return ''
  let ms
  if (typeof val === 'object' && val !== null && val.fastTime) {
    ms = val.fastTime
  } else if (typeof val === 'number') {
    ms = val
  } else if (typeof val === 'string') {
    ms = Date.parse(val)
  } else {
    return ''
  }
  if (isNaN(ms)) return ''
  const d = new Date(ms)
  const pad = n => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`
}

function statusTagType(status) {
  const map = {
    '待付款': 'warning',
    '已付款': 'primary',
    '已发货': '',
    '已收货': 'success',
    '已取消': ''
  }
  return map[status] || ''
}

function statusTagColor(status) {
  const map = {
    '已发货': '#722ed1',
    '已取消': '#999'
  }
  return map[status] || undefined
}

function actionsFor(status) {
  const map = {
    '待付款': ['pay', 'cancel'],
    '已付款': ['cancel'],
    '已发货': ['confirm']
  }
  return map[status] || []
}

function actionText(action) {
  const map = { pay: '立即支付', cancel: '取消订单', confirm: '确认收货' }
  return map[action] || action
}

function actionType(action) {
  return action === 'cancel' ? 'default' : 'primary'
}
</script>

<template>
  <div class="orders-page">
    <van-nav-bar title="我的订单" left-arrow fixed placeholder @click-left="router.back" />

    <van-tabs v-model:active="activeTab" @change="onTabChange" sticky offset-top="46">
      <van-tab v-for="tab in tabs" :key="tab.status" :title="tab.title" />
    </van-tabs>

    <van-pull-refresh v-model="refreshing" @refresh="onRefresh">
      <van-list
        v-model:loading="loading"
        :finished="finished"
        finished-text="— 没有更多了 —"
        loading-text="加载中..."
        @load="onLoad"
      >
        <van-empty v-if="!loading && fetched && orders.length === 0" description="暂无订单" />

        <div v-for="order in displayOrders" :key="order.orderId" class="order-card">
          <!-- Header -->
          <div class="order-header">
            <div class="order-meta">
              <span class="order-id">订单号：{{ order.orderId }}</span>
              <span class="order-time">{{ formatTime(order.createTime) }}</span>
            </div>
            <van-tag
              :type="statusTagType(order.status)"
              :color="statusTagColor(order.status)"
              size="medium"
              round
            >
              {{ order.status }}
            </van-tag>
          </div>

          <!-- Items -->
          <div class="order-items">
            <div
              v-for="item in order.items"
              :key="item.productId"
              class="order-item"
              @click="router.push('/product/' + item.productId)"
            >
              <img
                :src="fixImg(item.productPic)"
                style="width:64px;height:64px;object-fit:cover;border-radius:6px"
                @error="$event.target.src='data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%2264%22 height=%2264%22><rect fill=%22%23f5f5f5%22 width=%2264%22 height=%2264%22 rx=%226%22/><text x=%2232%22 y=%2245%22 text-anchor=%22middle%22 fill=%22%23ccc%22 font-size=%2224%22>🌸</text></svg>'"
              />
              <div class="item-info">
                <span class="item-name">{{ item.productName }}</span>
                <span class="item-price">&yen;{{ item.productPrice.toFixed(2) }} x {{ item.quantity }}</span>
              </div>
            </div>
          </div>

          <!-- Footer -->
          <div class="order-footer">
            <span class="order-total">
              共 {{ order.totalCount }} 件 &nbsp; 合计：<strong>&yen;{{ order.totalAmount.toFixed(2) }}</strong>
            </span>
            <div class="order-actions" v-if="actionsFor(order.status).length">
              <van-button
                v-for="act in actionsFor(order.status)"
                :key="act"
                :type="actionType(act)"
                size="small"
                round
                @click="
                  act === 'pay' ? payOrder(order.orderId) :
                  act === 'cancel' ? cancelOrder(order.orderId) :
                  act === 'confirm' ? confirmOrder(order.orderId) : null
                "
              >
                {{ actionText(act) }}
              </van-button>
            </div>
          </div>
        </div>
      </van-list>
    </van-pull-refresh>
  </div>
</template>

<style scoped>
.orders-page {
  min-height: 100vh;
  background: #f5f5f5;
  padding-bottom: 20px;
}

.order-card {
  margin: 10px 12px;
  background: #fff;
  border-radius: 10px;
  overflow: hidden;
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 14px 4px;
}

.order-meta {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.order-id {
  font-size: 13px;
  color: #666;
}

.order-time {
  font-size: 11px;
  color: #999;
}

.order-items {
  padding: 8px 14px;
}

.order-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 6px 0;
  cursor: pointer;
}

.order-item:not(:last-child) {
  border-bottom: 1px solid #f5f5f5;
}

.item-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
  overflow: hidden;
}

.item-name {
  font-size: 14px;
  color: #323233;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.item-price {
  font-size: 12px;
  color: #999;
}

.order-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 14px 14px;
  border-top: 1px solid #f5f5f5;
}

.order-total {
  font-size: 13px;
  color: #333;
}

.order-total strong {
  color: #ee0a24;
  font-size: 14px;
}

.order-actions {
  display: flex;
  gap: 8px;
}

/* Vant overrides for tabs inside sticky + fixed nav */
:deep(.van-tabs__wrap) {
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
}

:deep(.van-pull-refresh) {
  min-height: calc(100vh - 90px);
}
</style>
