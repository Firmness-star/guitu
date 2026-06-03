<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { Icon, Button, Cell, CellGroup, Tag, showToast } from 'vant'

const router = useRouter()
const route = useRoute()

const orderNo = route.query.orderNo || ''
const payAmount = route.query.amount || '0'
const payMethod = route.query.method || ''
const payTime = ref('')

const methodLabels = { 'alipay': '支付宝', 'wechat': '微信支付', 'bankcard': '银行卡' }

onMounted(() => {
  payTime.value = new Date().toLocaleString('zh-CN')
})

function goOrder() {
  router.push('/orders')
}

function goHome() {
  router.push('/')
}
</script>

<template>
  <div class="success-page">
    <div class="success-icon-wrap">
      <div class="success-icon-circle">
        <Icon name="success" size="48" color="#fff" />
      </div>
    </div>
    <h1 class="success-title">支付成功！</h1>
    <p class="success-desc">您的订单已支付成功，我们将尽快为您安排发货</p>

    <CellGroup inset class="order-card">
      <Cell title="订单编号" :value="orderNo" />
      <Cell title="支付金额">
        <template #value>
          <span class="amount">&yen;{{ payAmount }}</span>
        </template>
      </Cell>
      <Cell title="支付方式" :value="methodLabels[payMethod] || payMethod" v-if="payMethod" />
      <Cell title="支付时间" :value="payTime" />
    </CellGroup>

    <div class="btn-group">
      <Button round block class="btn-orders" @click="goOrder">查看订单</Button>
      <Button round block plain class="btn-home" @click="goHome">继续购物</Button>
    </div>
  </div>
</template>

<style scoped>
.success-page {
  min-height: 100vh;
  background: #f5f5f5;
  padding: 60px 16px 40px;
  text-align: center;
}
.success-icon-wrap {
  display: flex;
  justify-content: center;
  margin-bottom: 20px;
}
.success-icon-circle {
  width: 80px;
  height: 80px;
  background: #27ae60;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  animation: scaleIn 0.5s ease;
}
@keyframes scaleIn {
  0% { transform: scale(0); }
  50% { transform: scale(1.15); }
  100% { transform: scale(1); }
}
.success-title {
  font-size: 22px;
  font-weight: 700;
  color: #323233;
  margin: 0 0 8px;
}
.success-desc {
  font-size: 14px;
  color: #969799;
  margin: 0 0 30px;
}
.order-card {
  margin-bottom: 30px;
  text-align: left;
}
.amount {
  font-size: 20px;
  font-weight: 700;
  color: #ee0a24;
}
.btn-group {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
}
.btn-orders {
  flex: 1;
  background: linear-gradient(135deg, #ff6b6b, #ee0a24);
  color: #fff;
  border: none;
  min-height: 44px;
  font-size: 15px;
  font-weight: 600;
}
.btn-home {
  flex: 1;
  min-height: 44px;
  font-size: 15px;
}
</style>