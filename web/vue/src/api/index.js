import axios from 'axios'

const api = axios.create({
  baseURL: import.meta.env.PROD ? '' : '/api',
  timeout: 10000,
  withCredentials: true,
  headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
})

// transform: auto-convert objects to URLSearchParams
api.interceptors.request.use(config => {
  if (config.data && typeof config.data === 'object' && !(config.data instanceof URLSearchParams) && !(config.data instanceof FormData)) {
    const params = new URLSearchParams()
    for (const [k, v] of Object.entries(config.data)) {
      if (v != null) params.append(k, v)
    }
    config.data = params
  }
  return config
})

api.interceptors.response.use(
  res => res.data,
  err => {
    const msg = err.response?.data?.message || '网络错误'
    return Promise.reject(new Error(msg))
  }
)

export const get = (url, params) => api.get(url, { params })
export const post = (url, data) => api.post(url, data)
export const put = (url, data) => api.put(url, data)
export const del = (url, params) => api.delete(url, { params })

export default api
