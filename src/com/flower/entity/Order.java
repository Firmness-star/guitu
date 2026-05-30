package com.flower.entity;

import java.io.Serializable;
import java.util.Date;
import java.util.List;
import java.util.ArrayList;

/**
 * 订单实体类
 * 用于封装订单的完整信息，包括收货人详情、订单状态及包含的商品列表
 */
public class Order implements Serializable {
    private static final long serialVersionUID = 1L;

    private String orderId;
    private Integer userId;
    private String username;
    private Date createTime;
    private double totalAmount;
    private int totalCount;
    private String status;
    private String receiverName;
    private String receiverPhone;
    private String receiverAddress;
    private String remark;
    private String wlNo;       // 物流编号
    private List<CartItem> items;

    /**
     * 无参构造函数，初始化订单为默认状态（待付款）并创建空商品列表
     */
    public Order() {
        this.items = new ArrayList<>();
        this.createTime = new Date();
        this.status = "待付款";
    }

    /**
     * 生成唯一的订单编号，基于当前时间戳
     *
     * @return 格式为 "ORD" + 时间戳 的字符串
     */
    public static String generateOrderId() {
        return "ORD" + System.currentTimeMillis();
    }

    public String getOrderId() {
        return orderId;
    }

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public int getTotalCount() {
        return totalCount;
    }

    public void setTotalCount(int totalCount) {
        this.totalCount = totalCount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
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

    public String getReceiverAddress() {
        return receiverAddress;
    }

    public void setReceiverAddress(String receiverAddress) {
        this.receiverAddress = receiverAddress;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    public String getWlNo() { return wlNo; }
    public void setWlNo(String wlNo) { this.wlNo = wlNo; }

    public List<CartItem> getItems() {
        return items;
    }

    public void setItems(List<CartItem> items) {
        this.items = items;
    }

    /**
     * 向订单中添加一个购物车项（商品）
     *
     * @param item 待添加的购物车项对象
     */
    public void addItem(CartItem item) {
        this.items.add(item);
    }

    /**
     * 判断订单当前是否处于“待付款”状态
     *
     * @return 若状态为待付款返回 true，否则返回 false
     */
    public boolean isPendingPayment() {
        return "待付款".equals(status);
    }

    /**
     * 判断订单当前是否处于“已付款”状态
     *
     * @return 若状态为已付款返回 true，否则返回 false
     */
    public boolean isPaid() {
        return "已付款".equals(status);
    }

    /**
     * 判断订单当前是否处于“已发货”状态
     *
     * @return 若状态为已发货返回 true，否则返回 false
     */
    public boolean isShipped() {
        return "已发货".equals(status);
    }

    /**
     * 判断订单当前是否处于“已完成”状态
     *
     * @return 若状态为已完成返回 true，否则返回 false
     */
    public boolean isCompleted() {
        return "已完成".equals(status);
    }

    @Override
    public String toString() {
        return "Order{" +
                "orderId='" + orderId + '\'' +
                ", userId=" + userId +
                ", username='" + username + '\'' +
                ", createTime=" + createTime +
                ", totalAmount=" + totalAmount +
                ", totalCount=" + totalCount +
                ", status='" + status + '\'' +
                ", receiverName='" + receiverName + '\'' +
                ", receiverPhone='" + receiverPhone + '\'' +
                ", receiverAddress='" + receiverAddress + '\'' +
                ", remark='" + remark + '\'' +
                ", items=" + (items != null ? items.size() : 0) +
                '}';
    }
}
