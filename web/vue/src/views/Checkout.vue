<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showToast, showLoadingToast, closeToast } from 'vant'
import { get, post } from '../api'
import { fixImg } from '../utils/img'
import { useCartStore } from '../stores/cart'
import { useUserStore } from '../stores/user'

const router = useRouter()
const cartStore = useCartStore()
const userStore = useUserStore()

// ---------- 地址 ----------
const addresses = ref([])
const selectedAddress = ref(null)
const selectedAddressId = computed({
  get: () => selectedAddress.value?.id,
  set: (val) => {
    const addr = addresses.value.find(a => a.id === val)
    if (addr) selectedAddress.value = addr
  }
})
const showAddressPopup = ref(false)
const addressLoading = ref(false)
const addressError = ref('')

async function fetchAddresses() {
  addressLoading.value = true
  addressError.value = ''
  try {
    const res = await get('/address')
    if (res.code === 200) {
      const list = res.data.list || res.data || []
      addresses.value = list
      if (list.length > 0 && !selectedAddress.value) {
        const def = list.find(a => a.isDefault) || list[0]
        selectedAddress.value = def
      }
    }
  } catch (e) {
    addressError.value = e.message || '加载地址失败'
  } finally {
    addressLoading.value = false
  }
}

function selectAddress(addr) {
  selectedAddress.value = addr
  showAddressPopup.value = false
}

function goAddAddress() {
  showAddressPopup.value = false
  router.push('/address')
}

const addressDisplay = computed(() => {
  const a = selectedAddress.value
  if (!a) return ''
  return `${a.province || ''}${a.city || ''}${a.district || ''} ${a.detailAddress || a.detail || ''}`
})

// ---------- 支付方式 ----------
const paymentMethod = ref('wechat')
const paymentOptions = [
  { name: '微信支付', value: 'wechat' },
  { name: '支付宝', value: 'alipay' },
  { name: '银行卡', value: 'bankcard' }
]

// ---------- 备注 ----------
const remark = ref('')

// ---------- 积分抵扣 ----------
const usedPoints = ref(0)
const maxPoints = computed(() => userStore.jf || 0)
const pointsRate = 100 // 100积分 = 1元
const pointsDiscountAmount = computed(() => {
  const pts = Number(usedPoints.value) || 0
  return Math.floor(pts / pointsRate)
})

function onPointsChange(val) {
  const n = Number(val)
  if (isNaN(n) || n < 0) {
    usedPoints.value = 0
    return
  }
  const maxDeduction = Math.floor((Number(cartStore.totalAmount) || 0) * 50)
  usedPoints.value = Math.min(n, maxPoints.value, maxDeduction)
}

// ---------- 金额计算 ----------
const totalPay = computed(() => {
  const amt = Number(cartStore.totalAmount) || 0
  const disc = Number(pointsDiscountAmount.value) || 0
  const raw = amt - disc
  return Math.max(raw, 0).toFixed(2)
})

// ---------- 商品清单 ----------
const cartItems = computed(() => cartStore.items || [])

// ---------- 提交订单 ----------
const submitting = ref(false)

async function submitOrder() {
  if (!selectedAddress.value) {
    showToast('请选择收货地址')
    return
  }
  if (!cartItems.value.length) {
    showToast('购物车为空')
    return
  }
  if (!userStore.loggedIn) {
    showToast('请先登录')
    router.push('/login')
    return
  }

  submitting.value = true
  showLoadingToast({ message: '提交中...', forbidClick: true })

  try {
    const addr = selectedAddress.value
    const orderData = new URLSearchParams()
    orderData.append('receiverName', addr.receiverName || addr.name || '')
    orderData.append('receiverPhone', addr.receiverPhone || addr.phone || '')
    orderData.append('receiverAddress', `${addr.province || ''}${addr.city || ''}${addr.district || ''}${addr.detailAddress || addr.detail || ''}`)
    orderData.append('remark', remark.value)
    orderData.append('payMethod', paymentMethod.value)
    orderData.append('usePoints', String(usedPoints.value))
    const res = await post('/orders', orderData)
    closeToast()
    if (res.code === 200) {
      const orderData = res.data || {}
      const orderId = orderData.id || orderData.orderId
      if (orderId) {
        closeToast()
        const addr = selectedAddress.value
        router.push({
          path: '/order-success',
          query: {
            orderNo: orderId,
            amount: orderData.totalAmount || orderData.actualAmount || '0',
            name: addr.receiverName || addr.name || '',
            phone: addr.receiverPhone || addr.phone || '',
            address: ((addr.province || '') + (addr.city || '') + (addr.district || '') + (addr.detailAddress || addr.detail || ''))
          }
        })
      } else {
        await cartStore.clear()
        router.push('/orders')
      }
    } else {
      showToast(res.message || '下单失败')
    }
  } catch (e) {
    closeToast()
    showToast(e.message || '提交失败')
  } finally {
    submitting.value = false
  }
}

// ---------- 生命周期 ----------
onMounted(async () => {
  if (!userStore.loggedIn) {
    await userStore.fetchProfile()
  }
  if (userStore.loggedIn) {
    await cartStore.fetch()
    await fetchAddresses()
  } else {
    router.replace({ path: '/login', query: { redirect: '/checkout' } })
  }
})
</script>

<template>
  <div class="checkout-page">
    <!-- 导航栏 -->
    <van-nav-bar
      title="确认订单"
      left-arrow
      fixed
      placeholder
      @click-left="router.back()"
    />

    <!-- 加载中 -->
    <div v-if="addressLoading && !addresses.length" class="checkout-loading">
      <van-loading size="24" vertical>加载中...</van-loading>
    </div>

    <template v-else>
      <!-- 收货地址 -->
      <div class="checkout-section">
        <div class="section-title">收货地址</div>
        <van-skeleton :loading="addressLoading" :row="3" animate>
          <div v-if="!selectedAddress && !addressError" class="checkout-address-empty">
            <van-cell title="请添加收货地址" is-link @click="goAddAddress">
              <template #icon>
                <van-icon name="location-o" size="20" style="margin-right:8px;color:#999" />
              </template>
            </van-cell>
          </div>
          <div v-else-if="addressError" class="checkout-address-empty">
            <van-cell :title="addressError" is-link @click="fetchAddresses">
              <template #icon>
                <van-icon name="warning-o" size="20" style="margin-right:8px;color:#ee0a24" />
              </template>
            </van-cell>
          </div>
          <van-cell
            v-else
            :title="selectedAddress?.receiverName"
            :label="addressDisplay"
            is-link
            @click="showAddressPopup = true"
          >
            <template #icon>
              <van-icon name="location-o" size="20" style="margin-right:8px;color:#ee0a24" />
            </template>
            <template #value>
              {{ selectedAddress?.receiverPhone }}
            </template>
          </van-cell>
        </van-skeleton>
      </div>

      <!-- 商品清单 -->
      <div class="checkout-section">
        <div class="section-title">商品清单</div>
        <div v-if="!cartItems.length" class="checkout-empty-cart">
          <van-empty description="购物车为空" />
          <van-button type="primary" block round @click="router.push('/')">去逛逛</van-button>
        </div>
        <template v-else>
          <div v-for="item in cartItems" :key="item.productId" class="checkout-cart-item">
            <img
              :src="fixImg(item.productPic || item.pic)"
              style="width:72px;height:72px;object-fit:cover;border-radius:8px"
              width="72" height="72"
              @error="$event.target.src='data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%2272%22 height=%2272%22><rect fill=%22%23f5f5f5%22 width=%2272%22 height=%2272%22 rx=%228%22/><text x=%2236%22 y=%2245%22 text-anchor=%22middle%22 fill=%22%23ccc%22 font-size=%2220%22>🌸</text></svg>'"
            />
            <div class="item-info">
              <div class="item-name">{{ item.name || item.productName }}</div>
              <div class="item-bottom">
                <span class="item-price">&yen;{{ Number(item.price).toFixed(2) }}</span>
                <span class="item-qty">x{{ item.quantity }}</span>
              </div>
            </div>
          </div>
        </template>
      </div>

      <!-- 支付方式 -->
      <div class="checkout-section">
        <div class="section-title">支付方式</div>
        <van-radio-group v-model="paymentMethod" class="payment-radio-group">
          <van-cell
            v-for="opt in paymentOptions"
            :key="opt.value"
            clickable
            @click="paymentMethod = opt.value"
          >
            <template #title>
              <div class="payment-option">
                <span class="payment-name">{{ opt.name }}</span>
              </div>
            </template>
            <template #right-icon>
              <van-radio :name="opt.value" />
            </template>
          </van-cell>
        </van-radio-group>
      </div>

      <!-- 积分抵扣 -->
      <div class="checkout-section">
        <div class="section-title">积分抵扣</div>
        <van-cell :title="`可用积分: ${maxPoints}`" :value="`${pointsRate}积分=1元`" />
        <van-field
          v-model="usedPoints"
          type="digit"
          label="使用积分"
          placeholder="输入积分数"
          :rules="[{ pattern: /^\d*$/, message: '请输入整数' }]"
          @update:model-value="onPointsChange"
        >
          <template #extra>
            <span v-if="usedPoints > 0" class="points-discount">
              抵扣 &yen;{{ pointsDiscountAmount.toFixed(2) }}
            </span>
          </template>
        </van-field>
      </div>

      <!-- 订单备注 -->
      <div class="checkout-section">
        <van-field
          v-model="remark"
          type="textarea"
          label="订单备注"
          placeholder="选填：如有特殊要求请在此留言"
          rows="3"
          maxlength="200"
          autosize
          show-word-limit
        />
      </div>

      <!-- 费用明细 -->
      <div class="checkout-section">
        <div class="section-title">费用明细</div>
        <van-cell-group>
          <van-cell title="商品合计">
            <template #value>
              <span class="price-text">&yen;{{ Number(cartStore.totalAmount).toFixed(2) }}</span>
            </template>
          </van-cell>
          <van-cell v-if="pointsDiscountAmount > 0" title="积分抵扣">
            <template #value>
              <span class="discount-text">-&yen;{{ pointsDiscountAmount.toFixed(2) }}</span>
            </template>
          </van-cell>
          <van-cell title="运费">
            <template #value>
              <span class="free-shipping">免运费</span>
            </template>
          </van-cell>
        </van-cell-group>
      </div>

      <!-- 继续购物 -->
      <div class="continue-link" @click="router.push('/')">
        继续购物
      </div>

      <!-- 底部占位 (给 submit-bar 留空间) -->
      <div style="height:60px" />
    </template>

    <!-- 提交栏 -->
    <van-submit-bar
      :price="Number(totalPay) * 100"
      button-text="提交订单"
      :loading="submitting"
      currency="&yen;"
      @submit="submitOrder"
    >
      <template #default>
        <span class="submit-bar-label">实付：</span>
      </template>
    </van-submit-bar>

    <!-- 地址选择弹窗 -->
    <van-action-sheet
      v-model:show="showAddressPopup"
      title="选择收货地址"
      :close-on-click-action="false"
    >
      <div class="address-sheet">
        <div v-if="!addresses.length" class="address-sheet-empty">
          <van-empty description="暂无地址" />
          <van-button type="primary" block round @click="goAddAddress">
            新增收货地址
          </van-button>
        </div>
        <van-address-list
          v-else
          v-model="selectedAddressId"
          :list="addresses.map(a => ({
            id: a.id,
            name: a.receiverName || a.name,
            tel: a.receiverPhone || a.phone,
            address: `${a.province || ''}${a.city || ''}${a.district || ''} ${a.detail || ''}`,
            isDefault: a.isDefault
          }))"
          default-tag-text="默认"
          @select="(item) => {
            const found = addresses.find(a => a.id === item.id)
            if (found) selectAddress(found)
          }"
        />
        <div class="address-sheet-footer">
          <van-button type="primary" size="small" plain @click="goAddAddress">
            新增地址
          </van-button>
        </div>
      </div>
    </van-action-sheet>
  </div>
</template>

<style scoped>
.checkout-page {
  min-height: 100vh;
  background: #f5f5f5;
  padding-bottom: 60px;
}

.checkout-loading {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 200px;
}

.checkout-section {
  margin-bottom: 12px;
  background: #fff;
  border-radius: 0;
}

.section-title {
  padding: 14px 16px 8px;
  font-size: 15px;
  font-weight: 600;
  color: #323233;
}

.checkout-address-empty {
  padding: 0 0 12px;
}

.checkout-empty-cart {
  padding: 20px 16px;
}

.checkout-cart-item {
  display: flex;
  padding: 12px 16px;
  border-bottom: 1px solid #f5f5f5;
}

.checkout-cart-item:last-child {
  border-bottom: none;
}

.item-image {
  flex-shrink: 0;
  border: 1px solid #ebedf0;
  border-radius: 8px;
  overflow: hidden;
}

.image-placeholder {
  width: 72px;
  height: 72px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f7f8fa;
}

.item-info {
  flex: 1;
  margin-left: 12px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  min-width: 0;
}

.item-name {
  font-size: 14px;
  color: #323233;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.item-bottom {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
}

.item-price {
  font-size: 14px;
  font-weight: 600;
  color: #ee0a24;
}

.item-qty {
  font-size: 13px;
  color: #969799;
}

.payment-radio-group .van-cell {
  align-items: center;
}

.payment-option {
  display: flex;
  align-items: center;
}

.payment-name {
  font-size: 14px;
  color: #323233;
}

.points-discount {
  font-size: 12px;
  color: #ee0a24;
}

.price-text {
  font-weight: 600;
  color: #323233;
}

.free-shipping {
  color: #07c160;
  font-size: 13px;
}

.discount-text {
  font-weight: 600;
  color: #ee0a24;
}

.submit-bar-label {
  font-size: 14px;
  color: #323233;
  margin-right: 4px;
}

.address-sheet {
  max-height: 60vh;
  overflow-y: auto;
  padding-bottom: 16px;
}

.address-sheet-empty {
  padding: 20px 16px;
}

.address-sheet-footer {
  padding: 12px 16px;
  text-align: center;
  border-top: 1px solid #ebedf0;
}

.free-shipping { font-size: 14px; color: #27ae60; font-weight: 600; }

.continue-link {
  text-align: center; padding: 16px;
  font-size: 13px; color: #1989fa; cursor: pointer; min-height: 44px;
  display: flex; align-items: center; justify-content: center;
}
.continue-link:active { opacity: 0.7; }
</style>
