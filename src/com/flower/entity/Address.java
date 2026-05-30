package com.flower.entity;

import java.io.Serializable;
import java.util.Date;

/**
 * 收货地址实体类
 * 用于封装用户的收货地址信息，支持序列化存储
 */
public class Address implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int userId;
    private String receiverName;
    private String receiverPhone;
    private String province;
    private String city;
    private String district;
    private String detailAddress;
    private boolean isDefault;
    private Date createTime;
    private Date updateTime;

    /**
     * 无参构造函数
     */
    public Address() {
    }

    /**
     * 带参构造函数，初始化收货地址基本信息
     *
     * @param userId        用户 ID
     * @param receiverName  收件人姓名
     * @param receiverPhone 收件人电话
     * @param province      省份
     * @param city          城市
     * @param district      区/县
     * @param detailAddress 详细地址
     */
    public Address(int userId, String receiverName, String receiverPhone,
                   String province, String city, String district, String detailAddress) {
        this.userId = userId;
        this.receiverName = receiverName;
        this.receiverPhone = receiverPhone;
        this.province = province;
        this.city = city;
        this.district = district;
        this.detailAddress = detailAddress;
        this.isDefault = false;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getReceiverName() {
        return receiverName;
    }

    public void setReceiverName(String receiverName) {
        this.receiverName = receiverName;
    }

    public String getReceiverPhone() {
        return receiverPhone;
    }

    public void setReceiverPhone(String receiverPhone) {
        this.receiverPhone = receiverPhone;
    }

    public String getProvince() {
        return province;
    }

    public void setProvince(String province) {
        this.province = province;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getDistrict() {
        return district;
    }

    public void setDistrict(String district) {
        this.district = district;
    }

    public String getDetailAddress() {
        return detailAddress;
    }

    public void setDetailAddress(String detailAddress) {
        this.detailAddress = detailAddress;
    }

    public boolean isDefault() {
        return isDefault;
    }

    public void setDefault(boolean aDefault) {
        isDefault = aDefault;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    public Date getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(Date updateTime) {
        this.updateTime = updateTime;
    }

    /**
     * 获取拼接后的完整收货地址字符串
     *
     * @return 包含省、市、区及详细地址的完整字符串
     */
    public String getFullAddress() {
        return province + city + district + detailAddress;
    }

    @Override
    public String toString() {
        return "Address{" +
                "id=" + id +
                ", userId=" + userId +
                ", receiverName='" + receiverName + '\'' +
                ", receiverPhone='" + receiverPhone + '\'' +
                ", fullAddress='" + getFullAddress() + '\'' +
                ", isDefault=" + isDefault +
                '}';
    }
}
