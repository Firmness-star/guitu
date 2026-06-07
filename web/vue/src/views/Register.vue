<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { showToast, showSuccessToast } from 'vant'
import { get, post } from '../api'
import { useUserStore } from '../stores/user'

const router = useRouter()
const userStore = useUserStore()

const submitting = ref(false)
const agreeTerms = ref(false)
const verifyCodeSrc = ref('/verifyCode?t=' + Date.now())

const form = reactive({
  username: '',
  tel: '',
  email: '',
  password: '',
  confirmPassword: '',
  verifyCode: ''
})

// ── Real-time availability ──
const usernameStatus = ref('')
const telStatus = ref('')
const emailStatus = ref('')
const timers = {}

async function doCheckField(apiField, value, statusRef) {
  const v = value.trim()
  if (!v) { statusRef.value = ''; return }
  statusRef.value = 'checking'
  try {
    const action = { username: 'checkUsername', tel: 'checkTel', email: 'checkEmail' }[apiField]
    const params = {}
    params[apiField] = v
    const res = await get('/register', { action, ...params })
    statusRef.value = res.code === 200 ? 'available' : 'unavailable'
  } catch {
    statusRef.value = 'unavailable'
  }
}

function scheduleCheck(apiField, value, statusRef) {
  if (timers[apiField]) clearTimeout(timers[apiField])
  if (!value || !value.trim()) { statusRef.value = ''; return }
  timers[apiField] = setTimeout(() => doCheckField(apiField, value, statusRef), 500)
}

function onUsernameChange(val) { form.username = val || ''; scheduleCheck('username', form.username, usernameStatus) }
function onTelChange(val)     { form.tel = (val || '').replace(/\D/g, ''); scheduleCheck('tel', form.tel, telStatus) }
function onEmailChange(val)   { form.email = val || ''; scheduleCheck('email', form.email, emailStatus) }

function statusText(s) {
  return { checking: '检测中...', available: '✓ 可用', unavailable: '✗ 不可用' }[s] || ''
}
function statusClass(s) {
  return { checking: 'checking', available: 'ok', unavailable: 'fail' }[s] || ''
}

// ── Validation ──
function validateUsername(val) {
  if (!val) return '请输入用户名'
  if (val.length < 3 || val.length > 20) return '用户名应为3-20位'
  if (!/^[a-zA-Z0-9_]+$/.test(val)) return '只能包含字母、数字和下划线'
  return usernameStatus.value === 'unavailable' ? '该用户名已被占用' : true
}
function validateTel(val) {
  if (!val) return '请输入手机号'
  if (!/^1[3-9]\d{9}$/.test(val)) return '手机号格式不正确'
  return telStatus.value === 'unavailable' ? '该手机号已被占用' : true
}
function validateEmail(val) {
  if (!val) return '请输入邮箱'
  if (!/^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/.test(val)) return '邮箱格式不正确'
  return emailStatus.value === 'unavailable' ? '该邮箱已被占用' : true
}
function validatePassword(val) {
  if (!val) return '请输入密码'
  if (val.length < 6 || val.length > 20) return '密码长度应为6-20位'
  return true
}
function validateConfirmPassword(val) {
  if (!val) return '请确认密码'
  if (val !== form.password) return '两次密码不一致'
  return true
}
function validateVerifyCode(val) {
  if (!val) return '请输入验证码'
  return true
}

function refreshCode() {
  verifyCodeSrc.value = '/verifyCode?t=' + Date.now()
}

// ── Submit ──
async function onSubmit() {
  if (!agreeTerms.value) { showToast('请先同意用户协议'); return }
  if (submitting.value) return
  submitting.value = true
  try {
    const res = await post('/register', {
      username: form.username.trim(),
      tel: form.tel.trim(),
      email: form.email.trim(),
      password: form.password,
      confirmPassword: form.confirmPassword,
      verifyCode: form.verifyCode.trim()
    })
    if (res.code === 200) {
      showSuccessToast('注册成功')
      router.push('/login')
    } else {
      showToast(res.message || '注册失败')
      refreshCode()
    }
  } catch (e) {
    showToast(e.message || '注册失败')
    refreshCode()
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <div class="register-page">
    <van-nav-bar title="注册" left-arrow fixed placeholder safe-area-inset-top @click-left="router.back" />

    <div class="register-body">
      <!-- Brand -->
      <div class="brand-header">
        <h1>🌸 归途</h1>
        <p>加入花店商城，开启美好生活</p>
      </div>

      <van-form @submit="onSubmit">
        <van-field
          :model-value="form.username"
          name="username"
          label="用户名"
          placeholder="设置用户名（3-20位字母、数字、下划线）"
          :rules="[{ validator: validateUsername, trigger: 'onBlur' }]"
          maxlength="20"
          clearable
          @update:model-value="onUsernameChange"
        >
          <template #extra>
            <span :class="'field-status ' + statusClass(usernameStatus)">{{ statusText(usernameStatus) }}</span>
          </template>
        </van-field>

        <van-field
          :model-value="form.tel"
          name="tel"
          label="手机号"
          placeholder="11位手机号"
          :rules="[{ validator: validateTel, trigger: 'onBlur' }]"
          type="tel"
          maxlength="11"
          clearable
          @update:model-value="onTelChange"
        >
          <template #extra>
            <span :class="'field-status ' + statusClass(telStatus)">{{ statusText(telStatus) }}</span>
          </template>
        </van-field>

        <van-field
          :model-value="form.email"
          name="email"
          label="邮箱"
          placeholder="example@email.com"
          :rules="[{ validator: validateEmail, trigger: 'onBlur' }]"
          type="email"
          clearable
          @update:model-value="onEmailChange"
        >
          <template #extra>
            <span :class="'field-status ' + statusClass(emailStatus)">{{ statusText(emailStatus) }}</span>
          </template>
        </van-field>

        <van-field
          v-model="form.password"
          name="password"
          label="密码"
          placeholder="设置密码（6-20位）"
          :rules="[{ validator: validatePassword, trigger: 'onBlur' }]"
          type="password"
          maxlength="20"
          clearable
        />
        <van-field
          v-model="form.confirmPassword"
          name="confirmPassword"
          label="确认密码"
          placeholder="再次输入密码"
          :rules="[{ validator: validateConfirmPassword, trigger: 'onBlur' }]"
          type="password"
          maxlength="20"
          clearable
        />

        <van-field
          v-model="form.verifyCode"
          name="verifyCode"
          label="验证码"
          placeholder="验证码"
          :rules="[{ validator: validateVerifyCode, trigger: 'onBlur' }]"
          maxlength="4"
          clearable
        >
          <template #button>
            <img :src="verifyCodeSrc" alt="验证码" class="verify-img" @click="refreshCode" />
          </template>
        </van-field>

        <div class="agreement-row">
          <van-checkbox v-model="agreeTerms" icon-size="15px">
            我已阅读并同意<span class="agreement-link">用户协议</span>和<span class="agreement-link">隐私政策</span>
          </van-checkbox>
        </div>

        <div class="submit-wrapper">
          <van-button
            round
            block
            type="primary"
            native-type="submit"
            :loading="submitting"
            loading-text="注册中..."
          >
            注册
          </van-button>
        </div>
      </van-form>

      <div class="login-link">
        已有账号？<router-link to="/login">立即登录</router-link>
        <span class="divider">|</span>
        <router-link to="/">返回首页</router-link>
      </div>
    </div>
  </div>
</template>

<style scoped>
.register-page { min-height: 100vh; background: #f5f7fa; padding-bottom: 30px; }

.register-body { padding: 20px 16px; }

/* Brand */
.brand-header { text-align: center; margin-bottom: 24px; }
.brand-header h1 {
  background: linear-gradient(135deg, #e74c3c 0%, #ff6b6b 100%);
  -webkit-background-clip: text; -webkit-text-fill-color: transparent;
  font-size: 28px; font-weight: 700; margin: 0 0 6px;
}
.brand-header p { color: #999; font-size: 13px; margin: 0; }

/* Field status */
.field-status { font-size: 11px; margin-left: 4px; }
.field-status.checking { color: #999; }
.field-status.ok { color: #27ae60; }
.field-status.fail { color: #e74c3c; }

/* Verify img */
.verify-img { width: 90px; height: 36px; cursor: pointer; border-radius: 4px; border: 1px solid #ebedf0; }

/* Agreement */
.agreement-row { padding: 12px 16px 0; }
.agreement-link { color: #1989fa; text-decoration: none; }

/* Submit */
.submit-wrapper { margin: 20px 16px 0; }

/* Login link */
.login-link { text-align: center; margin-top: 24px; font-size: 13px; color: #999; }
.login-link a { color: #1989fa; text-decoration: none; margin: 0 4px; font-weight: 500; }
.login-link .divider { color: #ddd; }
</style>
