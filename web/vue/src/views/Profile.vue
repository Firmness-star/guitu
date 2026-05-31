<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import { useCartStore } from '../stores/cart'
import { get } from '../api'
import { showDialog, showToast } from 'vant'
import { put } from '../api'

const router = useRouter()
const userStore = useUserStore()
const cartStore = useCartStore()

const showPwdPopup = ref(false)
const pwdForm = ref({ oldPwd: '', newPwd: '', confirmPwd: '' })
const pwdLoading = ref(false)

function handleLogout() {
  showDialog({
    title: '退出登录',
    message: '确定要退出登录吗？',
    showCancelButton: true,
    confirmButtonText: '确定',
    cancelButtonText: '取消',
  }).then(() => {
    userStore.logout()
    cartStore.clear()
    router.push('/')
  }).catch(() => {})
}

async function handleChangePassword() {
  showPwdPopup.value = true
}

async function submitPassword() {
  const { oldPwd, newPwd, confirmPwd } = pwdForm.value
  if (!oldPwd) { showToast('请输入原密码'); return }
  if (!newPwd || newPwd.length < 6) { showToast('新密码至少6位'); return }
  if (newPwd !== confirmPwd) { showToast('两次密码不一致'); return }

  pwdLoading.value = true
  const body = new URLSearchParams()
  body.append('action', 'changePwd')
  body.append('oldPassword', oldPwd)
  body.append('newPassword', newPwd)
  try {
    const res = await put('/user', body)
    if (res.code === 200) {
      showToast('密码修改成功')
      showPwdPopup.value = false
      pwdForm.value = { oldPwd: '', newPwd: '', confirmPwd: '' }
    } else { showToast(res.message || '修改失败') }
  } catch (e) { showToast(e.message || '网络错误') }
  finally { pwdLoading.value = false }
}
</script>

<template>
  <div class="profile-page">
    <van-nav-bar title="个人中心" fixed placeholder />
    <div v-if="userStore.loggedIn" class="profile-header">
      <van-image round width="64" height="64" :src="userStore.avatar || 'https://img.yzcdn.cn/vant/cat.jpeg'" fit="cover" class="avatar" />
      <div class="profile-info">
        <div class="username">{{ userStore.username }}</div>
        <div class="phone">{{ userStore.phone || '未绑定手机' }}</div>
      </div>
    </div>
    <div v-else class="profile-header profile-header--guest">
      <van-image round width="64" height="64" src="https://img.yzcdn.cn/vant/cat.jpeg" fit="cover" class="avatar" />
      <div class="auth-buttons">
        <van-button type="primary" size="small" @click="router.push('/login')">登录</van-button>
        <van-button plain type="primary" size="small" @click="router.push('/register')">注册</van-button>
      </div>
    </div>
    <van-cell-group v-if="userStore.loggedIn" class="menu-group">
      <van-cell title="我的积分" :value="String(userStore.jf || 0)" icon="gold-coin-o" />
      <van-cell title="我的订单" is-link to="/orders" icon="orders-o" />
      <van-cell title="收货地址" is-link to="/address" icon="location-o" />
      <van-cell title="修改密码" is-link icon="lock" @click="handleChangePassword" />
      <van-cell title="退出登录" icon="close" clickable @click="handleLogout" class="logout-cell" />
    </van-cell-group>

    <van-popup v-model:show="showPwdPopup" position="bottom" round :style="{ height: '55%' }" safe-area-inset-bottom>
      <div class="pwd-form">
        <h3>修改密码</h3>
        <van-field v-model="pwdForm.oldPwd" type="password" label="原密码" placeholder="请输入原密码" />
        <van-field v-model="pwdForm.newPwd" type="password" label="新密码" placeholder="至少6位" />
        <van-field v-model="pwdForm.confirmPwd" type="password" label="确认密码" placeholder="再次输入" />
        <div class="pwd-btns">
          <van-button round @click="showPwdPopup = false">取消</van-button>
          <van-button round type="primary" :loading="pwdLoading" @click="submitPassword">确认修改</van-button>
        </div>
      </div>
    </van-popup>
  </div>
</template>

<style scoped>
.profile-page { min-height:100vh;background:#f5f5f5; }
.profile-header { display:flex;align-items:center;gap:16px;padding:24px 16px;background:#fff;margin-bottom:12px; }
.profile-header--guest { flex-direction:column;gap:12px; }
.avatar { flex-shrink:0; }
.profile-info { flex:1;min-width:0; }
.username { font-size:18px;font-weight:600;color:#323233;margin-bottom:4px; }
.phone { font-size:13px;color:#969799; }
.auth-buttons { display:flex;gap:12px; }
.menu-group { margin:0 0 12px; }
.logout-cell { --van-cell-text-color:#ee0a24;text-align:center; }
.pwd-form { padding:20px 16px; }
.pwd-form h3 { text-align:center;font-size:18px;margin:0 0 16px; }
.pwd-btns { display:flex;gap:12px;margin-top:20px; }
</style>
