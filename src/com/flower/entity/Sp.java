package com.flower.entity;

import java.io.Serializable;
import java.util.Date;

/**
 * 商品实体类 (Shang Pin)
 * 用于封装商品的详细信息，包括价格、库存、销量及上下架状态
 */
public class Sp implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String name;
    private String intro;
    private double price;
    private int stock;
    private String pic;
    private String pics;      // 多图 JSON 数组（如 ["url1","url2","url3"]）
    private int categoryId;
    private int sales;
    private Date createTime;
    private int status;

    /**
     * 无参构造函数
     */
    public Sp() {
    }

    /**
     * 带参构造函数，初始化商品的基本展示信息
     *
     * @param id    商品 ID
     * @param name  商品名称
     * @param intro 商品简介
     * @param price 商品价格
     * @param stock 商品库存
     * @param pic   商品图片路径
     */
    public Sp(int id, String name, String intro, double price, int stock, String pic) {
        this.id = id;
        this.name = name;
        this.intro = intro;
        this.price = price;
        this.stock = stock;
        this.pic = pic;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getIntro() {
        return intro;
    }

    public void setIntro(String intro) {
        this.intro = intro;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public int getStock() {
        return stock;
    }

    public void setStock(int stock) {
        this.stock = stock;
    }

    public String getPic() {
        return pic;
    }

    public void setPic(String pic) {
        this.pic = pic;
    }

    public String getPics() { return pics; }
    public void setPics(String pics) { this.pics = pics; }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public int getSales() {
        return sales;
    }

    public void setSales(int sales) {
        this.sales = sales;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    /**
     * 判断商品是否有库存
     *
     * @return 若库存大于 0 返回 true，否则返回 false
     */
    public boolean hasStock() {
        return stock > 0;
    }

    /**
     * 判断商品是否处于上架状态
     *
     * @return 若状态值为 1 返回 true，否则返回 false
     */
    public boolean isOnSale() {
        return status == 1;
    }

    /**
     * 判断商品是否处于低库存预警状态（库存少于 20 件）
     *
     * @return 若库存大于 0 且小于 20 返回 true，否则返回 false
     */
    public boolean isLowStock() {
        return stock > 0 && stock < 20;
    }

    /**
     * 判断商品是否已售罄
     *
     * @return 若库存小于或等于 0 返回 true，否则返回 false
     */
    public boolean isOutOfStock() {
        return stock <= 0;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Sp sp = (Sp) o;
        return id == sp.id;
    }

    @Override
    public int hashCode() {
        return Integer.hashCode(id);
    }

    @Override
    public String toString() {
        return "Sp{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", intro='" + intro + '\'' +
                ", price=" + price +
                ", stock=" + stock +
                ", pic='" + pic + '\'' +
                ", categoryId=" + categoryId +
                ", sales=" + sales +
                ", status=" + status +
                ", createTime=" + createTime +
                '}';
    }
}