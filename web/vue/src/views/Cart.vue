<script setup>
import { ref, computed, reactive, watch, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useCartStore } from '../stores/cart'
import { useUserStore } from '../stores/user'
import { fixImg } from '../utils/img'
import {
  NavBar, Checkbox, Button, Empty, Loading, Icon,
  showConfirmDialog, showToast, showSuccessToast, showFailToast
} from 'vant'

const router = useRouter()
const cartStore = useCartStore()
const userStore = useUserStore()

const loading = ref(true)
const editMode = ref(false)
const checked = reactive({})

const validItems = computed(() =>
  cartStore.items.filter(i => i.status === 1 && i.stock > 0)
)
const invalidItems = computed(() =>
  cartStore.items.filter(i => i.status !== 1 || i.stock <= 0)
)

watch(() => cartStore.items, (items) => {
  items.forEach(i => {
    if (checked[i.productId] === undefined) {
      checked[i.productId] = i.isValid !== false
    }
  })
  Object.keys(checked).forEach(k => {
    if (!items.find(i => i.productId === Number(k))) delete checked[k]
  })
}, { deep: true, immediate: true })

const allChecked = computed({
  get: () =>
    validItems.value.length > 0 &&
    validItems.value.every(i => checked[i.productId]),
  set: (val) => {
    validItems.value.forEach(i => { checked[i.productId] = val })
  }
})

const checkedCount = computed(() =>
  cartStore.items.filter(i => checked[i.productId] && i.isValid !== false).length
)

const checkedTotal = computed(() => {
  let total = 0
  cartStore.items.forEach(i => {
    if (checked[i.productId] && (i.isValid !== false)) {
      total += i.productPrice * i.quantity
    }
  })
  return Math.round(total * 100) / 100
})

const checkedTotalFen = computed(() => Math.round(checkedTotal.value * 100))

async function fetchCart() {
  loading.value = true
  try {
    await cartStore.fetch()
  } catch (e) {
    showFailToast(e.message || '加载失败')
  } finally {
    loading.value = false
  }
}

async function onQuantityChange(item, qty) {
  if (qty < 1) qty = 1
  if (item.stock && qty > item.stock) qty = item.stock
  if (qty > 99) qty = 99
  try {
    await cartStore.update(item.productId, qty)
  } catch (e) {
    showFailToast(e.message || '更新失败')
  }
}

async function onDelete(item) {
  try {
    await showConfirmDialog({ title: '确认删除', message: `确定要删除「${item.productName}」吗？` })
  } catch { return }
  try {
    await cartStore.remove(item.productId)
    showToast('已删除')
  } catch (e) {
    showFailToast(e.message || '删除失败')
  }
}

async function onBatchDelete() {
  const selected = cartStore.items.filter(i => checked[i.productId])
  if (selected.length === 0) { showToast('请选择要删除的商品'); return }
  try {
    await showConfirmDialog({ title: '批量删除', message: `确定要删除选中的 ${selected.length} 件商品吗？` })
  } catch { return }
  try {
    for (const item of selected) {
      await cartStore.remove(item.productId)
    }
    showSuccessToast(`已删除 ${selected.length} 件商品`)
  } catch (e) {
    showFailToast(e.message || '删除失败')
  }
}

function goCheckout() {
  const selected = cartStore.items.filter(i =>
    checked[i.productId] && i.status === 1 && i.stock > 0
  )
  if (selected.length === 0) { showToast('请选择可购买的商品'); return }
  if (!userStore.loggedIn) { router.push('/login'); return }
  sessionStorage.setItem('checkoutItems', JSON.stringify(selected.map(i => i.productId)))
  router.push('/checkout')
}

function goProduct(id) { router.push(`/product/${id}`) }

function invalidReason(item) {
  if (item.status !== 1) return '已下架'
  if (item.stock <= 0) return '暂时缺货'
  return ''
}

function subtotal(item) {
  return (item.productPrice * item.quantity).toFixed(2)
}

onMounted(() => { fetchCart() })
</script>

<template>
  <div class="cart-page">
    <NavBar
      :title="editMode ? '编辑购物车' : '购物车'"
      left-arrow fixed placeholder safe-area-inset-top
      @click-left="router.back"
    >
      <template #right>
        <span v-if="cartStore.items.length > 0" class="edit-toggle" @click="editMode = !editMode">{{ editMode ? '完成' : '编辑' }}</span>
      </template>
    </NavBar>

    <div v-if="loading" class="loading-wrap">
      <Loading type="spinner" size="32" color="#ee0a24" />
      <p class="loading-text">加载购物车...</p>
    </div>

    <template v-else>
      <Empty
        v-if="cartStore.items.length === 0"
        description="购物车是空的" image="search" class="empty-wrap"
      >
        <Button type="primary" round class="go-shop-btn" @click="router.push('/')">去逛逛</Button>
      </Empty>

      <div v-else class="cart-body">
        <!-- 失效商品 -->
        <div v-if="invalidItems.length > 0" class="invalid-section">
          <div class="invalid-header">
            <Icon name="info-o" size="14" style="color:#c8c9cc" /> 失效商品 ({{ invalidItems.length }})
          </div>
          <div
            v-for="item in invalidItems" :key="'inv-' + item.productId"
            class="cart-card cart-card-invalid"
          >
            <div class="cart-card-img" @click="goProduct(item.productId)">
              <img :src="fixImg(item.productPic)" :alt="item.productName"
                @error="$event.target.src='data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%2280%22 height=%2280%22><rect fill=%22%23f5f5f5%22 width=%2280%22 height=%2280%22 rx=%226%22/><text x=%2240%22 y=%2250%22 text-anchor=%22middle%22 fill=%22%23ccc%22 font-size=%2224%22>🌸</text></svg>'" />
              <span class="invalid-badge">{{ invalidReason(item) }}</span>
            </div>
            <div class="cart-card-info" @click="goProduct(item.productId)">
              <div class="cart-card-name line-through">{{ item.productName }}</div>
              <div class="cart-card-price">&yen;{{ item.productPrice.toFixed(2) }}</div>
            </div>
            <div class="cart-card-del" @click="onDelete(item)">
              <Icon name="delete-o" size="18" />
            </div>
          </div>
        </div>

        <!-- 正常商品 -->
        <div v-if="validItems.length > 0" class="valid-section">
          <div class="section-header">
            <Checkbox
              v-model="allChecked"
              icon-size="18"
              checked-color="#ee0a24"
              class="all-check"
            >全选</Checkbox>
            <span class="section-sub" v-if="!editMode">合计 <b class="price-red">&yen;{{ checkedTotal.toFixed(2) }}</b></span>
            <Button
              v-if="editMode"
              type="danger" size="small" round
              :disabled="checkedCount === 0"
              @click="onBatchDelete"
            >删除 ({{ checkedCount }})</Button>
          </div>

          <div
            v-for="item in validItems" :key="'v-' + item.productId"
            class="cart-card"
            :class="{ 'swiped': false }"
          >
            <Checkbox
              :model-value="checked[item.productId]"
              @update:model-value="checked[item.productId] = $event"
              icon-size="20" checked-color="#ee0a24" class="cart-check"
            />
            <div class="cart-card-img" @click="goProduct(item.productId)">
              <img :src="fixImg(item.productPic)" :alt="item.productName"
                @error="$event.target.src='data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%2280%22 height=%2280%22><rect fill=%22%23f5f5f5%22 width=%2280%22 height=%2280%22 rx=%226%22/><text x=%2240%22 y=%2250%22 text-anchor=%22middle%22 fill=%22%23ccc%22 font-size=%2224%22>🌸</text></svg>'" />
            </div>
            <div class="cart-card-info">
              <div class="cart-card-name" @click="goProduct(item.productId)">{{ item.productName }}</div>
              <div class="cart-card-bottom">
                <div class="cart-card-price">&yen;{{ item.productPrice.toFixed(2) }}</div>
                <div class="qty-control" v-if="!editMode">
                  <button class="qty-btn" @click.stop="onQuantityChange(item, item.quantity - 1)" :disabled="item.quantity <= 1">-</button>
                  <span class="qty-val">{{ item.quantity }}</span>
                  <button class="qty-btn" @click.stop="onQuantityChange(item, item.quantity + 1)" :disabled="item.quantity >= Math.min(item.stock || 99, 99)">+</button>
                </div>
                <span class="cart-card-subtotal" v-if="!editMode">&yen;{{ subtotal(item) }}</span>
                <div class="cart-card-del" v-if="editMode" @click="onDelete(item)">
                  <Icon name="delete-o" size="18" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="bottom-spacer" />
    </template>

    <!-- 底部结算栏 -->
    <div v-if="!loading && cartStore.items.length > 0 && !editMode" class="bottom-bar">
      <div class="bottom-left">
        合计 <b class="price-red">&yen;{{ checkedTotal.toFixed(2) }}</b>
      </div>
      <button class="checkout-btn" :disabled="checkedCount === 0" @click="goCheckout">
        去结算
      </button>
    </div>
  </div>
</template>

<style scoped>
.cart-page { min-height: 100vh; background: #f5f5f5; padding-bottom: 0; }

.edit-toggle { font-size: 14px; color: #ee0a24; cursor: pointer; padding: 6px 4px; white-space: nowrap; }
.edit-toggle:active { opacity: 0.7; }

.loading-wrap { display: flex; flex-direction: column; align-items: center; padding: 140px 0; gap: 12px; }
.loading-text { font-size: 13px; color: #969799; margin: 0; }

.empty-wrap { margin-top: 60px; }
.go-shop-btn { min-width: 140px; min-height: 44px; }

/* ── Cart body ── */
.cart-body { padding: 0; }

/* ── Section header ── */
.section-header {
  display: flex; align-items: center; justify-content: space-between;
  padding: 14px 16px 10px; background: #fff; margin-bottom: 1px;
}
.section-sub { font-size: 13px; color: #999; }
.price-red { color: #ee0a24; font-weight: 700; font-size: 16px; }
.all-check { font-size: 13px; }

/* ── Invalid section ── */
.invalid-section { margin-bottom: 8px; }
.invalid-header {
  display: flex; align-items: center; gap: 6px;
  padding: 10px 16px; font-size: 13px; color: #969799; background: #fafafa;
}

/* ── Cart card ── */
.cart-card {
  display: flex; align-items: center; gap: 10px;
  background: #fff; padding: 10px 14px; margin-bottom: 1px;
  min-height: 80px;
}
.cart-card-invalid { opacity: 0.55; }
.cart-check { flex-shrink: 0; }

.cart-card-img {
  flex-shrink: 0; width: 72px; height: 72px; border-radius: 8px;
  overflow: hidden; position: relative; cursor: pointer;
}
.cart-card-img img {
  width: 72px; height: 72px; object-fit: cover; display: block;
}

.invalid-badge {
  position: absolute; inset: 0; display: flex; align-items: center;
  justify-content: center; background: rgba(0,0,0,0.45);
  color: #fff; font-size: 12px; font-weight: 600;
  border-radius: 8px;
}

.cart-card-info { flex: 1; min-width: 0; }
.cart-card-name {
  font-size: 14px; font-weight: 500; color: #323233;
  line-height: 1.3; overflow: hidden; text-overflow: ellipsis;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;
  margin-bottom: 8px; cursor: pointer;
}
.cart-card-name:active { color: #ee0a24; }
.line-through { text-decoration: line-through; color: #969799; }

.cart-card-bottom {
  display: flex; align-items: center; gap: 8px;
}
.cart-card-price {
  font-size: 15px; font-weight: 700; color: #ee0a24;
  white-space: nowrap;
}

/* ── Quantity control ── */
.qty-control {
  display: inline-flex; align-items: center;
  border: 1px solid #e5e5e5; border-radius: 6px;
  overflow: hidden; margin-left: auto;
}
.qty-btn {
  width: 30px; height: 28px; border: none; background: #f5f5f5;
  font-size: 16px; color: #666; cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  transition: background 0.15s;
}
.qty-btn:active { background: #e8e8e8; }
.qty-btn:disabled { color: #ccc; cursor: not-allowed; }
.qty-val {
  width: 36px; text-align: center; font-size: 14px;
  font-weight: 600; color: #333; user-select: none;
}

.cart-card-subtotal {
  font-size: 14px; font-weight: 700; color: #ee0a24;
  white-space: nowrap;
}

.cart-card-del {
  width: 32px; height: 32px; display: flex; align-items: center;
  justify-content: center; color: #c8c9cc; cursor: pointer;
  border-radius: 50%; flex-shrink: 0; transition: all 0.15s;
}
.cart-card-del:active { background: #fff0f0; color: #ee0a24; }

/* ── Bottom spacer ── */
.bottom-spacer { height: 70px; }

/* ── Bottom bar ── */
.bottom-bar {
  position: fixed; bottom: 0; left: 0; right: 0; z-index: 100;
  background: #fff; display: flex; align-items: center;
  justify-content: space-between; padding: 12px 16px;
  padding-bottom: calc(12px + env(safe-area-inset-bottom, 0px));
  box-shadow: 0 -2px 10px rgba(0,0,0,0.06);
}
.bottom-left { font-size: 14px; color: #666; }
.checkout-btn {
  background: #ee0a24; color: #fff; border: none;
  padding: 10px 32px; border-radius: 22px; font-size: 15px;
  font-weight: 600; cursor: pointer; transition: all 0.15s;
}
.checkout-btn:active { background: #c0392b; }
.checkout-btn:disabled { background: #ccc; cursor: not-allowed; }

/* ── Touch targets ── */
.go-shop-btn, .edit-btn, .qty-btn, .cart-card-del,
.cart-check, .cart-card-img, .cart-card-name { min-height: 44px; min-width: 44px; }

@media (max-width: 360px) {
  .cart-card-price { font-size: 13px; }
  .cart-card-subtotal { font-size: 12px; }
}
</style>
