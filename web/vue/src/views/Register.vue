<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { showToast } from 'vant'
import { useUserStore } from '../stores/user'

const router = useRouter()
const userStore = useUserStore()

const formRef = ref(null)
const submitting = ref(false)
const agreeTerms = ref(false)
const verifyCodeSrc = ref('/verifyCode?t=' + Date.now())

const form = reactive({
  username: '',
  phone: '',
  email: '',
  password: '',
  confirmPassword: '',
  verifyCode: ''
})

function refreshCode() {
  verifyCodeSrc.value = '/verifyCode?t=' + Date.now()
}

function validateUsername(val) {
  if (!val) return '请输入用户名'
  if (val.length < 2) return '用户名至少2个字符'
  if (val.length > 20) return '用户名最多20个字符'
  return true
}

function validatePhone(val) {
  if (!val) return '请输入手机号'
  if (!/^1[3-9]\d{9}$/.test(val)) return '手机号格式不正确'
  return true
}

function validateEmail(val) {
  if (!val) return '请输入邮箱'
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(val)) return '邮箱格式不正确'
  return true
}

function validatePassword(val) {
  if (!val) return '请输入密码'
  if (val.length < 6) return '密码至少6位'
  if (val.length > 20) return '密码最多20位'
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

async function onSubmit() {
  if (submitting.value) return
  try {
    await formRef.value?.validate()
  } catch {
    showToast('请完善表单信息')
    return
  }

  submitting.value = true
  try {
    const res = await userStore.register({
      username: form.username,
      phone: form.phone,
      email: form.email,
      password: form.password,
      verifyCode: form.verifyCode
    })
    if (res.code === 200) {
      showToast('注册成功')
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
    <van-nav-bar title="注册" left-arrow @click-left="router.back" fixed placeholder />

    <div class="register-form">
      <van-form ref="formRef" @submit="onSubmit">
        <van-field
          v-model="form.username"
          name="username"
          label="用户名"
          placeholder="请输入用户名"
          :rules="[{ validator: validateUsername, trigger: 'onBlur' }]"
          maxlength="20"
          clearable
        />
        <van-field
          v-model="form.phone"
          name="phone"
          label="手机号"
          placeholder="请输入手机号"
          :rules="[{ validator: validatePhone, trigger: 'onBlur' }]"
          type="tel"
          maxlength="11"
          clearable
        />
        <van-field
          v-model="form.email"
          name="email"
          label="邮箱"
          placeholder="请输入邮箱"
          :rules="[{ validator: validateEmail, trigger: 'onBlur' }]"
          type="email"
          clearable
        />
        <van-field
          v-model="form.password"
          name="password"
          label="密码"
          placeholder="请输入密码"
          :rules="[{ validator: validatePassword, trigger: 'onBlur' }]"
          type="password"
          maxlength="20"
          clearable
        />
        <van-field
          v-model="form.confirmPassword"
          name="confirmPassword"
          label="确认密码"
          placeholder="请再次输入密码"
          :rules="[{ validator: validateConfirmPassword, trigger: 'onBlur' }]"
          type="password"
          maxlength="20"
          clearable
        />
        <van-field
          v-model="form.verifyCode"
          name="verifyCode"
          label="验证码"
          placeholder="请输入验证码"
          :rules="[{ validator: validateVerifyCode, trigger: 'onBlur' }]"
          maxlength="4"
          clearable
        >
          <template #button>
            <img
              :src="verifyCodeSrc"
              alt="验证码"
              class="verify-code-img"
              @click="refreshCode"
            />
          </template>
        </van-field>

        <div class="agreement-row">
          <label class="agreement-opt">
            <input type="checkbox" v-model="agreeTerms" />
            <span>我已阅读并同意 <a href="javascript:void(0)" @click="showToast('用户协议内容')">用户协议</a></span>
          </label>
        </div>

        <div class="submit-wrapper">
          <van-button
            round
            block
            type="primary"
            native-type="submit"
            :loading="submitting"
            :disabled="!agreeTerms"
            loading-text="注册中..."
          >
            注册
          </van-button>
        </div>
      </van-form>

      <div class="login-link">
        已有账号？
        <router-link to="/login">立即登录</router-link>
      </div>
    </div>
  </div>
</template>

<style scoped>
.register-page {
  min-height: 100vh;
  background: #f5f5f5;
}

.register-form {
  padding: 16px;
}

.submit-wrapper {
  margin: 24px 16px 0;
}

.agreement-row {
  display: flex;
  align-items: center;
  padding: 12px 16px 0;
  font-size: 13px;
  color: #969799;
}
.agreement-opt {
  display: flex;
  align-items: center;
  gap: 6px;
  cursor: pointer;
  min-height: 44px;
}
.agreement-opt input[type="checkbox"] {
  width: 16px;
  height: 16px;
  accent-color: #ee0a24;
}
.agreement-opt a { color: #1989fa; text-decoration: none; }

.verify-code-img {
  width: 100px;
  height: 40px;
  cursor: pointer;
  border-radius: 4px;
  border: 1px solid #ebedf0;
}

.login-link {
  text-align: center;
  margin-top: 24px;
  font-size: 14px;
  color: #969799;
}

.login-link a {
  color: #1989fa;
  text-decoration: none;
}
</style>
