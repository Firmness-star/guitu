package com.flower.entity;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * 购物车项实体类
 * 用于封装购物车中单个商品的信息及小计计算逻辑
 */
public class CartItem implements Serializable {
    private static final long serialVersionUID = 1L;

    private int productId;
    private String productName;
    private String productPic;
    private double productPrice;
    private int quantity;
    private boolean selected = true;

    /**
     * 无参构造函数
     */
    public CartItem() {
    }

    /**
     * 带参构造函数，初始化购物车项基本信息
     *
     * @param productId   商品 ID
     * @param productName 商品名称
     * @param productPic  商品图片路径
     * @param productPrice 商品单价
     * @param quantity    购买数量
     */
    public CartItem(int productId, String productName, String productPic, double productPrice, int quantity) {
        this.productId = productId;
        this.productName = productName;
        this.productPic = productPic;
        this.productPrice = productPrice;
        this.quantity = quantity;
    }

    /**
     * 计算当前商品的小计金额（单价 × 数量），保留两位小数
     *
     * @return 商品小计金额
     */
    public double getSubtotal() {
        return BigDecimal.valueOf(productPrice)
                .multiply(BigDecimal.valueOf(quantity))
                .setScale(2, BigDecimal.ROUND_HALF_UP)
                .doubleValue();
    }

    /**
     * 增加商品购买数量（每次加 1）
     */
    public void increaseQuantity() {
        this.quantity++;
    }

    /**
     * 减少商品购买数量（每次减 1，最低为 1）
     */
    public void decreaseQuantity() {
        if (this.quantity > 1) {
            this.quantity--;
        }
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getProductPic() {
        return productPic;
    }

    public void setProductPic(String productPic) {
        this.productPic = productPic;
    }

    public double getProductPrice() {
        return productPrice;
    }

    public void setProductPrice(double productPrice) {
        this.productPrice = productPrice;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public boolean isSelected() {
        return selected;
    }

    public void setSelected(boolean selected) {
        this.selected = selected;
    }

    @Override
    public String toString() {
        return "CartItem{" +
                "productId=" + productId +
                ", productName='" + productName + '\'' +
                ", productPrice=" + productPrice +
                ", quantity=" + quantity +
                ", subtotal=" + getSubtotal() +
                ", selected=" + selected +
                '}';
    }
}