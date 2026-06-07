<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { showToast, showDialog } from 'vant'
import { areaList } from '@vant/area-data'
import { get, post, put, del } from '../api'

// ---------- state ----------
const addresses = ref([])
const showEdit = ref(false)
const editMode = ref('add')
const editId = ref(null)

const emptyAddress = () => ({
  id: '',
  name: '',
  tel: '',
  province: '',
  city: '',
  county: '',
  addressDetail: '',
  areaCode: '',
  isDefault: false
})

const editData = reactive(emptyAddress())

// ---------- api ----------
async function fetchAddresses() {
  try {
    const res = await get('/address')
    if (res.code === 200) {
      addresses.value = res.data.list || res.data || []
    } else {
      showToast(res.message || '获取地址失败')
    }
  } catch (e) {
    showToast(e.message || '网络错误')
  }
}

async function saveAddress(data) {
  try {
    const payload = {
      receiverName: data.name,
      receiverPhone: data.tel,
      province: data.province,
      city: data.city,
      district: data.county,
      detailAddress: data.addressDetail,
      areaCode: data.areaCode,
      isDefault: data.isDefault ? '1' : '0'
    }
    let res
    if (editMode.value === 'add') {
      res = await post('/address', payload)
    } else {
      const qs = new URLSearchParams({ id: editId.value, ...payload }).toString()
      res = await put(`/address?${qs}`)
    }
    if (res.code === 200) {
      showToast(editMode.value === 'add' ? '添加成功' : '修改成功')
      showEdit.value = false
      await fetchAddresses()
    } else {
      showToast(res.message || '保存失败')
    }
  } catch (e) {
    showToast(e.message || '网络错误')
  }
}

async function deleteAddress(id) {
  try {
    const res = await del(`/address?id=${id}`)
    if (res.code === 200) {
      showToast('删除成功')
      await fetchAddresses()
    } else {
      showToast(res.message || '删除失败')
    }
  } catch (e) {
    showToast(e.message || '网络错误')
  }
}

async function setDefaultAddress(id) {
  try {
    const qs = `id=${id}&action=setDefault`
    const res = await put(`/address?${qs}`)
    if (res.code === 200) {
      // 乐观更新
      addresses.value.forEach(a => { a.default = (a.id === id) })
      showToast('已设为默认地址')
      await fetchAddresses()
    } else {
      showToast(res.message || '设置失败')
    }
  } catch (e) {
    showToast(e.message || '网络错误')
  }
}

// ---------- handlers ----------
function onAdd() {
  editMode.value = 'add'
  editId.value = null
  Object.assign(editData, emptyAddress())
  showEdit.value = true
}

function onEdit(addr) {
  editMode.value = 'edit'
  editId.value = addr.id
  Object.assign(editData, {
    name: addr.receiverName || '',
    tel: addr.receiverPhone || '',
    province: addr.province || '',
    city: addr.city || '',
    county: addr.district || '',
    addressDetail: addr.detailAddress || '',
    areaCode: addr.areaCode || '',
    isDefault: !!addr.default
  })
  showEdit.value = true
}



function onSave(data) {
  saveAddress(data)
}


function onEditDelete() {
  showDialog({
    title: '确认删除',
    message: '确定要删除该地址吗？',
    showCancelButton: true,
    confirmButtonText: '删除',
    confirmButtonColor: '#ee0a24'
  }).then(() => {
    deleteAddress(editId.value)
    showEdit.value = false
  }).catch(() => {})
}

function onDelete(addr) {
  showDialog({
    title: '确认删除',
    message: `确定要删除 ${addr.receiverName} 的地址吗？`,
    showCancelButton: true,
    confirmButtonText: '删除',
    confirmButtonColor: '#ee0a24'
  }).then(() => {
    deleteAddress(addr.id)
  }).catch(() => {})
}

function onClickDefault(addr) {
  if (addr.default) return
  setDefaultAddress(addr.id)
}

function formatAddress(addr) {
  return `${addr.province || ''}${addr.city || ''}${addr.district || ''} ${addr.detailAddress || ''}`
}

// ---------- lifecycle ----------
onMounted(() => {
  fetchAddresses()
})
</script>

<template>
  <div class="address-page">
    <van-nav-bar
      title="收货地址"
      left-arrow
      fixed
      placeholder
      @click-left="$router.back()"
    />

    <!-- address list with swipe-to-delete -->
    <div v-if="addresses.length > 0" class="address-list">
      <van-swipe-cell v-for="addr in addresses" :key="addr.id">
        <van-cell
          :border="false"
          @click="onEdit(addr)"
        >
          <template #title>
            <div class="address-cell-title">
              <span class="address-name">{{ addr.receiverName }}</span>
              <span class="address-tel">{{ addr.receiverPhone }}</span>
              <van-tag v-if="addr.default" type="danger" size="medium" round>
                默认
              </van-tag>
            </div>
            <div class="address-detail">{{ formatAddress(addr) }}</div>
          </template>
          <template #right-icon>
            <van-icon name="edit" class="edit-icon" />
          </template>
          <template #label>
            <span
              v-if="!addr.default"
              class="set-default-link"
              @click.stop="onClickDefault(addr)"
            >设为默认</span>
          </template>
        </van-cell>
        <template #right>
          <van-button
            square
            type="danger"
            class="swipe-delete-btn"
            @click="onDelete(addr)"
          >
            删除
          </van-button>
        </template>
      </van-swipe-cell>
    </div>

    <van-empty
      v-else
      description="还没有收货地址，点击下方按钮添加"
    />

    <!-- add button -->
    <div class="add-btn-wrapper">
      <van-button
        round
        block
        type="primary"
        icon="plus"
        @click="onAdd"
      >
        添加新地址
      </van-button>
    </div>

    <!-- address edit popup -->
    <van-popup
      v-model:show="showEdit"
      position="right"
      :style="{ width: '100%', height: '100%' }"
      closeable
      close-icon-position="top-left"
      :key="editId || 'new'"
    >
      <van-address-edit
        :address-info="editData"
        :area-list="areaList"
        :show-delete="editMode === 'edit'"
        :show-set-default="true"
        :detail-max-length="60"
        :show-search-result="true"
        :is-saving="false"
        save-button-text="保存"
        delete-button-text="删除地址"
        @save="onSave"
        @delete="onEditDelete"
      />
    </van-popup>
  </div>
</template>

<style scoped>
.address-page {
  min-height: 100vh;
  background: #f5f5f5;
}

.address-list {
  background: #fff;
}

.address-cell-title {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 4px;
}

.address-name {
  font-size: 15px;
  font-weight: 500;
  color: #333;
}

.address-tel {
  font-size: 13px;
  color: #666;
}

.address-detail {
  font-size: 13px;
  color: #999;
  line-height: 1.4;
}

.edit-icon {
  font-size: 18px;
  color: #999;
}

.set-default-link {
  font-size: 12px;
  color: #1989fa;
  cursor: pointer;
  padding: 2px 4px;
  border-radius: 2px;
}
.set-default-link:active {
  opacity: 0.7;
}

.swipe-delete-btn {
  height: 100%;
  min-width: 65px;
  font-size: 15px;
}

.add-btn-wrapper {
  padding: 24px 16px;
  padding-bottom: calc(24px + env(safe-area-inset-bottom));
}
</style>
