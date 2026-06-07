<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showToast, showSuccessToast, showFailToast } from 'vant'
import { get, post } from '../api'
import { useUserStore } from '../stores/user'
import {
  NavBar, Cell, CellGroup, Field, Button, Empty, Loading, Tag
} from 'vant'

const router = useRouter()
const userStore = useUserStore()

// ── Password ──
const oldPwd = ref('')
const newPwd = ref('')
const confirmPwd = ref('')
const pwdLoading = ref(false)

async function changePwd() {
  if (!oldPwd.value) { showToast('请输入原密码'); return }
  if (!newPwd.value || newPwd.value.length < 6) { showToast('新密码至少6位'); return }
  if (newPwd.value !== confirmPwd.value) { showToast('两次密码不一致'); return }
  pwdLoading.value = true
  try {
    const res = await userStore.changePwd(oldPwd.value, newPwd.value)
    if (res.code === 200) {
      showSuccessToast('密码修改成功')
      oldPwd.value = ''
      newPwd.value = ''
      confirmPwd.value = ''
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
    if (res.code === 200) logs.value = Array.isArray(res.data) ? res.data : []
    else logs.value = []
  } catch { logs.value = [] }
  finally { logsLoading.value = false }
}

onMounted(() => { if (userStore.loggedIn) fetchLogs() })
</script>

<template>
  <div class="security-page">
    <NavBar title="安全中心" left-arrow fixed placeholder safe-area-inset-top @click-left="router.back" />

    <!-- Password -->
    <div class="section">
      <div class="section-header">
        <span class="section-title">修改密码</span>
      </div>
      <CellGroup :border="false">
        <Field v-model="oldPwd" type="password" label="原密码" placeholder="请输入原密码" />
        <Field v-model="newPwd" type="password" label="新密码" placeholder="至少6位" />
        <Field v-model="confirmPwd" type="password" label="确认密码" placeholder="再次输入" />
      </CellGroup>
      <div class="btn-wrap">
        <Button round block type="primary" :loading="pwdLoading" @click="changePwd">
          确认修改
        </Button>
      </div>
    </div>

    <!-- Login logs -->
    <div class="section">
      <div class="section-header">
        <span class="section-title">登录日志</span>
      </div>
      <div v-if="logsLoading" class="center-wrap">
        <Loading type="spinner" size="24" />
        <span style="font-size:13px;color:#999">加载中...</span>
      </div>
      <Empty v-else-if="logs.length === 0" description="暂无登录记录" />
      <CellGroup v-else :border="false">
        <Cell v-for="(log, idx) in logs" :key="idx">
          <template #title>
            <span class="log-time">{{ log.loginTime || log.time || '' }}</span>
          </template>
          <template #label>
            <span class="log-detail">IP: {{ log.loginIp || log.ip || '-' }}</span>
          </template>
          <template #value>
            <Tag :type="idx === 0 ? 'success' : 'default'" plain size="small" round>
              {{ idx === 0 ? '最近' : '历史' }}
            </Tag>
          </template>
        </Cell>
      </CellGroup>
    </div>
  </div>
</template>

<style scoped>
.security-page { min-height: 100vh; background: #f5f7fa; padding-bottom: 30px; }

.section {
  margin: 12px 16px;
  background: #fff;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 1px 4px rgba(0,0,0,0.04);
}
.section-header { padding: 16px 16px 4px; }
.section-title { font-size: 15px; font-weight: 600; color: #333; }
.btn-wrap { padding: 16px; }

.center-wrap {
  display: flex; align-items: center; justify-content: center;
  gap: 8px; padding: 32px 0;
}

.log-time { font-size: 13px; color: #323233; }
.log-detail { font-size: 12px; color: #999; margin-top: 2px; }
</style>
