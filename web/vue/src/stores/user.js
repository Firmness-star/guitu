import { defineStore } from 'pinia'
import { post, get, put } from '../api'

export const useUserStore = defineStore('user', {
  state: () => ({
    id: null,
    username: '',
    role: '',
    email: '',
    phone: '',
    avatar: '',
    jf: 0,
    loggedIn: false
  }),
  actions: {
    async login(username, password, verifyCode) {
      const body = new URLSearchParams()
      body.append('username', username)
      body.append('password', password)
      body.append('verifyCode', verifyCode)
      const res = await post('/login', body)
      if (res.code === 200) {
        Object.assign(this, { ...res.data, loggedIn: true })
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
        Object.assign(this, { ...res.data, loggedIn: true })
      }
      return res
    },
    async updateProfile(tel, email) {
      const body = new URLSearchParams()
      body.append('action', 'updateInfo')
      body.append('tel', tel)
      body.append('email', email)
      return await put('/user', body)
    },
    async changePwd(oldPassword, newPassword) {
      const body = new URLSearchParams()
      body.append('action', 'changePwd')
      body.append('oldPassword', oldPassword)
      body.append('newPassword', newPassword)
      return await put('/user', body)
    },
    logout() {
      this.$reset()
    }
  }
})
