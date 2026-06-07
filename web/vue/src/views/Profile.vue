<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import { useCartStore } from '../stores/cart'
import { get, post } from '../api'
import {
  showDialog, showToast, showSuccessToast, showFailToast,
  NavBar, Cell, CellGroup, Image as VanImage, Button, Icon,
  Popup, Field, Picker, Tag, Empty, Loading
} from 'vant'

const router = useRouter()
const userStore = useUserStore()
const cartStore = useCartStore()

// ── States ──
const orderStats = reactive({ pendingPay: 0, pendingShip: 0, pendingReceive: 0, completed: 0 })
const recentOrders = ref([])
const loadingStats = ref(true)
const jfLogs = ref([])
const showJfLogs = ref(false)
const showJfRules = ref(false)

// ── Edit profile popup ──
const showEditPopup = ref(false)
const editForm = reactive({ tel: '', email: '', gender: '' })
const editLoading = ref(false)

const showGenderPicker = ref(false)
const genderOptions = [
  { text: '保密', value: '保密' },
  { text: '男', value: '男' },
  { text: '女', value: '女' }
]

function openGenderPicker() {
  if (!editForm.gender || typeof editForm.gender !== 'string') {
    editForm.gender = '保密'
  }
  showGenderPicker.value = true
}

function onGenderConfirm({ selectedValues }) {
  if (selectedValues && selectedValues.length > 0) {
    editForm.gender = String(selectedValues[0])
  }
  showGenderPicker.value = false
}

// ── Computed ──
const statCards = computed(() => [
  { icon: 'clock-o', num: orderStats.pendingPay, label: '待付款', color: '#ff976a', bg: '#fff7f0', route: '/orders?tab=1' },
  { icon: 'logistics', num: orderStats.pendingShip, label: '待发货', color: '#1989fa', bg: '#eef5ff', route: '/orders?tab=2' },
  { icon: 'passed', num: orderStats.pendingReceive, label: '待收货', color: '#07c160', bg: '#e8f8ef', route: '/orders?tab=3' },
  { icon: 'star-o', num: orderStats.completed, label: '已收货', color: '#999', bg: '#f5f5f5', route: '/orders?tab=4' },
])

const formatTime = (val) => {
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

const formatDate = (val) => {
  if (!val) return ''
  const s = String(val)
  return s.length <= 10 ? s : s.slice(0, 10)
}

// ── Fetch order stats ──
async function fetchStats() {
  loadingStats.value = true
  try {
    const res = await get('/orders')
    if (res.code === 200) {
      const list = res.data.list || res.data || []
      orderStats.pendingPay = list.filter(o => o.status === '待付款').length
      orderStats.pendingShip = list.filter(o => o.status === '已付款').length
      orderStats.pendingReceive = list.filter(o => o.status === '已发货').length
      orderStats.completed = list.filter(o => o.status === '已完成').length
      recentOrders.value = list.slice(0, 3)
    }
  } catch {} finally { loadingStats.value = false }
}

async function fetchJfLogs() {
  try {
    const res = await get('/user', { action: 'jfLogs', limit: 50 })
    if (res.code === 200) {
      jfLogs.value = Array.isArray(res.data) ? res.data : []
    }
  } catch {}
}

// ── Logout ──
function handleLogout() {
  showDialog({ title: '退出登录', message: '确定要退出登录吗？', showCancelButton: true })
    .then(() => { userStore.logout(); cartStore.$reset(); router.push('/') })
    .catch(() => {})
}

// ── Edit profile ──
function openEditPopup() {
  editForm.tel = userStore.phone || ''
  editForm.email = userStore.email || ''
  editForm.gender = userStore.gender || '保密'
  showEditPopup.value = true
}

async function submitEdit() {
  if (!editForm.tel || !editForm.tel.match(/^1[3-9]\d{9}$/)) { showToast('请输入正确的手机号'); return }
  if (!editForm.email || !editForm.email.match(/^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/)) { showToast('请输入正确的邮箱'); return }
  editLoading.value = true
  try {
    const res = await userStore.updateProfile(editForm.tel, editForm.email, editForm.gender)
    if (res.code === 200) {
      showSuccessToast('保存成功')
      showEditPopup.value = false
      userStore.fetchProfile()
    } else { showFailToast(res.message || '保存失败') }
  } catch (e) { showFailToast(e.message || '网络错误') }
  finally { editLoading.value = false }
}

// ── Avatar upload ──
const avatarInput = ref(null)

function triggerAvatar() {
  avatarInput.value?.click()
}

async function onAvatarFile(e) {
  const file = e.target.files?.[0]
  if (!file) return
  if (file.size > 2 * 1024 * 1024) { showToast('图片不能超过2MB'); return }
  if (!['image/jpeg', 'image/png', 'image/gif'].includes(file.type)) { showToast('仅支持 JPG、PNG、GIF 格式'); return }

  const formData = new FormData()
  formData.append('file', file)
  try {
    const res = await post('/avatar', formData)
    if (res.code === 200) {
      showSuccessToast('头像更新成功')
      userStore.fetchProfile()
    } else { showFailToast(res.message || '上传失败') }
  } catch { showFailToast('上传失败') }
  // reset so same file can be re-selected
  avatarInput.value.value = ''
}

// ── Points ──
function openJfLogs() {
  fetchJfLogs()
  showJfLogs.value = true
}

// ── Menu items ──
const menuGroups = [
  { icon: 'orders-o', title: '我的订单', to: '/orders' },
  { icon: 'like-o', title: '我的收藏', to: '/favorites' },
  { icon: 'location-o', title: '收货地址', to: '/address' },
  { icon: 'comment-o', title: '我的留言', to: '/message' },
]

const otherMenu = [
  { icon: '', title: '修改密码', to: '/security' },
  { icon: '', title: '退出登录', action: 'logout' },
]

onMounted(async () => {
  if (!userStore.loggedIn) {
    await userStore.fetchProfile()
    if (!userStore.loggedIn) return
  }
  fetchStats()
})
</script>

<template>
  <div class="profile-page">
    <!-- Nav -->
    <van-nav-bar
      title="个人中心"
      fixed
      placeholder
      safe-area-inset-top
    />

    <!-- Guest -->
    <template v-if="!userStore.loggedIn">
      <div class="guest-banner">
        <div class="guest-avatar">
          <van-icon name="manager" size="40" color="#fff" />
        </div>
        <div class="guest-text">
          <div class="guest-title">欢迎来到归途花店</div>
          <div class="guest-sub">登录后享受更多专属服务</div>
        </div>
        <div class="guest-btns">
          <van-button type="primary" size="small" round @click="router.push('/login')">登录</van-button>
          <van-button plain type="primary" size="small" round @click="router.push('/register')">注册</van-button>
        </div>
      </div>
      <div class="guest-empty">
        <van-empty description="登录后可查看订单、收藏、积分等" />
      </div>
    </template>

    <!-- Logged in -->
    <template v-else>
      <!-- Header card -->
      <div class="profile-header">
        <div class="header-bg" />
        <div class="header-content">
          <div class="avatar-col" @click="triggerAvatar">
            <van-image
              round
              width="66"
              height="66"
              :src="userStore.avatar || 'data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%2266%22 height=%2266%22><rect fill=%22rgba(255,255,255,0.3)%22 width=%2266%22 height=%2266%22 rx=%2233%22/><text x=%2233%22 y=%2246%22 text-anchor=%22middle%22 fill=%22white%22 font-size=%2232%22>🌸</text></svg>'"
              fit="cover"
            />
            <div class="avatar-badge"><van-icon name="photograph" size="12" /></div>
          </div>
          <input ref="avatarInput" type="file" accept="image/*" style="display:none" @change="onAvatarFile" />
          <div class="info-col">
            <div class="username">{{ userStore.username }}</div>
            <div class="user-meta">
              <span v-if="userStore.phone" class="meta-tag">{{ userStore.phone }}</span>
              <span v-if="userStore.gender && userStore.gender !== '保密'" class="meta-tag gender-tag">{{ userStore.gender }}</span>
            </div>
            <div class="user-time" v-if="userStore.lastLoginTime">最近登录: {{ formatTime(userStore.lastLoginTime) }}</div>
          </div>
        </div>

        <!-- Points bar -->
        <div class="points-bar">
          <div class="points-info" @click="openJfLogs">
            <div class="points-num">{{ userStore.jf || 0 }}</div>
            <div class="points-label">我的积分 <van-icon name="arrow" size="10" /></div>
          </div>
          <div class="points-divider" />
          <div class="points-actions">
            <span class="points-link" @click="openJfLogs">积分明细</span>
            <span class="points-link" @click="showJfRules = true">积分规则</span>
          </div>
        </div>
      </div>

      <!-- Order stats -->
      <div class="stats-section">
        <div class="section-header">
          <span class="section-title">我的订单</span>
          <span class="section-more" @click="router.push('/orders')">全部订单 <van-icon name="arrow" /></span>
        </div>
        <div class="stats-grid">
          <div
            v-for="card in statCards"
            :key="card.label"
            class="stat-item"
            @click="router.push(card.route)"
          >
            <div class="stat-icon-wrap" :style="{ background: card.bg, color: card.color }">
              <van-icon :name="card.icon" size="20" />
            </div>
            <div class="stat-num" :class="{ 'is-zero': card.num === 0 }">{{ card.num }}</div>
            <div class="stat-label">{{ card.label }}</div>
          </div>
        </div>
      </div>

      <!-- Recent orders -->
      <div v-if="recentOrders.length" class="recent-section">
        <div class="section-header">
          <span class="section-title">最近订单</span>
        </div>
        <div class="recent-cards">
          <div
            v-for="o in recentOrders"
            :key="o.orderId"
            class="recent-card"
            @click="router.push('/order/' + o.orderId)"
          >
            <div class="recent-card-top">
              <div class="recent-card-meta">
                <span class="recent-order-id">#{{ o.orderId }}</span>
                <span class="recent-time">{{ formatDate(o.createTime) }}</span>
              </div>
              <van-tag
                :type="{'待付款':'warning','已付款':'primary','已发货':'primary','已收货':'success','已完成':'success','已取消':'default'}[o.status]"
                :plain="o.status === '已收货' || o.status === '已完成' || o.status === '已取消'"
                size="medium"
                round
              >
                {{ o.status }}
              </van-tag>
            </div>
            <div class="recent-items">
              <div
                v-for="item in (o.items || []).slice(0, 3)"
                :key="item.productId"
                class="recent-item-row"
              >
                <img
                  :src="item.productPic"
                  style="width:44px;height:44px;object-fit:cover;border-radius:6px;border:1px solid #f0f0f0"
                  @error="$event.target.src='data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%2244%22 height=%2244%22><rect fill=%22%23f5f5f5%22 width=%2244%22 height=%2244%22 rx=%226%22/><text x=%2222%22 y=%2230%22 text-anchor=%22middle%22 fill=%22%23ccc%22 font-size=%2216%22>🌸</text></svg>'"
                />
                <span class="recent-item-name">{{ item.productName }}</span>
                <span class="recent-item-qty">x{{ item.quantity }}</span>
              </div>
            </div>
            <div class="recent-card-footer">
              <span>共 {{ o.totalCount }} 件</span>
              <span class="recent-total">&yen;{{ Number(o.totalAmount || 0).toFixed(2) }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Account info -->
      <div class="info-section">
        <div class="section-header">
          <span class="section-title">账号信息</span>
          <span class="section-more" @click="openEditPopup">编辑</span>
        </div>
        <van-cell-group :border="false">
          <van-cell title="用户名" :value="userStore.username" />
          <van-cell title="手机号" :value="userStore.phone || '未设置'" />
          <van-cell title="邮箱" :value="userStore.email || '未设置'" />
          <van-cell title="性别" :value="userStore.gender || '保密'" />
          <van-cell title="注册时间" :value="formatTime(userStore.createTime)" />
          <van-cell title="最后登录" :value="formatTime(userStore.lastLoginTime) || '—'" />
        </van-cell-group>
      </div>

      <!-- Menu -->
      <div class="menu-section">
        <van-cell-group :border="false">
          <van-cell
            v-for="item in menuGroups"
            :key="item.title"
            :title="item.title"
            is-link
            :to="item.to"
          >
            <template #icon>
              <van-icon :name="item.icon" size="20" class="menu-icon" />
            </template>
          </van-cell>
        </van-cell-group>
      </div>

      <div class="menu-section">
        <van-cell-group :border="false">
          <van-cell
            v-for="item in otherMenu"
            :key="item.title"
            :title="item.title"
            is-link
            @click="item.action === 'logout' ? handleLogout() : router.push(item.to)"
          >
            <template #icon>
              <van-icon v-if="item.icon" :name="item.icon" size="20" :color="item.color || '#323233'" class="menu-icon" />
            </template>
          </van-cell>
        </van-cell-group>
      </div>
    </template>

    <!-- Spacer -->
    <div style="height:30px" />

    <!-- Edit profile popup -->
    <van-popup v-model:show="showEditPopup" position="bottom" round :style="{ height: '75%' }" safe-area-inset-bottom>
      <div class="popup-form">
        <h3 class="popup-title">编辑资料</h3>

        <!-- Avatar -->
        <div class="edit-avatar-row" @click="triggerAvatar">
          <van-image
            round
            width="60"
            height="60"
            :src="userStore.avatar || 'data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 width=%2260%22 height=%2260%22><rect fill=%22%23f5f5f5%22 width=%2260%22 height=%2260%22 rx=%2230%22/><text x=%2230%22 y=%2242%22 text-anchor=%22middle%22 fill=%22%23ccc%22 font-size=%2228%22>🌸</text></svg>'"
            fit="cover"
          />
          <div class="edit-avatar-text">
            <span>更换头像</span>
            <van-icon name="arrow" size="12" color="#999" />
          </div>
        </div>

        <van-field v-model="userStore.username" label="用户名" readonly />
        <van-field v-model="editForm.tel" label="手机号" placeholder="请输入手机号" type="tel" maxlength="11" />
        <van-field v-model="editForm.email" label="邮箱" placeholder="请输入邮箱" type="email" />
        <van-cell title="性别" :value="editForm.gender || '请选择'" is-link @click="openGenderPicker" />
        <div class="popup-btns">
          <van-button round block @click="showEditPopup = false">取消</van-button>
          <van-button round block type="primary" :loading="editLoading" @click="submitEdit">保存</van-button>
        </div>
      </div>
    </van-popup>

    <!-- Gender picker -->
    <van-popup v-model:show="showGenderPicker" position="bottom" round>
      <van-picker
        :columns="genderOptions"
        :default-index="Math.max(0, genderOptions.findIndex(o => o.value === editForm.gender))"
        @confirm="onGenderConfirm"
        @cancel="showGenderPicker = false"
      />
    </van-popup>

    <!-- Points log popup -->
    <van-popup
      v-model:show="showJfLogs"
      position="bottom"
      round
      :style="{ height: '65%', maxHeight: '600px' }"
      safe-area-inset-bottom
    >
      <div class="jf-popup">
        <div class="jf-popup-header">
          <h3>积分明细</h3>
          <span class="jf-balance">当前余额: <strong>{{ userStore.jf || 0 }}</strong> 积分</span>
        </div>
        <div class="jf-list" v-if="jfLogs.length">
          <div v-for="log in jfLogs" :key="log.id" class="jf-item">
            <div class="jf-item-left">
              <div class="jf-item-desc">{{ log.description }}</div>
              <div class="jf-item-time">{{ log.createTime }}</div>
            </div>
            <div class="jf-item-amount" :class="{ positive: log.amount > 0, negative: log.amount < 0 }">
              {{ log.amount > 0 ? '+' : '' }}{{ log.amount }}
            </div>
          </div>
        </div>
        <van-empty v-else description="暂无积分记录" />
      </div>
    </van-popup>

    <!-- Points rules popup -->
    <van-popup
      v-model:show="showJfRules"
      position="bottom"
      round
      :style="{ height: '60%', maxHeight: '520px' }"
      safe-area-inset-bottom
    >
      <div class="jf-popup">
        <div class="jf-popup-header">
          <h3>积分规则</h3>
        </div>
        <div class="jf-rules">
          <h4 class="rules-title earn">获取积分</h4>
          <div class="rule-row"><span>新用户注册</span><span class="rule-val earn">+200</span></div>
          <div class="rule-row"><span>每日首次登录</span><span class="rule-val earn">+5</span></div>
          <div class="rule-row"><span>浏览商品（每件不重复）</span><span class="rule-val earn" style="color:#27ae60">+2</span></div>
          <div class="rule-row"><span>首次添加收货地址</span><span class="rule-val earn" style="color:#27ae60">+50</span></div>
          <div class="rule-row"><span>完善个人信息（首次）</span><span class="rule-val earn" style="color:#27ae60">+50</span></div>
          <div class="rule-row"><span>更新个人信息</span><span class="rule-val earn" style="color:#27ae60">+10</span></div>
          <div class="rule-row"><span>购物消费（每&yen;10 = 1积分）</span><span class="rule-val earn">+1%</span></div>
          <h4 class="rules-title spend" style="margin-top:20px">使用积分</h4>
          <div class="rule-row"><span>积分抵扣</span><span class="rule-val spend">100积分 = &yen;1</span></div>
          <div class="rule-row"><span>最高抵扣比例</span><span class="rule-val" style="color:#666">订单金额 50%</span></div>
        </div>
      </div>
    </van-popup>
  </div>
</template>

<style scoped>
.profile-page {
  min-height: 100vh;
  background: #f5f7fa;
}

/* ── Guest ── */
.guest-banner {
  background: linear-gradient(135deg, #e74c3c 0%, #f39c12 100%);
  padding: 24px 16px;
  display: flex;
  align-items: center;
  gap: 12px;
}
.guest-avatar {
  width: 56px; height: 56px;
  background: rgba(255,255,255,0.2);
  border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.guest-text { flex: 1; min-width: 0; }
.guest-title { font-size: 17px; font-weight: 700; color: #fff; }
.guest-sub { font-size: 12px; color: rgba(255,255,255,0.8); margin-top: 2px; }
.guest-btns { display: flex; gap: 8px; flex-shrink: 0; }
.guest-btns :deep(.van-button--small) { min-width: 60px; }
.guest-empty { background: #fff; }

/* ── Header ── */
.profile-header {
  position: relative;
  overflow: hidden;
}
.header-bg {
  position: absolute; inset: 0;
  background: linear-gradient(135deg, #e74c3c 0%, #f39c12 100%);
  height: 140px;
}
.header-content {
  position: relative; z-index: 1;
  display: flex; align-items: center; gap: 12px;
  padding: 20px 16px 0;
  color: #fff;
}
.avatar-col {
  position: relative; flex-shrink: 0;
  border: 3px solid rgba(255,255,255,0.5);
  border-radius: 50%;
}
.avatar-badge {
  position: absolute; bottom: 0; right: 0;
  width: 20px; height: 20px;
  background: rgba(0,0,0,0.4);
  border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  color: #fff;
}
.info-col { flex: 1; min-width: 0; }
.username { font-size: 18px; font-weight: 700; }
.user-meta { display: flex; gap: 6px; margin-top: 4px; }
.meta-tag {
  font-size: 11px; background: rgba(255,255,255,0.25);
  padding: 1px 8px; border-radius: 10px;
}
.gender-tag { background: rgba(255,255,255,0.3); }
.user-time { font-size: 11px; opacity: 0.7; margin-top: 2px; }

/* ── Points bar ── */
.points-bar {
  position: relative; z-index: 1;
  margin: 16px 16px 0;
  background: #fff;
  border-radius: 12px;
  padding: 14px 16px;
  display: flex;
  align-items: center;
  box-shadow: 0 2px 8px rgba(0,0,0,0.06);
}
.points-info { cursor: pointer; }
.points-num { font-size: 26px; font-weight: 800; color: #e74c3c; line-height: 1.1; }
.points-label { font-size: 12px; color: #999; }
.points-divider { width: 1px; height: 32px; background: #f0f0f0; margin: 0 16px; }
.points-actions { display: flex; flex-direction: column; gap: 6px; }
.points-link {
  font-size: 12px; color: #e74c3c; cursor: pointer;
  text-decoration: underline; text-underline-offset: 2px;
}
.points-link:active { opacity: 0.7; }

/* ── Stats section ── */
.stats-section {
  margin: 12px 16px;
  background: #fff;
  border-radius: 12px;
  padding: 16px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.04);
}
.section-header {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 14px;
}
.section-title { font-size: 15px; font-weight: 600; color: #333; }
.section-more {
  font-size: 12px; color: #999; cursor: pointer;
  display: flex; align-items: center; gap: 2px;
}
.section-more:active { color: #666; }
.stats-grid {
  display: flex; justify-content: space-around;
}
.stat-item {
  display: flex; flex-direction: column; align-items: center;
  cursor: pointer; padding: 4px 8px; border-radius: 8px;
  transition: background 0.2s;
}
.stat-item:active { background: #f5f7fa; }
.stat-icon-wrap {
  width: 40px; height: 40px; border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  margin-bottom: 6px;
}
.stat-num { font-size: 18px; font-weight: 700; color: #333; }
.stat-num.is-zero { color: #ccc; }
.stat-label { font-size: 11px; color: #999; }

/* ── Recent orders ── */
.recent-section {
  margin: 0 16px 12px;
  background: #fff;
  border-radius: 12px;
  padding: 16px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.04);
}
.recent-cards { display: flex; flex-direction: column; gap: 10px; }
.recent-card {
  border: 1px solid #f0f0f0; border-radius: 10px; padding: 12px;
  cursor: pointer; transition: border-color 0.2s;
}
.recent-card:active { border-color: #e74c3c; background: #fef8f8; }
.recent-card-top {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 8px;
}
.recent-card-meta { display: flex; flex-direction: column; gap: 2px; }
.recent-order-id { font-size: 12px; color: #999; }
.recent-time { font-size: 11px; color: #bbb; }
.recent-items { margin-bottom: 8px; }
.recent-item-row {
  display: flex; align-items: center; gap: 8px;
  padding: 6px 0; border-bottom: 1px solid #fafafa;
}
.recent-item-row:last-child { border-bottom: none; }
.recent-item-name {
  flex: 1; font-size: 13px; color: #333;
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}
.recent-item-qty { font-size: 12px; color: #999; }
.recent-card-footer {
  display: flex; justify-content: space-between; align-items: center;
  font-size: 12px; color: #999;
}
.recent-total { font-size: 15px; font-weight: 700; color: #e74c3c; }

/* ── Account info ── */
.info-section {
  margin: 0 16px 12px;
  background: #fff;
  border-radius: 12px;
  padding: 0 0 4px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.04);
}
.info-section .section-header { padding: 16px 16px 4px; margin-bottom: 0; }
.info-section :deep(.van-cell) { padding: 10px 16px; }
.info-section :deep(.van-cell__title) { font-size: 13px; color: #999; flex: none; width: 80px; }
.info-section :deep(.van-cell__value) { font-size: 13px; color: #333; font-weight: 500; }

/* ── Menu ── */
.menu-section {
  margin: 0 16px 12px;
  background: #fff;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 1px 4px rgba(0,0,0,0.04);
}
.menu-icon { margin-right: 8px; color: #666; }

/* ── Popups ── */
.popup-form { padding: 24px 16px 32px; }
.popup-title { text-align: center; font-size: 18px; font-weight: 700; margin: 0 0 20px; color: #323233; }
.popup-btns { display: flex; gap: 12px; margin-top: 24px; }
.popup-btns .van-button { flex: 1; }

.edit-avatar-row {
  display: flex; align-items: center; gap: 12px;
  padding: 12px 16px; cursor: pointer; background: #fafafa;
  border-radius: 8px; margin-bottom: 12px;
}
.edit-avatar-row:active { background: #f0f0f0; }
.edit-avatar-text { flex: 1; display: flex; justify-content: space-between; align-items: center; font-size: 14px; color: #323233; }

/* ── Points popup ── */
.jf-popup {
  display: flex; flex-direction: column; height: 100%;
}
.jf-popup-header {
  padding: 20px 16px 12px;
  text-align: center; border-bottom: 1px solid #f0f0f0;
  background: linear-gradient(135deg, #fff0f0, #fff8f0);
}
.jf-popup-header h3 { margin: 0 0 4px; font-size: 17px; font-weight: 700; }
.jf-balance { font-size: 13px; color: #666; }
.jf-balance strong { color: #e74c3c; }
.jf-list { flex: 1; overflow-y: auto; }
.jf-item {
  display: flex; justify-content: space-between; align-items: center;
  padding: 14px 16px; border-bottom: 1px solid #f5f5f5;
}
.jf-item-left { flex: 1; min-width: 0; }
.jf-item-desc { font-size: 14px; color: #333; }
.jf-item-time { font-size: 11px; color: #999; margin-top: 2px; }
.jf-item-amount { font-size: 18px; font-weight: 700; margin-left: 12px; }
.jf-item-amount.positive { color: #27ae60; }
.jf-item-amount.negative { color: #e74c3c; }

.jf-rules { padding: 0 20px 20px; overflow-y: auto; }
.rules-title { font-size: 15px; font-weight: 700; margin: 0 0 12px; display: flex; align-items: center; gap: 6px; }
.rules-title.earn::before { content: ''; width: 4px; height: 16px; background: #27ae60; border-radius: 2px; display: inline-block; }
.rules-title.spend::before { content: ''; width: 4px; height: 16px; background: #e74c3c; border-radius: 2px; display: inline-block; }
.rule-row {
  display: flex; justify-content: space-between; align-items: center;
  padding: 8px 0; border-bottom: 1px solid #f5f5f5; font-size: 13px; color: #555;
}
.rule-val { font-weight: 700; }
.rule-val.earn { color: #27ae60; }
.rule-val.spend { color: #e74c3c; }
</style>
