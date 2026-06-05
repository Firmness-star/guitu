package com.flower.entity;

import java.io.Serializable;
import java.util.Date;

/**
 * 秒杀活动实体类
 * 包含活动基本信息及关联商品展示字段，提供时间状态判断方法
 */
public class SeckillActivity implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int productId;
    private double seckillPrice;
    private int seckillStock;
    private int perUserLimit;
    private Date startTime;
    private Date endTime;
    private int status;        // 0=关闭 1=开启
    private Date createTime;

    // JOIN 查询后的商品展示字段（非数据库字段）
    private String productName;
    private String productPic;
    private double productPrice;

    // 计算字段（非数据库字段）
    private int soldCount;     // 已售数量（由 DAO 查询计算）

    public SeckillActivity() {
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public double getSeckillPrice() { return seckillPrice; }
    public void setSeckillPrice(double seckillPrice) { this.seckillPrice = seckillPrice; }

    public int getSeckillStock() { return seckillStock; }
    public void setSeckillStock(int seckillStock) { this.seckillStock = seckillStock; }

    public int getPerUserLimit() { return perUserLimit; }
    public void setPerUserLimit(int perUserLimit) { this.perUserLimit = perUserLimit; }

    public Date getStartTime() { return startTime; }
    public void setStartTime(Date startTime) { this.startTime = startTime; }

    public Date getEndTime() { return endTime; }
    public void setEndTime(Date endTime) { this.endTime = endTime; }

    public int getStatus() { return status; }
    public void setStatus(int status) { this.status = status; }

    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getProductPic() { return productPic; }
    public void setProductPic(String productPic) { this.productPic = productPic; }

    public double getProductPrice() { return productPrice; }
    public void setProductPrice(double productPrice) { this.productPrice = productPrice; }

    public int getSoldCount() { return soldCount; }
    public void setSoldCount(int soldCount) { this.soldCount = soldCount; }

    /**
     * 判断秒杀活动是否已开始
     */
    public boolean isStarted() {
        return startTime != null && new Date().after(startTime);
    }

    /**
     * 判断秒杀活动是否已结束
     */
    public boolean isEnded() {
        return endTime != null && new Date().after(endTime);
    }

    /**
     * 判断秒杀活动是否正在进行中
     */
    public boolean isOngoing() {
        return status == 1 && isStarted() && !isEnded();
    }

    /**
     * 获取距离秒杀结束的剩余秒数，用于前端倒计时
     * 如果已结束返回 0
     */
    public long getRemainingSeconds() {
        if (endTime == null) return 0;
        long diff = endTime.getTime() - System.currentTimeMillis();
        return diff > 0 ? diff / 1000 : 0;
    }

    /**
     * 获取距离秒杀开始的剩余秒数
     * 如果已开始返回 0
     */
    public long getStartRemainingSeconds() {
        if (startTime == null) return 0;
        long diff = startTime.getTime() - System.currentTimeMillis();
        return diff > 0 ? diff / 1000 : 0;
    }

    /**
     * 判断秒杀库存是否已售罄
     */
    public boolean isSoldOut() {
        return seckillStock <= 0;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        SeckillActivity that = (SeckillActivity) o;
        return id == that.id;
    }

    @Override
    public int hashCode() {
        return Integer.hashCode(id);
    }
}
