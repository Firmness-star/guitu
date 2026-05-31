<script setup>
import { ref, computed, reactive, watch, onMounted } from 'vue'
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
  showConfirmDialog,
  showToast,
  showFailToast
} from 'vant'

const router = useRouter()
const cartStore = useCartStore()
const userStore = useUserStore()

// Loading state
const loading = ref(true)

// Local checked state keyed by productId, survives refetches
const checked = reactive({})

// Sync checked map when cart items change (after fetch)
watch(
  () => cartStore.items,
  (items) => {
    const map = {}
    items.forEach((item) => {
      map[item.productId] =
        checked[item.productId] !== undefined
          ? checked[item.productId]
          : item.selected !== false
    })
    Object.keys(checked).forEach((key) => {
      if (!(key in map)) delete checked[key]
    })
    Object.assign(checked, map)
  },
  { deep: true, immediate: true }
)

// Computed: all selected
const allChecked = computed({
  get: () =>
    cartStore.items.length > 0 &&
    cartStore.items.every((i) => checked[i.productId]),
  set: (val) => {
    cartStore.items.forEach((i) => {
      checked[i.productId] = val
    })
  }
})

// Computed: count of checked items
const checkedCount = computed(() =>
  cartStore.items.filter((i) => checked[i.productId]).length
)

// Computed: total price of checked items (yuan)
const checkedTotal = computed(() => {
  const total = cartStore.items.reduce((sum, i) => {
    if (checked[i.productId]) {
      return sum + i.productPrice * i.quantity
    }
    return sum
  }, 0)
  return Math.round(total * 100) / 100
})

// Computed: total in fen for SubmitBar
const checkedTotalFen = computed(() =>
  Math.round(checkedTotal.value * 100)
)

// Fetch cart data
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

// Quantity change
async function onQuantityChange(item, qty) {
  try {
    await cartStore.update(item.productId, qty)
  } catch (e) {
    showFailToast(e.message || '更新失败')
  }
}

// Delete cart item
async function onDelete(item) {
  try {
    await showConfirmDialog({
      title: '确认删除',
      message: `确定要删除「${item.productName}」吗？`
    })
  } catch {
    // User cancelled
    return
  }
  try {
    await cartStore.remove(item.productId)
    showToast('已删除')
  } catch (e) {
    showFailToast(e.message || '删除失败')
  }
}

// Go to checkout
function goCheckout() {
  if (checkedCount.value === 0) {
    showToast('请选择商品')
    return
  }
  if (!userStore.loggedIn) {
    router.push('/login')
    return
  }
  const selectedIds = cartStore.items
    .filter((i) => checked[i.productId])
    .map((i) => i.productId)
  sessionStorage.setItem('checkoutItems', JSON.stringify(selectedIds))
  router.push('/checkout')
}

// Go to product detail
function goProduct(id) {
  router.push(`/product/${id}`)
}

onMounted(() => {
  fetchCart()
})
</script>

<template>
  <div class="cart-page">
    <!-- NavBar -->
    <NavBar
      title="购物车"
      left-arrow
      fixed
      placeholder
      @click-left="router.back"
    />

    <!-- Loading -->
    <div v-if="loading" class="loading-wrap">
      <Loading type="spinner" size="32" color="#ff6b81" />
      <span class="loading-text">加载中...</span>
    </div>

    <!-- Cart Content -->
    <template v-else>
      <!-- Empty state -->
      <Empty
        v-if="cartStore.items.length === 0"
        description="购物车是空的"
        image="search"
        class="empty-wrap"
      >
        <Button type="primary" round @click="router.push('/')">
          去逛逛
        </Button>
      </Empty>

      <!-- Cart items -->
      <div v-else class="cart-list">
        <SwipeCell
          v-for="item in cartStore.items"
          :key="item.productId"
        >
          <div class="cart-item">
            <Checkbox
              v-model="checked[item.productId]"
              class="cart-checkbox"
              icon-size="20"
              checked-color="#ee0a24"
            />
            <div class="cart-item-img" @click="goProduct(item.productId)">
              <img
                :src="fixImg(item.productPic)"
                style="width:80px;height:80px;object-fit:cover;border-radius:8px"
                @error="$event.target.src='data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%2280%22 height=%2280%22><rect fill=%22%23f5f5f5%22 width=%2280%22 height=%2280%22 rx=%228%22/><text x=%2240%22 y=%2250%22 text-anchor=%22middle%22 fill=%22%23ccc%22 font-size=%2224%22>🌸</text></svg>'"
              />
            </div>
            <div class="cart-item-info">
              <p
                class="cart-item-name"
                @click="goProduct(item.productId)"
              >
                {{ item.productName }}
              </p>
              <div class="cart-item-bottom">
                <span class="cart-item-price">
                  &yen;{{ item.productPrice.toFixed(2) }}
                </span>
                <Stepper
                  :model-value="item.quantity"
                  :min="1"
                  :max="99"
                  integer
                  theme="round"
                  @change="(val) => onQuantityChange(item, val)"
                />
              </div>
            </div>
          </div>
          <template #right>
            <Button
              square
              type="danger"
              class="delete-btn"
              @click="onDelete(item)"
            >
              删除
            </Button>
          </template>
        </SwipeCell>
      </div>
    </template>

    <!-- Submit bar -->
    <SubmitBar
      v-if="!loading && cartStore.items.length > 0"
      :price="checkedTotalFen"
      button-text="去结算"
      button-color="#ee0a24"
      :disabled="checkedCount === 0"
      safe-area-inset-bottom
      @submit="goCheckout"
    >
      <Checkbox
        v-model="allChecked"
        icon-size="18"
        checked-color="#ee0a24"
      >
        全选
      </Checkbox>
    </SubmitBar>

    <!-- Bottom spacer when submit bar is visible -->
    <div
      v-if="!loading && cartStore.items.length > 0"
      style="height: 60px"
    />
  </div>
</template>

<style scoped>
.cart-page {
  min-height: 100vh;
  background: #f5f5f5;
}

/* Loading */
.loading-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 120px 0;
  gap: 12px;
}
.loading-text {
  font-size: 13px;
  color: #999;
}

/* Empty */
.empty-wrap {
  margin-top: 80px;
}

/* Cart list */
.cart-list {
  padding-bottom: 10px;
}

/* Cart item */
.cart-item {
  display: flex;
  align-items: center;
  background: #fff;
  padding: 10px 16px;
  gap: 10px;
  margin-bottom: 1px;
}

.cart-checkbox {
  flex-shrink: 0;
}

.cart-item-img {
  flex-shrink: 0;
  cursor: pointer;
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

.cart-item-name {
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

.cart-item-bottom {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: auto;
}

.cart-item-price {
  font-size: 16px;
  font-weight: 700;
  color: #ee0a24;
}

/* Delete button in swipe-cell */
.delete-btn {
  height: 100%;
  min-width: 64px;
  font-size: 14px;
}
</style>
