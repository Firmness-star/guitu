<script setup>
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '../stores/user'
import { showToast } from 'vant'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const username = ref('')
const password = ref('')
const verifyCode = ref('')
const verifyCodeUrl = ref('/verifyCode')
const loading = ref(false)
const rememberMe = ref(false)

function refreshVerifyCode() {
  verifyCodeUrl.value = '/verifyCode?t=' + Date.now()
}

async function handleLogin() {
  if (!username.value.trim()) {
    showToast('请输入用户名')
    return
  }
  if (!password.value) {
    showToast('请输入密码')
    return
  }
  if (!verifyCode.value.trim()) {
    showToast('请输入验证码')
    return
  }

  loading.value = true
  try {
    const res = await userStore.login(username.value.trim(), password.value, verifyCode.value.trim())
    if (res.code === 200) {
      showToast('登录成功')
      const redirect = route.query.redirect || '/'
      router.replace(redirect)
    } else {
      showToast(res.message || '登录失败')
      refreshVerifyCode()
      verifyCode.value = ''
    }
  } catch (e) {
    showToast(e.message || '登录失败，请重试')
    refreshVerifyCode()
    verifyCode.value = ''
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="login-page">
    <van-nav-bar title="登录" left-arrow fixed placeholder safe-area-inset-top />

    <div class="login-form">
      <!-- Logo -->
      <div class="logo">
        <div class="logo-icon">&#x1F338;</div>
        <div class="logo-text">归途花店</div>
      </div>

      <!-- Form -->
      <van-form @submit="handleLogin">
        <van-field
          v-model="username"
          name="username"
          label="用户名"
          placeholder="请输入用户名"
          left-icon="user-o"
          :rules="[{ required: true, message: '请输入用户名' }]"
          clearable
        />

        <van-field
          v-model="password"
          type="password"
          name="password"
          label="密码"
          placeholder="请输入密码"
          left-icon="lock"
          :rules="[{ required: true, message: '请输入密码' }]"
          clearable
        />

        <van-field
          v-model="verifyCode"
          name="verifyCode"
          label="验证码"
          placeholder="请输入验证码"
          left-icon="shield-o"
          :rules="[{ required: true, message: '请输入验证码' }]"
          clearable
        >
          <template #button>
            <img
              :src="verifyCodeUrl"
              alt="验证码"
              class="verify-code-img"
              @click="refreshVerifyCode"
            />
          </template>
        </van-field>

        <div class="login-btn-wrap">
          <van-button
            round
            block
            type="danger"
            native-type="submit"
            :loading="loading"
            loading-text="登录中..."
          >
            登录
          </van-button>
        </div>
      </van-form>

      <!-- Options -->
      <div class="login-options">
        <label class="remember-opt">
          <input type="checkbox" v-model="rememberMe" />
          <span>记住我</span>
        </label>
        <span class="forgot-link" @click="showToast('请联系管理员重置密码')">忘记密码？</span>
      </div>

      <!-- Register link -->
      <div class="register-link">
        还没有账号？
        <router-link to="/register">立即注册</router-link>
      </div>
    </div>
  </div>
</template>

<style scoped>
.login-page {
  min-height: 100vh;
  background: #fff;
}

.login-form {
  padding: 40px 24px 0;
}

/* Logo */
.logo {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 40px;
}

.logo-icon {
  font-size: 56px;
  line-height: 1;
  margin-bottom: 12px;
}

.logo-text {
  font-size: 20px;
  font-weight: 600;
  color: #333;
  letter-spacing: 2px;
}

/* Verify code image */
.verify-code-img {
  height: 36px;
  cursor: pointer;
  border-radius: 4px;
  border: 1px solid #ebedf0;
}

/* Login options */
.login-options {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 16px;
  margin-top: 12px;
  font-size: 13px;
  color: #969799;
}
.remember-opt {
  display: flex;
  align-items: center;
  gap: 6px;
  cursor: pointer;
  min-height: 44px;
}
.remember-opt input[type="checkbox"] {
  width: 16px;
  height: 16px;
  accent-color: #ee0a24;
}
.forgot-link {
  cursor: pointer;
  min-height: 44px;
  display: flex;
  align-items: center;
}
.forgot-link:active { color: #ee0a24; }

/* Login button */
.login-btn-wrap {
  margin: 32px 16px 0;
}

.login-btn-wrap .van-button--danger {
  background: #ee0a24;
  border-color: #ee0a24;
  font-size: 16px;
  height: 44px;
}

/* Register link */
.register-link {
  text-align: center;
  margin-top: 24px;
  font-size: 14px;
  color: #999;
}

.register-link a {
  color: #ee0a24;
  text-decoration: none;
}
</style>
