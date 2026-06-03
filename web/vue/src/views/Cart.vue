<script setup>
import { ref, computed, reactive, watch, onMounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { useCartStore } from '../stores/cart'
import { useUserStore } from '../stores/user'
import { fixImg } from '../utils/img'
import {
  NavBar,
  Checkbox,
  SwipeCell,
  Stepper,
  SubmitBar,
  Empty,
  Button,
  Loading,
  Icon,
  showConfirmDialog,
  showToast,
  showSuccessToast,
  showFailToast
} from 'vant'

const router = useRouter()
const cartStore = useCartStore()
const userStore = useUserStore()

// ── State ──
const loading = ref(true)
const editMode = ref(false)

// ── Checked state ──
const checked = reactive({})

// ── Computed: valid vs invalid items ──
const validItems = computed(() =>
  cartStore.items.filter(i => i.status === 1 && i.stock > 0)
)
const invalidItems = computed(() =>
  cartStore.items.filter(i => i.status !== 1 || i.stock <= 0)
)

// ── Sync checked state ──
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

// ── Select all (valid items only) ──
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

// ── Fetch ──
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

// ── Quantity ──
async function onQuantityChange(item, qty) {
  try {
    const res = await cartStore.update(item.productId, qty)
    return res
  } catch (e) {
    showFailToast(e.message || '更新失败')
  }
}

// ── Delete single ──
async function onDelete(item) {
  try {
    await showConfirmDialog({
      title: '确认删除',
      message: `确定要删除「${item.productName}」吗？`
    })
  } catch { return }
  try {
    await cartStore.remove(item.productId)
    showToast('已删除')
  } catch (e) {
    showFailToast(e.message || '删除失败')
  }
}

// ── Batch delete ──
async function onBatchDelete() {
  const selected = cartStore.items.filter(i => checked[i.productId])
  if (selected.length === 0) {
    showToast('请选择要删除的商品')
    return
  }
  try {
    await showConfirmDialog({
      title: '批量删除',
      message: `确定要删除选中的 ${selected.length} 件商品吗？`
    })
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

// ── Checkout ──
function goCheckout() {
  const selected = cartStore.items.filter(i =>
    checked[i.productId] && i.status === 1 && i.stock > 0
  )
  if (selected.length === 0) {
    showToast('请选择可购买的商品')
    return
  }
  if (!userStore.loggedIn) {
    router.push('/login')
    return
  }
  const ids = selected.map(i => i.productId)
  sessionStorage.setItem('checkoutItems', JSON.stringify(ids))
  router.push('/checkout')
}

// ── Navigate ──
function goProduct(id) {
  router.push(`/product/${id}`)
}

// ── Invalid item helper ──
function invalidReason(item) {
  if (item.status !== 1) return '已下架'
  if (item.stock <= 0) return '暂时缺货'
  return ''
}

onMounted(() => { fetchCart() })
</script>

<template>
  <div class="cart-page">
    <!-- NavBar -->
    <NavBar
      :title="editMode ? '编辑购物车' : '购物车'"
      left-arrow
      fixed
      placeholder
      safe-area-inset-top
      @click-left="router.back"
    >
      <template #right>
        <Button
          v-if="cartStore.items.length > 0"
          :text="editMode ? '完成' : '编辑'"
          size="small"
          type="primary"
          plain
          hairline
          @click="editMode = !editMode"
          class="edit-btn"
        />
      </template>
    </NavBar>

    <!-- Loading -->
    <div v-if="loading" class="loading-wrap">
      <Loading type="spinner" size="32" color="#ee0a24" />
      <p class="loading-text">加载购物车...</p>
    </div>

    <template v-else>
      <!-- Empty -->
      <Empty
        v-if="cartStore.items.length === 0"
        description="购物车是空的"
        image="search"
        class="empty-wrap"
      >
        <Button type="primary" round class="go-shop-btn" @click="router.push('/')">
          去逛逛
        </Button>
      </Empty>

      <div v-else class="cart-body">
        <!-- ‒‒‒ Invalid Items Section ‒‒‒ -->
        <div v-if="invalidItems.length > 0" class="invalid-section">
          <div class="invalid-header">
            <Icon name="info-o" class="invalid-icon" />
            失效商品 ({{ invalidItems.length }})
          </div>
          <SwipeCell v-for="item in invalidItems" :key="'inv-' + item.productId">
            <div class="cart-item cart-item-invalid">
              <div class="cart-item-img" @click="goProduct(item.productId)">
                <img
                  :src="fixImg(item.productPic)"
                  :alt="item.productName"
                  class="item-img"
                  @error="$event.target.src='data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%2280%22 height=%2280%22><rect fill=%22%23f5f5f5%22 width=%2280%22 height=%2280%22 rx=%228%22/><text x=%2240%22 y=%2250%22 text-anchor=%22middle%22 fill=%22%23ccc%22 font-size=%2224%22></text></svg>'"
                />
                <span class="invalid-badge">{{ invalidReason(item) }}</span>
              </div>
              <div class="cart-item-info">
                <p class="item-name item-name-invalid">{{ item.productName }}</p>
                <div class="item-bottom">
                  <span class="item-price">&yen;{{ item.productPrice.toFixed(2) }}</span>
                </div>
              </div>
            </div>
            <template #right>
              <Button square type="danger" class="delete-btn" @click="onDelete(item)">删除</Button>
            </template>
          </SwipeCell>
        </div>

        <!-- ‒‒‒ Valid Items Section ‒‒‒ -->
        <div v-if="validItems.length > 0" class="valid-section">
          <SwipeCell v-for="item in validItems" :key="'v-' + item.productId">
            <div class="cart-item">
              <Checkbox
                :model-value="checked[item.productId]"
                @update:model-value="checked[item.productId] = $event"
                class="cart-checkbox"
                icon-size="22"
                checked-color="#ee0a24"
              />
              <div class="cart-item-img" @click="goProduct(item.productId)">
                <img
                  :src="fixImg(item.productPic)"
                  :alt="item.productName"
                  class="item-img"
                  @error="$event.target.src='data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%2280%22 height=%2280%22><rect fill=%22%23f5f5f5%22 width=%2280%22 height=%2280%22 rx=%228%22/><text x=%2240%22 y=%2250%22 text-anchor=%22middle%22 fill=%22%23ccc%22 font-size=%2224%22></text></svg>'"
                />
              </div>
              <div class="cart-item-info">
                <p class="item-name" @click="goProduct(item.productId)">{{ item.productName }}</p>
                <div class="item-bottom">
                  <span class="item-price">&yen;{{ item.productPrice.toFixed(2) }}</span>
                  <Stepper
                    :model-value="item.quantity"
                    :min="1"
                    :max="Math.min(item.stock, 99)"
                    integer
                    theme="round"
                    button-size="26"
                    input-width="36"
                    :disabled="editMode"
                    @change="(val) => onQuantityChange(item, val)"
                    class="item-stepper"
                  />
                </div>
              </div>
            </div>
            <template #right>
              <Button square type="danger" class="delete-btn" @click="onDelete(item)">删除</Button>
            </template>
          </SwipeCell>
        </div>
      </div>

      <!-- Bottom spacer -->
      <div class="bottom-spacer" />
    </template>

    <!-- ═══ Bottom Bar (结算/编辑模式) ═══ -->
    <template v-if="!loading && cartStore.items.length > 0">
      <!-- Edit mode bottom bar -->
      <div v-if="editMode" class="edit-bar" safe-area-inset-bottom>
        <Checkbox
          v-model="allChecked"
          icon-size="18"
          checked-color="#ee0a24"
          class="edit-all-checkbox"
        >
          全选 ({{ checkedCount }})
        </Checkbox>
        <Button
          type="danger"
          :disabled="checkedCount === 0"
          @click="onBatchDelete"
          class="batch-delete-btn"
        >
          删除 ({{ checkedCount }})
        </Button>
      </div>

      <!-- Normal mode submit bar -->
      <SubmitBar
        v-else
        :price="checkedTotalFen"
        button-text="去结算"
        button-color="#ee0a24"
        :disabled="checkedCount === 0"
        safe-area-inset-bottom
        @submit="goCheckout"
        class="cart-submit-bar"
      >
        <Checkbox
          v-model="allChecked"
          icon-size="18"
          checked-color="#ee0a24"
          class="submit-checkbox"
        >
          全选
        </Checkbox>
        <template #tip>
          <span class="submit-tip">
            合计: <b class="submit-total">&yen;{{ checkedTotal.toFixed(2) }}</b>
          </span>
        </template>
      </SubmitBar>
    </template>
  </div>
</template>

<style scoped>
.cart-page {
  min-height: 100vh;
  background: #f5f5f5;
  padding-bottom: 0;
}

/* ── NavBar ── */
.edit-btn {
  min-width: 56px;
  min-height: 32px;
  font-size: 13px;
}

/* ── Loading ── */
.loading-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 140px 0;
  gap: 12px;
}
.loading-text { font-size: 13px; color: #969799; margin: 0; }

/* ── Empty ── */
.empty-wrap { margin-top: 60px; }
.go-shop-btn { min-width: 140px; min-height: 44px; }

/* ── Cart body ── */
.cart-body { padding: 0; }

/* ── Invalid section ── */
.invalid-section {
  margin-bottom: 8px;
}
.invalid-header {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 10px 16px;
  font-size: 13px;
  color: #969799;
  background: #fafafa;
}
.invalid-icon { font-size: 14px; color: #c8c9cc; }

.cart-item-invalid {
  opacity: 0.6;
  pointer-events: none;
}

.invalid-badge {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: rgba(0,0,0,0.6);
  color: #fff;
  font-size: 12px;
  padding: 4px 12px;
  border-radius: 4px;
  white-space: nowrap;
  pointer-events: none;
}

.item-name-invalid {
  text-decoration: line-through;
  color: #969799;
}

/* ── Valid section ── */
.valid-section {
  margin-bottom: 4px;
}

/* ── Cart item ── */
.cart-item {
  display: flex;
  align-items: center;
  background: #fff;
  padding: 12px 16px;
  gap: 10px;
  margin-bottom: 1px;
  min-height: 104px;
}

.cart-checkbox { flex-shrink: 0; }

.cart-item-img {
  flex-shrink: 0;
  position: relative;
  width: 80px;
  height: 80px;
  cursor: pointer;
}
.item-img {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 8px;
  display: block;
}

.cart-item-info {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-self: stretch;
  padding: 2px 0;
}

.item-name {
  font-size: 14px;
  font-weight: 500;
  color: #323233;
  line-height: 1.4;
  margin: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  cursor: pointer;
}
.item-name:active { color: #ee0a24; }

.item-bottom {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: auto;
}

.item-price {
  font-size: 16px;
  font-weight: 700;
  color: #ee0a24;
}

.item-stepper {
  flex-shrink: 0;
}

/* ── Delete button ── */
.delete-btn {
  height: 100%;
  min-width: 64px;
  min-height: 104px;
  font-size: 14px;
}

/* ── Bottom spacer ── */
.bottom-spacer { height: 60px; }

/* ═══ SubmitBar ═══ */
.cart-submit-bar {
  z-index: 100;
}

.submit-checkbox {
  --van-checkbox-label-color: #323233;
  font-size: 13px;
}

.submit-tip {
  font-size: 13px;
  color: #969799;
}
.submit-total {
  font-size: 16px;
  color: #ee0a24;
  font-weight: 700;
}

/* ═══ Edit bar ═══ */
.edit-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 16px;
  padding-bottom: calc(8px + env(safe-area-inset-bottom, 0px));
  box-shadow: 0 -2px 10px rgba(0,0,0,0.06);
  z-index: 100;
}

.edit-all-checkbox {
  font-size: 13px;
}

.batch-delete-btn {
  min-width: 96px;
  min-height: 40px;
  font-size: 14px;
  font-weight: 600;
  border-radius: 20px;
}

.batch-delete-btn:active {
  opacity: 0.8;
}

/* ═══ Touch target >= 48px ═══ */
.go-shop-btn,
.edit-btn,
.batch-delete-btn,
.delete-btn,
.cart-checkbox,
.cart-item-img,
.item-name,
.item-stepper :deep(.van-stepper__minus),
.item-stepper :deep(.van-stepper__plus) {
  min-height: 44px;
  min-width: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* ═══ Responsive ═══ */
@media (max-width: 360px) {
  .item-price { font-size: 14px; }
  .submit-total { font-size: 14px; }
}
</style>