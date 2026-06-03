<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { Icon, Button, Cell, CellGroup, Tag } from 'vant'

const router = useRouter()
const route = useRoute()

const orderNo = route.query.orderNo || ''
const orderAmount = route.query.amount || '0'
const receiverName = route.query.name || ''
const receiverPhone = route.query.phone || ''
const receiverAddress = route.query.address || ''
const orderStatus = '待付款'

function goPayment() {
  router.push('/payment?orderId=' + orderNo + '&payMethod=alipay')
}

function goOrders() {
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
    <h1 class="success-title">订单提交成功！</h1>
    <p class="success-desc">感谢您的购买，我们将尽快为您安排发货</p>

    <CellGroup inset class="order-card">
      <Cell title="订单编号" :value="orderNo" />
      <Cell title="订单状态">
        <template #value>
          <Tag type="warning" round>{{ orderStatus }}</Tag>
        </template>
      </Cell>
      <Cell title="收货人" :value="receiverName + ' ' + receiverPhone" />
      <Cell title="收货地址" :value="receiverAddress" />
      <Cell title="应付金额">
        <template #value>
          <span class="amount">&yen;{{ orderAmount }}</span>
        </template>
      </Cell>
    </CellGroup>

    <div class="btn-group">
      <Button round block class="btn-pay" @click="goPayment">立即支付</Button>
      <Button round block plain class="btn-orders" @click="goOrders">查看订单</Button>
    </div>

    <div class="home-link" @click="goHome">
      <Icon name="home-o" /> 返回首页
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
  font-size: 18px;
  font-weight: 700;
  color: #ee0a24;
}
.btn-group {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
}
.btn-pay {
  flex: 1;
  background: linear-gradient(135deg, #ff6b6b, #ee0a24);
  color: #fff;
  border: none;
  min-height: 44px;
  font-size: 15px;
  font-weight: 600;
}
.btn-orders {
  flex: 1;
  min-height: 44px;
  font-size: 15px;
}
.home-link {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  color: #969799;
  font-size: 13px;
  cursor: pointer;
  padding: 10px;
}
.home-link:active { color: #ee0a24; }
</style>