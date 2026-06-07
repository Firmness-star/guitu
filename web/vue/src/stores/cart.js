import { defineStore } from 'pinia'
import { get, post, put, del } from '../api'

export const useCartStore = defineStore('cart', {
  state: () => ({
    items: [],
    totalAmount: 0,
    totalCount: 0
  }),
  actions: {
    async fetch() {
      const res = await get('/cart')
      if (res.code === 200) {
        this.items = res.data.items || []
        this.totalAmount = res.data.totalAmount
        this.totalCount = res.data.totalCount
      }
    },
    async add(productId, quantity = 1) {
      const body = new URLSearchParams()
      body.append('productId', productId)
      body.append('quantity', quantity)
      const res = await post('/cart', body)
      if (res.code === 200) await this.fetch()
      return res
    },
    async update(productId, quantity) {
      const res = await put(`/cart?productId=${productId}&quantity=${quantity}`)
      if (res.code === 200) await this.fetch()
      return res
    },
    async remove(productId) {
      const res = await del(`/cart?productId=${productId}`)
      if (res.code === 200) await this.fetch()
      return res
    },
    async clear() {
      const res = await del('/cart?action=clear')
      if (res.code === 200) this.items = []
      return res
    }
  }
})
