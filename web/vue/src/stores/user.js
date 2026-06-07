import { defineStore } from 'pinia'
import { post, get, put } from '../api'

export const useUserStore = defineStore('user', {
  state: () => ({
    id: null,
    username: '',
    role: '',
    email: '',
    phone: '',
    gender: '',
    avatar: '',
    jf: 0,
    createTime: '',
    lastLoginTime: '',
    loggedIn: false
  }),
  actions: {
    _applyProfile(data) {
      Object.assign(this, {
        id: data.id,
        username: data.username,
        role: data.role,
        email: data.email || '',
        phone: data.tel || data.phone || '',
        gender: data.gender || '',
        avatar: data.avatar || '',
        jf: data.jf || 0,
        createTime: data.createTime || '',
        lastLoginTime: data.lastLoginTime || '',
        loggedIn: true
      })
    },
    async login(username, password, verifyCode) {
      const body = new URLSearchParams()
      body.append('username', username)
      body.append('password', password)
      body.append('verifyCode', verifyCode)
      const res = await post('/login', body)
      if (res.code === 200) {
        this._applyProfile(res.data)
      }
      return res
    },
    async register(data) {
      const body = new URLSearchParams()
      for (const [k, v] of Object.entries(data)) {
        if (v != null) body.append(k, v)
      }
      return await post('/register', body)
    },
    async fetchProfile() {
      const res = await get('/user')
      if (res.code === 200) {
        this._applyProfile(res.data)
      }
      return res
    },
    async updateProfile(tel, email, gender) {
      return await post('/user', {
        action: 'updateInfo',
        tel: tel,
        email: email,
        gender: gender || ''
      })
    },
    async changePwd(oldPassword, newPassword) {
      return await post('/user', {
        action: 'changePwd',
        oldPassword: oldPassword,
        newPassword: newPassword
      })
    },
    async fetchJfLogs(limit = 50) {
      return await get('/user', { action: 'jfLogs', limit })
    },
    async logout() {
      try { await post('/logout') } catch {}
      this.$reset()
    }
  }
})
