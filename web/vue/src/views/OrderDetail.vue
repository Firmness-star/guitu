<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { showToast, showDialog } from 'vant'
import { get, post, put } from '../api'
import { fixImg } from '../utils/img'
import { useUserStore } from '../stores/user'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const order = ref(null)
const loading = ref(true)

function formBody(obj) {
  const p = new URLSearchParams()
  for (const [k, v] of Object.entries(obj)) {
    if (v != null) p.append(k, v)
  }
  return p
}

async function fetchOrder() {
  loading.value = true
  try {
    const res = await get('/orders', { orderId: route.params.id })
    if (res.code === 200) {
      const list = res.data?.list || res.data || []
      order.value = Array.isArray(list) ? list.find(o => o.orderId === route.params.id) : list
    }
  } catch (e) { showToast(e.message || '加载失败') }
  finally { loading.value = false }
}

const statusTagType = (s) => ({ '待付款': 'warning', '已付款': 'primary', '已发货': '', '已收货': 'success', '已完成': 'success', '已取消': '' })[s] || ''

async function cancelOrder(orderId) {
  try { await showDialog({ title: '取消订单', message: '确认取消该订单？' }) } catch { return }
  const res = await put('/order/status', formBody({ orderId, action: 'cancel' }))
  if (res.code === 200) { showToast('已取消'); fetchOrder() }
  else showToast(res.message || '操作失败')
}

async function confirmOrder(orderId) {
  try { await showDialog({ title: '确认收货', message: '确认已收到商品？' }) } catch { return }
  const res = await put('/order/status', formBody({ orderId, action: 'confirm' }))
  if (res.code === 200) { showToast('已确认收货'); fetchOrder() }
  else showToast(res.message || '操作失败')
}

function formatTime(val) {
  if (!val) return ''
  let ms = typeof val === 'number' ? val : Date.parse(val)
  if (isNaN(ms)) return ''
  const d = new Date(ms)
  const pad = n => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`
}

onMounted(() => { if (!userStore.loggedIn) { router.replace('/login'); return }; fetchOrder() })
</script>

<template>
  <div class="order-detail-page">
    <van-nav-bar title="订单详情" left-arrow fixed placeholder safe-area-inset-top @click-left="router.back" />

    <div v-if="loading" style="display:flex;align-items:center;justify-content:center;padding:120px 0;">
      <van-loading type="spinner" size="28" color="#ee0a24" />
    </div>

    <van-empty v-else-if="!order" description="订单不存在" />

    <template v-else>
      <!-- Status -->
      <div class="od-status-card">
        <div class="od-status-icon">
          <van-icon :name="order.status === '待付款' ? 'clock-o' : order.status === '已付款' ? 'checked' : order.status === '已发货' ? 'logistics' : order.status === '已收货' || order.status === '已完成' ? 'passed' : 'close'" size="28" />
        </div>
        <div class="od-status-text">{{ order.status }}</div>
        <div class="od-status-sub" v-if="order.status === '待付款'">请尽快完成支付</div>
        <div class="od-status-sub" v-else-if="order.status === '已发货'">商品正在运输中，请留意签收</div>
      </div>

      <!-- Receiver -->
      <div class="od-section">
        <div class="od-section-title">
          <van-icon name="location-o" size="16" color="#ee0a24" />
          收货信息
        </div>
        <div class="od-receiver">
          <span>{{ order.receiverName }}</span>
          <span class="od-phone">{{ order.receiverPhone }}</span>
        </div>
        <div class="od-address">{{ order.receiverAddress }}</div>
      </div>

      <!-- Items -->
      <div class="od-section">
        <div class="od-section-title">
          <van-icon name="shop-o" size="16" color="#ee0a24" />
          商品清单
        </div>
        <div v-for="item in (order.items || [])" :key="item.productId" class="od-item" @click="router.push('/product/' + item.productId)">
          <img :src="fixImg(item.productPic)" class="od-item-img"
            @error="$event.target.src='data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%2264%22 height=%2264%22><rect fill=%22%23f5f5f5%22 width=%2264%22 height=%2264%22 rx=%226%22/><text x=%2232%22 y=%2245%22 text-anchor=%22middle%22 fill=%22%23ccc%22 font-size=%2220%22>🌸</text></svg>'" />
          <div class="od-item-info">
            <div class="od-item-name">{{ item.productName }}</div>
            <div class="od-item-price">&yen;{{ Number(item.productPrice).toFixed(2) }} x {{ item.quantity }}</div>
          </div>
        </div>
      </div>

      <!-- Logistics -->
      <div class="od-section" v-if="order.wlNo && (order.status === '已发货' || order.status === '已收货' || order.status === '已完成')">
        <div class="od-section-title">
          <van-icon name="logistics" size="16" color="#1989fa" />
          物流信息
        </div>
        <div class="od-logistics">物流单号: {{ order.wlNo }}</div>
      </div>

      <!-- Remark -->
      <div class="od-section" v-if="order.remark">
        <div class="od-section-title">
          <van-icon name="notes-o" size="16" color="#999" />
          备注
        </div>
        <div class="od-remark">{{ order.remark }}</div>
      </div>

      <!-- Summary -->
      <div class="od-section">
        <div class="od-summary-row">
          <span>订单编号</span>
          <span class="od-mono">{{ order.orderId }}</span>
        </div>
        <div class="od-summary-row">
          <span>下单时间</span>
          <span>{{ formatTime(order.createTime) }}</span>
        </div>
        <div class="od-summary-row">
          <span>商品件数</span>
          <span>{{ order.totalCount }} 件</span>
        </div>
        <div class="od-summary-row od-total-row">
          <span>实付金额</span>
          <span class="od-total-amount">&yen;{{ Number(order.totalAmount).toFixed(2) }}</span>
        </div>
      </div>

      <!-- Actions -->
      <div class="od-actions" v-if="['待付款','已发货'].includes(order.status)">
        <van-button v-if="order.status === '待付款'" type="danger" round block @click="router.push({ path: '/payment', query: { orderId: order.orderId } })">立即支付</van-button>
        <van-button v-if="order.status === '待付款'" plain round block @click="cancelOrder(order.orderId)" style="margin-top:8px">取消订单</van-button>
        <van-button v-if="order.status === '已发货'" type="primary" round block @click="confirmOrder(order.orderId)">确认收货</van-button>
      </div>

      <div style="height:20px" />
    </template>
  </div>
</template>

<style scoped>
.order-detail-page { min-height: 100vh; background: #f5f5f5; padding-bottom: 20px; }
.od-status-card { text-align: center; padding: 24px 16px; background: #fff; margin-bottom: 10px; }
.od-status-icon { margin-bottom: 8px; color: #ee0a24; }
.od-status-text { font-size: 20px; font-weight: 700; color: #333; margin-bottom: 4px; }
.od-status-sub { font-size: 13px; color: #999; }
.od-section { background: #fff; margin-bottom: 10px; padding: 14px 16px; }
.od-section-title { font-size: 14px; font-weight: 600; color: #333; margin-bottom: 10px; display: flex; align-items: center; gap: 6px; }
.od-receiver { font-size: 15px; font-weight: 600; color: #333; }
.od-phone { color: #666; font-weight: 400; margin-left: 8px; font-size: 13px; }
.od-address { font-size: 13px; color: #666; margin-top: 4px; }
.od-item { display: flex; gap: 10px; padding: 8px 0; cursor: pointer; }
.od-item + .od-item { border-top: 1px solid #f5f5f5; }
.od-item-img { width: 64px; height: 64px; border-radius: 6px; object-fit: cover; flex-shrink: 0; display: block; }
.od-item-info { flex: 1; min-width: 0; }
.od-item-name { font-size: 13px; color: #333; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; margin-bottom: 4px; }
.od-item-price { font-size: 13px; color: #666; }
.od-logistics { font-size: 14px; color: #1989fa; }
.od-remark { font-size: 13px; color: #666; line-height: 1.6; }
.od-summary-row { display: flex; justify-content: space-between; font-size: 13px; padding: 6px 0; color: #666; }
.od-mono { font-size: 12px; color: #999; }
.od-total-row { border-top: 1px solid #f0f0f0; padding-top: 10px; margin-top: 4px; }
.od-total-amount { font-size: 18px; font-weight: 800; color: #ee0a24; }
.od-actions { padding: 16px; }
</style>
