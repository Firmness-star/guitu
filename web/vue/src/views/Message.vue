<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showToast, showSuccessToast, showFailToast } from 'vant'
import { get, post } from '../api'
import { useUserStore } from '../stores/user'
import {
  NavBar, Cell, CellGroup, Field, Button, Empty, Loading, Tag, Icon
} from 'vant'

const router = useRouter()
const userStore = useUserStore()

const messages = ref([])
const loading = ref(true)
const content = ref('')
const submitting = ref(false)

async function fetchMessages() {
  loading.value = true
  try {
    const res = await get('/message')
    if (res.code === 200) messages.value = res.data || []
    else messages.value = []
  } catch { messages.value = [] }
  finally { loading.value = false }
}

async function sendMessage() {
  if (!content.value.trim()) { showToast('请输入留言内容'); return }
  submitting.value = true
  try {
    const res = await post('/message', { content: content.value })
    if (res.code === 200) {
      showSuccessToast('留言已发送')
      content.value = ''
      fetchMessages()
    } else { showFailToast(res.message || '发送失败') }
  } catch (e) { showFailToast(e.message || '网络错误') }
  finally { submitting.value = false }
}

onMounted(() => { if (userStore.loggedIn) fetchMessages() })
</script>

<template>
  <div class="msg-page">
    <NavBar title="留言板" left-arrow fixed placeholder safe-area-inset-top @click-left="router.back" />

    <!-- Send message -->
    <div class="send-section">
      <Field
        v-model="content"
        type="textarea"
        rows="3"
        placeholder="写下您的问题或建议，我们将尽快回复..."
        maxlength="500"
        show-word-limit
        :disabled="!userStore.loggedIn"
      />
      <div class="send-btn-wrap">
        <Button
          round
          type="primary"
          :loading="submitting"
          :disabled="!content.trim() || !userStore.loggedIn"
          @click="sendMessage"
          class="send-btn"
        >
          发送留言
        </Button>
      </div>
    </div>

    <!-- Login prompt -->
    <div v-if="!userStore.loggedIn" class="login-hint">
      <Empty description="请登录后留言">
        <Button type="primary" round @click="router.push('/login')">去登录</Button>
      </Empty>
    </div>

    <!-- Message list -->
    <div v-else-if="loading" class="loading-wrap">
      <Loading type="spinner" size="24" /> 加载中...
    </div>

    <div v-else-if="messages.length === 0" class="empty-wrap">
      <Empty description="暂无留言记录" />
    </div>

    <div v-else class="msg-list">
      <CellGroup inset>
        <Cell v-for="(msg, idx) in messages" :key="msg.id || idx">
          <template #title>
            <div class="msg-header">
              <Tag :type="msg.role === '管理员' ? 'danger' : 'primary'" round size="small">
                {{ msg.role || msg.username || '用户' }}
              </Tag>
              <span class="msg-time">{{ msg.createTime || msg.time || '' }}</span>
            </div>
          </template>
          <template #label>
            <div class="msg-content" :class="{ 'msg-admin': msg.role === '管理员' }">
              {{ msg.content }}
            </div>
            <div v-if="msg.reply" class="msg-reply">
              <Icon name="arrow-right" /> 管理员回复: {{ msg.reply }}
            </div>
          </template>
        </Cell>
      </CellGroup>
    </div>
  </div>
</template>

<style scoped>
.msg-page { min-height: 100vh; background: #f5f5f5; }
.send-section { background: #fff; padding: 16px; margin-bottom: 12px; }
.send-btn-wrap { display: flex; justify-content: flex-end; margin-top: 8px; }
.send-btn { min-width: 120px; min-height: 40px; }
.login-hint { margin-top: 40px; }
.loading-wrap { display: flex; align-items: center; justify-content: center; gap: 8px; padding: 60px 0; color: #969799; font-size: 13px; }
.empty-wrap { margin-top: 40px; }
.msg-list { padding: 0 0 12px; }
.msg-header { display: flex; align-items: center; gap: 8px; margin-bottom: 4px; }
.msg-time { font-size: 12px; color: #c8c9cc; }
.msg-content { font-size: 14px; color: #323233; line-height: 1.5; padding: 4px 0; }
.msg-admin { background: #fff8e6; padding: 8px 12px; border-radius: 6px; margin: 4px 0; }
.msg-reply { font-size: 13px; color: #ee0a24; margin-top: 6px; padding: 6px 10px; background: #fff5f5; border-radius: 4px; }
</style>