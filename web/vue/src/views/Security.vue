<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showToast, showSuccessToast, showFailToast } from 'vant'
import { get, put } from '../api'
import { useUserStore } from '../stores/user'
import {
  NavBar, Cell, CellGroup, Field, Button, Form, Tag, Empty, Loading, Tab, Tabs
} from 'vant'

const router = useRouter()
const userStore = useUserStore()

const activeTab = ref(0)

// ── Password ──
const pwdForm = ref({ oldPwd: '', newPwd: '', confirmPwd: '' })
const pwdLoading = ref(false)

async function changePwd() {
  const { oldPwd, newPwd, confirmPwd } = pwdForm.value
  if (!oldPwd) { showToast('请输入原密码'); return }
  if (!newPwd || newPwd.length < 6) { showToast('新密码至少6位'); return }
  if (newPwd !== confirmPwd) { showToast('两次密码不一致'); return }
  pwdLoading.value = true
  try {
    const res = await put('/user', { action: 'changePwd', oldPassword: oldPwd, newPassword: newPwd })
    if (res.code === 200) {
      showSuccessToast('密码修改成功')
      pwdForm.value = { oldPwd: '', newPwd: '', confirmPwd: '' }
    } else { showFailToast(res.message || '修改失败') }
  } catch (e) { showFailToast(e.message || '网络错误') }
  finally { pwdLoading.value = false }
}

// ── Login logs ──
const logs = ref([])
const logsLoading = ref(true)

async function fetchLogs() {
  logsLoading.value = true
  try {
    const res = await get('/user?action=loginLogs')
    if (res.code === 200) logs.value = res.data || []
    else logs.value = []
  } catch { logs.value = [] }
  finally { logsLoading.value = false }
}

onMounted(() => { if (userStore.loggedIn) fetchLogs() })
</script>

<template>
  <div class="security-page">
    <NavBar title="安全中心" left-arrow fixed placeholder safe-area-inset-top @click-left="router.back" />

    <Tabs v-model:active="activeTab" sticky>
      <Tab title="修改密码">
        <div class="form-wrap">
          <CellGroup inset>
            <Field v-model="pwdForm.oldPwd" type="password" label="原密码" placeholder="请输入原密码" clearable />
            <Field v-model="pwdForm.newPwd" type="password" label="新密码" placeholder="至少6位" clearable />
            <Field v-model="pwdForm.confirmPwd" type="password" label="确认密码" placeholder="再次输入" clearable />
          </CellGroup>
          <div class="submit-wrap">
            <Button round block type="primary" :loading="pwdLoading" @click="changePwd" class="submit-btn">
              确认修改
            </Button>
          </div>
        </div>
      </Tab>

      <Tab title="登录日志">
        <div v-if="logsLoading" class="loading-wrap">
          <Loading type="spinner" size="24" /> 加载中...
        </div>
        <Empty v-else-if="logs.length === 0" description="暂无登录记录" />
        <div v-else class="log-list">
          <CellGroup inset>
            <Cell v-for="(log, idx) in logs" :key="idx">
              <template #title>
                <div class="log-time">{{ log.loginTime || log.time || '' }}</div>
              </template>
              <template #label>
                <div class="log-detail">
                  <span>IP: {{ log.ip || '-' }}</span>
                </div>
              </template>
              <template #value>
                <Tag plain :type="idx === 0 ? 'success' : 'default'">
                  {{ idx === 0 ? '当前' : '历史' }}
                </Tag>
              </template>
            </Cell>
          </CellGroup>
        </div>
      </Tab>
    </Tabs>
  </div>
</template>

<style scoped>
.security-page { min-height: 100vh; background: #f5f5f5; }
.form-wrap { padding: 16px; }
.submit-wrap { padding: 24px 16px; }
.submit-btn { min-height: 44px; font-size: 15px; font-weight: 600; }
.loading-wrap { display: flex; align-items: center; justify-content: center; gap: 8px; padding: 60px 0; color: #969799; font-size: 13px; }
.log-list { padding: 12px 0; }
.log-time { font-size: 13px; font-weight: 600; color: #323233; }
.log-detail { font-size: 12px; color: #969799; margin-top: 2px; }
</style>