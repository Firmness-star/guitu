<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { get, post } from '../api'
import { showToast, showSuccessToast } from 'vant'

const route = useRoute()
const router = useRouter()

const orderId = ref(route.query.orderId || '')
const payMethod = ref(route.query.payMethod || 'alipay')
const order = ref(null)
const loading = ref(false)
const paying = ref(false)

function formatTime(val) {
  if (!val) return ''
  let ms = typeof val === 'string' ? Date.parse(val) : (typeof val === 'number' ? val : null)
  if (!ms || isNaN(ms)) return ''
  const d = new Date(ms)
  const pad = n => String(n).padStart(2, '0')
  return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate()) + ' ' + pad(d.getHours()) + ':' + pad(d.getMinutes())
}
const payMethods = [
  { value: 'alipay', label: '支付宝', icon: 'alipay' },
  { value: 'wechat', label: '微信支付', icon: 'wechat' },
  { value: 'bank', label: '银行卡', icon: 'credit-pay' }
]

function formBody(obj) {
  const p = new URLSearchParams()
  for (const [k, v] of Object.entries(obj)) if (v != null) p.append(k, v)
  return p
}

onMounted(async () => {
  if (!orderId.value) { router.replace('/orders'); return }
  try {
    const res = await get('/orders', {})
    if (res.code === 200) {
      const orders = Array.isArray(res.data) ? res.data : (res.data.list || [])
      order.value = orders.find(o => o.orderId === orderId.value)
    }
    if (!order.value) { showToast('订单不存在'); router.replace('/orders') }
  } catch { showToast('加载失败') }
})

async function doPay() {
  paying.value = true
  try {
    const res = await post('/payment', formBody({ orderId: orderId.value }))
    if (res.code === 200) {
      showSuccessToast('支付成功')
      setTimeout(() => {
        router.replace({
          path: '/payment-success',
          query: {
            orderNo: orderId.value,
            amount: order.value?.totalAmount || order.value?.actualAmount || '0',
            method: payMethod.value
          }
        })
      }, 600)
    } else { showToast(res.message || '支付失败') }
  } catch (e) { showToast(e.message || '网络错误') }
  finally { paying.value = false }
}
</script>

<template>
  <div class="payment-page">
    <van-nav-bar title="订单支付" left-arrow fixed placeholder @click-left="router.back" />
    <div class="payment-content">
      <div v-if="order" class="order-summary">
        <van-cell-group inset>
          <van-cell title="订单号" :value="order.orderId" />
          <van-cell title="下单时间" :value="formatTime(order.createTime)" />
          <van-cell title="商品数量" :value="order.totalCount + '件'" />
          <van-cell title="收货信息" :label="(order.receiverName||'') + ' ' + (order.receiverPhone||'')" v-if="order.receiverName">
            <template #value><span class="addr-text">{{ order.receiverAddress }}</span></template>
          </van-cell>
          <van-cell title="应付金额">
            <template #value><span class="amount">&yen;{{ order.totalAmount }}</span></template>
          </van-cell>
        </van-cell-group>
      </div>
      <van-cell-group inset title="支付方式" style="margin-top:12px">
        <van-cell v-for="m in payMethods" :key="m.value" clickable @click="payMethod = m.value">
          <template #icon><van-icon :name="m.icon" size="24" :color="payMethod===m.value ? '#ee0a24' : '#999'" /></template>
          <template #title><span :style="{color:payMethod===m.value?'#ee0a24':'#323233',fontWeight:payMethod===m.value?'600':'400'}">{{ m.label }}</span></template>
          <template #right-icon><van-icon :name="payMethod===m.value ? 'checked' : ''" :color="payMethod===m.value ? '#ee0a24' : 'transparent'" /></template>
        </van-cell>
      </van-cell-group>
      <div class="pay-btn-wrap">
        <van-button round block type="danger" size="large" :loading="paying" loading-text="支付中..." @click="doPay">
          立即支付 {{ order ? '¥' + order.totalAmount : '' }}
        </van-button>
      </div>
      <div class="back-btn">
        <van-button round block plain type="default" @click="router.push('/orders')">返回订单列表</van-button>
      </div>

      <!-- Security tip -->
      <div class="security-tip">
        <van-icon name="info-o" size="14" color="#c8c9cc" />
        <span>归途花店不会以任何理由向您索要支付密码，请谨防诈骗</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.payment-page { min-height:100vh;background:#f5f5f5; }
.payment-content { padding:12px 12px 30px; }
.amount { font-size:22px;font-weight:700;color:#ee0a24; }
.pay-btn-wrap { margin:24px 0 12px; }
.back-btn { margin-top:8px; }
.addr-text { font-size:12px;color:#969799;max-width:160px;display:inline-block;overflow:hidden;text-overflow:ellipsis;white-space:nowrap; }
.security-tip { display:flex;align-items:center;justify-content:center;gap:6px;margin-top:20px;font-size:12px;color:#c8c9cc;line-height:1.4;text-align:center;padding:0 16px; }
</style>
