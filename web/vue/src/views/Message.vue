<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { showToast, showSuccessToast, showFailToast } from 'vant'
import { get, post } from '../api'
import { useUserStore } from '../stores/user'
import {
  NavBar, Cell, CellGroup, Field, Button, Empty, Loading, Icon, Dialog
} from 'vant'

const router = useRouter()
const userStore = useUserStore()

const messages = ref([])
const loading = ref(true)
const error = ref('')
const content = ref('')
const submitting = ref(false)

// per-message reply state
const replyTexts = reactive({})
const replySubmitting = reactive({})

async function fetchMessages() {
  loading.value = true
  error.value = ''
  try {
    const res = await get('/message')
    if (res.code === 200) {
      messages.value = Array.isArray(res.data) ? res.data : []
    } else {
      messages.value = []
    }
  } catch (e) {
    error.value = e.message || '加载失败'
    messages.value = []
  } finally { loading.value = false }
}

async function sendMessage() {
  const val = content.value.trim()
  if (!val) { showToast('请输入留言内容'); return }
  submitting.value = true
  try {
    const res = await post('/message', { content: val })
    if (res.code === 200) {
      showSuccessToast('留言已发送')
      content.value = ''
      await fetchMessages()
    } else { showFailToast(res.message || '发送失败') }
  } catch (e) { showFailToast(e.message || '网络错误') }
  finally { submitting.value = false }
}

async function submitReply(msgId) {
  const val = (replyTexts[msgId] || '').trim()
  if (!val) { showToast('请输入回复内容'); return }
  replySubmitting[msgId] = true
  try {
    const res = await post('/message', { action: 'reply', msgId: String(msgId), content: val })
    if (res.code === 200) {
      showSuccessToast('回复成功')
      replyTexts[msgId] = ''
      await fetchMessages()
    } else { showFailToast(res.message || '回复失败') }
  } catch (e) { showFailToast(e.message || '网络错误') }
  finally { replySubmitting[msgId] = false }
}

function formatTime(val) {
  if (!val) return ''
  const s = String(val)
  return s.length <= 10 ? s : s.substring(0, 16)
}

onMounted(async () => {
  if (!userStore.loggedIn) {
    await userStore.fetchProfile()
  }
  if (userStore.loggedIn) {
    fetchMessages()
  } else {
    loading.value = false
  }
})
</script>

<template>
  <div class="msg-page">
    <NavBar title="我的留言" left-arrow fixed placeholder safe-area-inset-top @click-left="router.back" />

    <!-- Guest -->
    <template v-if="!userStore.loggedIn && !loading">
      <Empty description="请登录后留言">
        <Button type="primary" round @click="router.push('/login')">去登录</Button>
      </Empty>
    </template>

    <template v-else>
      <!-- Send area -->
      <div class="send-section">
        <Field
          v-model="content"
          type="textarea"
          rows="3"
          placeholder="请在此输入您对商城的意见或建议..."
          maxlength="500"
          show-word-limit
        />
        <div class="send-btn-wrap">
          <Button
            round
            type="primary"
            :loading="submitting"
            :disabled="!content.trim()"
            @click="sendMessage"
          >
            发送留言
          </Button>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="center-wrap">
        <Loading type="spinner" size="24" />
        <span class="loading-text">加载中...</span>
      </div>

      <!-- Error -->
      <div v-else-if="error" class="center-wrap">
        <Empty :description="error">
          <Button type="primary" size="small" round @click="fetchMessages">重试</Button>
        </Empty>
      </div>

      <!-- Empty -->
      <div v-else-if="!messages.length" class="center-wrap">
        <Empty description="暂无留言记录" />
      </div>

      <!-- Message list -->
      <div v-else class="msg-list">
        <div v-for="msg in messages" :key="msg.id" class="msg-card">
          <!-- Header -->
          <div class="msg-card-header">
            <span class="msg-time">{{ formatTime(msg.createTime) }}</span>
          </div>

          <!-- Original content -->
          <div class="msg-content">{{ msg.content }}</div>

          <!-- Conversation thread -->
          <div v-if="msg.replies && msg.replies.length" class="msg-conversation">
            <div
              v-for="(r, ri) in msg.replies"
              :key="ri"
              class="conv-item"
              :class="r.role === 'admin' ? 'conv-admin' : 'conv-user'"
            >
              <span class="conv-role">{{ r.role === 'admin' ? '管理员' : '我说' }}</span>
              <span class="conv-text">{{ r.text }}</span>
            </div>
          </div>

          <!-- Reply input -->
          <div class="msg-reply-row">
            <Field
              v-model="replyTexts[msg.id]"
              :placeholder="msg.replies && msg.replies.length ? '继续回复...' : '补充留言...'"
              size="small"
              :border="false"
              class="reply-input"
            >
              <template #button>
                <Button
                  size="small"
                  type="primary"
                  :loading="replySubmitting[msg.id]"
                  @click="submitReply(msg.id)"
                >
                  发送
                </Button>
              </template>
            </Field>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<style scoped>
.msg-page { min-height: 100vh; background: #f5f7fa; padding-bottom: 30px; }

/* ── Send ── */
.send-section {
  background: #fff;
  padding: 12px 16px 8px;
  margin-bottom: 10px;
}
.send-btn-wrap { display: flex; justify-content: flex-end; margin-top: 8px; }

/* ── Center ── */
.center-wrap {
  display: flex; flex-direction: column; align-items: center;
  padding: 60px 0; gap: 8px;
}
.loading-text { font-size: 13px; color: #999; }

/* ── Message cards ── */
.msg-list { padding: 0 12px; }
.msg-card {
  background: #fff;
  border-radius: 12px;
  padding: 14px 16px;
  margin-bottom: 10px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.04);
}
.msg-card-header {
  display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 8px;
}
.msg-time { font-size: 12px; color: #bbb; }
.msg-content {
  font-size: 14px; color: #333; line-height: 1.5;
  padding: 10px 12px; background: #f8f8f8;
  border-radius: 8px; margin-bottom: 8px;
}

/* ── Conversation ── */
.msg-conversation {
  margin-bottom: 8px; padding: 10px 12px;
  background: #fafafa; border-radius: 8px;
}
.conv-item { padding: 6px 0; font-size: 13px; line-height: 1.5; }
.conv-item:not(:last-child) { border-bottom: 1px solid #f0f0f0; }
.conv-admin { color: #155724; }
.conv-user { color: #856404; }
.conv-role { font-weight: 600; margin-right: 4px; }
.conv-admin .conv-role { color: #27ae60; }
.conv-user .conv-role { color: #e67e22; }
.conv-text { word-break: break-word; }

/* ── Reply input ── */
.msg-reply-row { margin-top: 6px; }
.reply-input {
  --van-cell-background: #f8f9fa;
  border-radius: 8px;
  padding: 4px 0;
}
</style>
