<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import { useCartStore } from '../stores/cart'
import { get, put, post } from '../api'
import { showDialog, showToast, showSuccessToast, showFailToast } from 'vant'
import {
  NavBar, Cell, CellGroup, Image as VanImage, Button, Icon,
  Popup, Field, RadioGroup, Radio, Form, Uploader, Dialog
} from 'vant'

const router = useRouter()
const userStore = useUserStore()
const cartStore = useCartStore()

// ── States ──
const orderStats = ref({ pendingPay: 0, pendingShip: 0, pendingReceive: 0, completed: 0 })
const recentOrders = ref([])
const loadingStats = ref(true)

// ── Password popup ──
const showPwdPopup = ref(false)
const pwdForm = ref({ oldPwd: '', newPwd: '', confirmPwd: '' })
const pwdLoading = ref(false)

// ── Edit profile popup ──
const showEditPopup = ref(false)
const editForm = ref({ tel: '', email: '', gender: '' })
const editLoading = ref(false)

// ── Avatar upload ──
const showAvatarActions = ref(false)

// ── Fetch order stats ──
async function fetchStats() {
  loadingStats.value = true
  try {
    const res = await get('/orders')
    if (res.code === 200) {
      const list = res.data.list || res.data || []
      orderStats.value = {
        pendingPay: list.filter(o => o.status === '待付款').length,
        pendingShip: list.filter(o => o.status === '已付款').length,
        pendingReceive: list.filter(o => o.status === '已发货').length,
        completed: list.filter(o => o.status === '已完成').length
      }
      recentOrders.value = list.slice(0, 3)
    }
  } catch {} finally { loadingStats.value = false }
}

// ── Logout ──
function handleLogout() {
  showDialog({ title: '退出登录', message: '确定要退出登录吗？', showCancelButton: true })
    .then(() => { userStore.logout(); cartStore.$reset(); router.push('/') })
    .catch(() => {})
}

// ── Change password ──
function openPwdPopup() { showPwdPopup.value = true }

async function submitPassword() {
  const { oldPwd, newPwd, confirmPwd } = pwdForm.value
  if (!oldPwd) { showToast('请输入原密码'); return }
  if (!newPwd || newPwd.length < 6) { showToast('新密码至少6位'); return }
  if (newPwd !== confirmPwd) { showToast('两次密码不一致'); return }
  pwdLoading.value = true
  try {
    const res = await put('/user', { action: 'changePwd', oldPassword: oldPwd, newPassword: newPwd })
    if (res.code === 200) {
      showSuccessToast('密码修改成功')
      showPwdPopup.value = false
      pwdForm.value = { oldPwd: '', newPwd: '', confirmPwd: '' }
    } else { showFailToast(res.message || '修改失败') }
  } catch (e) { showFailToast(e.message || '网络错误') }
  finally { pwdLoading.value = false }
}

// ── Edit profile ──
function openEditPopup() {
  editForm.value = {
    tel: userStore.phone || '',
    email: userStore.email || '',
    gender: userStore.gender || '未知'
  }
  showEditPopup.value = true
}

async function submitEdit() {
  editLoading.value = true
  try {
    const res = await put('/user', { action: 'updateInfo', tel: editForm.value.tel, email: editForm.value.email })
    if (res.code === 200) {
      showSuccessToast('保存成功')
      showEditPopup.value = false
      userStore.fetchProfile()
    } else { showFailToast(res.message || '保存失败') }
  } catch (e) { showFailToast(e.message || '网络错误') }
  finally { editLoading.value = false }
}

// ── Avatar upload ──
async function onAvatarUpload(file) {
  const formData = new FormData()
  formData.append('file', file.file)
  try {
    const res = await post('/avatar', formData)
    if (res.code === 200) {
      showSuccessToast('头像更新成功')
      userStore.fetchProfile()
    } else { showFailToast(res.message || '上传失败') }
  } catch { showFailToast('上传失败') }
  showAvatarActions.value = false
}

onMounted(() => { if (userStore.loggedIn) fetchStats() })
</script>

<template>
  <div class="profile-page">
    <NavBar title="个人中心" fixed placeholder safe-area-inset-top />

    <!-- Logged in header -->
    <div v-if="userStore.loggedIn" class="profile-header">
      <div class="avatar-wrap" @click="showAvatarActions = true">
        <VanImage round width="64" height="64" :src="userStore.avatar || 'https://img.yzcdn.cn/vant/cat.jpeg'" fit="cover" />
        <Icon name="photograph" class="avatar-edit-icon" />
      </div>
      <div class="profile-info">
        <div class="username">{{ userStore.username }}</div>
        <div class="sub-info">{{ userStore.phone || '未绑定手机' }}</div>
        <div class="sub-info">积分: {{ userStore.jf || 0 }}</div>
      </div>
      <Icon name="edit" class="edit-icon" @click="openEditPopup" />
    </div>

    <!-- Guest header -->
    <div v-else class="profile-header guest-header">
      <VanImage round width="64" height="64" src="https://img.yzcdn.cn/vant/cat.jpeg" />
      <div class="guest-btns">
        <Button type="primary" size="small" round @click="router.push('/login')">登录</Button>
        <Button plain type="primary" size="small" round @click="router.push('/register')">注册</Button>
      </div>
    </div>

    <!-- Order stats -->
    <div v-if="userStore.loggedIn" class="stats-card">
      <div class="stat-item" @click="router.push('/orders?tab=pendingPay')">
        <div class="stat-num">{{ orderStats.pendingPay }}</div>
        <div class="stat-label">待付款</div>
      </div>
      <div class="stat-divider" />
      <div class="stat-item" @click="router.push('/orders?tab=pendingShip')">
        <div class="stat-num">{{ orderStats.pendingShip }}</div>
        <div class="stat-label">待发货</div>
      </div>
      <div class="stat-divider" />
      <div class="stat-item" @click="router.push('/orders?tab=pendingReceive')">
        <div class="stat-num">{{ orderStats.pendingReceive }}</div>
        <div class="stat-label">待收货</div>
      </div>
      <div class="stat-divider" />
      <div class="stat-item" @click="router.push('/orders?tab=completed')">
        <div class="stat-num">{{ orderStats.completed }}</div>
        <div class="stat-label">已完成</div>
      </div>
    </div>

    <!-- Recent orders -->
    <CellGroup v-if="userStore.loggedIn && recentOrders.length" title="最近订单" class="section">
      <Cell v-for="o in recentOrders" :key="o.orderId" :title="o.orderId" :label="'¥' + (o.totalAmount || o.actualAmount || 0)" is-link @click="router.push('/orders')">
        <template #value>
          <Tag :type="o.status === '待付款' ? 'danger' : o.status === '已付款' ? 'warning' : o.status === '已发货' ? 'primary' : 'success'" round>{{ o.status }}</Tag>
        </template>
      </Cell>
    </CellGroup>

    <!-- Menu -->
    <CellGroup class="section menu-group">
      <Cell title="我的订单" is-link icon="orders-o" to="/orders" />
      <Cell title="收货地址" is-link icon="location-o" to="/address" />
      <Cell title="修改密码" is-link icon="lock-o" @click="openPwdPopup" />
      <Cell title="安全中心" is-link icon="shield-o" to="/security" />
      <Cell title="留言板" is-link icon="comment-o" to="/message" />
      <Cell title="退出登录" class="logout-cell" is-link icon="close" @click="handleLogout" />
    </CellGroup>

    <!-- Password popup -->
    <Popup v-model:show="showPwdPopup" position="bottom" round :style="{ height: '50%' }" safe-area-inset-bottom>
      <div class="popup-form">
        <h3 class="popup-title">修改密码</h3>
        <Field v-model="pwdForm.oldPwd" type="password" label="原密码" placeholder="请输入原密码" />
        <Field v-model="pwdForm.newPwd" type="password" label="新密码" placeholder="至少6位" />
        <Field v-model="pwdForm.confirmPwd" type="password" label="确认密码" placeholder="再次输入" />
        <div class="popup-btns">
          <Button round @click="showPwdPopup = false">取消</Button>
          <Button round type="primary" :loading="pwdLoading" @click="submitPassword">确认修改</Button>
        </div>
      </div>
    </Popup>

    <!-- Edit profile popup -->
    <Popup v-model:show="showEditPopup" position="bottom" round :style="{ height: '60%' }" safe-area-inset-bottom>
      <div class="popup-form">
        <h3 class="popup-title">编辑资料</h3>
        <Field v-model="editForm.tel" label="手机号" placeholder="请输入手机号" type="tel" maxlength="11" />
        <Field v-model="editForm.email" label="邮箱" placeholder="请输入邮箱" type="email" />
        <div class="popup-btns" style="margin-top:24px">
          <Button round @click="showEditPopup = false">取消</Button>
          <Button round type="primary" :loading="editLoading" @click="submitEdit">保存</Button>
        </div>
      </div>
    </Popup>

    <!-- Avatar upload action sheet -->
    <Popup v-model:show="showAvatarActions" position="bottom" round safe-area-inset-bottom>
      <div class="avatar-actions">
        <Uploader :after-read="onAvatarUpload" accept="image/*" :max-count="1">
          <Button block plain>选择头像上传</Button>
        </Uploader>
        <Button block plain @click="showAvatarActions = false" style="margin-top:8px;color:#969799">取消</Button>
      </div>
    </Popup>
  </div>
</template>

<style scoped>
.profile-page { min-height: 100vh; background: #f5f5f5; }
.profile-header {
  display: flex; align-items: center; gap: 14px;
  padding: 20px 16px; background: #fff; position: relative;
}
.guest-header { flex-direction: column; gap: 12px; }
.avatar-wrap { position: relative; cursor: pointer; }
.avatar-edit-icon {
  position: absolute; bottom: 0; right: 0;
  background: rgba(0,0,0,0.5); color: #fff;
  border-radius: 50%; padding: 3px; font-size: 14px;
}
.profile-info { flex: 1; min-width: 0; }
.username { font-size: 18px; font-weight: 600; color: #323233; margin-bottom: 2px; }
.sub-info { font-size: 13px; color: #969799; }
.edit-icon { font-size: 20px; color: #c8c9cc; cursor: pointer; padding: 8px; }
.edit-icon:active { color: #ee0a24; }
.guest-btns { display: flex; gap: 12px; }

/* Stats card */
.stats-card {
  display: flex; align-items: center; background: #fff;
  margin: 0 0 12px; padding: 16px 0;
}
.stat-item { flex: 1; text-align: center; cursor: pointer; padding: 4px 0; }
.stat-item:active { opacity: 0.6; }
.stat-num { font-size: 22px; font-weight: 700; color: #323233; }
.stat-label { font-size: 12px; color: #969799; margin-top: 2px; }
.stat-divider { width: 1px; height: 32px; background: #eee; }

/* Section */
.section { margin-bottom: 12px; }
.menu-group { margin-bottom: 0; }
.logout-cell { --van-cell-text-color: #ee0a24; }

/* Popup form */
.popup-form { padding: 24px 16px 32px; }
.popup-title { text-align: center; font-size: 18px; font-weight: 700; margin: 0 0 20px; color: #323233; }
.popup-btns { display: flex; gap: 12px; margin-top: 20px; }
.popup-btns .van-button { flex: 1; min-height: 44px; }

/* Avatar upload */
.avatar-actions { padding: 20px 16px 32px; }
</style>