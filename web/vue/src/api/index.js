import axios from 'axios'

const api = axios.create({
  baseURL: import.meta.env.PROD ? '' : '/api',
  timeout: 10000,
  withCredentials: true
})

// transform: auto-convert objects to URLSearchParams, set correct Content-Type
api.interceptors.request.use(config => {
  if (config.data && typeof config.data === 'object' && !(config.data instanceof URLSearchParams) && !(config.data instanceof FormData)) {
    config.headers['Content-Type'] = 'application/x-www-form-urlencoded'
    const params = new URLSearchParams()
    for (const [k, v] of Object.entries(config.data)) {
      if (v != null) params.append(k, v)
    }
    config.data = params
  }
  if (config.data instanceof URLSearchParams) {
    config.headers['Content-Type'] = 'application/x-www-form-urlencoded'
  }
  // For FormData, let the browser set Content-Type automatically
  if (config.data instanceof FormData) {
    delete config.headers['Content-Type']
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
