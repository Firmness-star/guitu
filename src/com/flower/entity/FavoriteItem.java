package com.flower.entity;

import java.io.Serializable;

/**
 * 收藏商品实体类
 * <p>用于封装用户收藏的单个商品信息</p>
 */
public class FavoriteItem implements Serializable {
    private static final long serialVersionUID = 1L;

    private int productId;
    private String productName;
    private String productPic;
    private double productPrice;
    private String createTime;

    public FavoriteItem() {}

    public FavoriteItem(int productId, String productName, String productPic, double productPrice) {
        this.productId = productId;
        this.productName = productName;
        this.productPic = productPic;
        this.productPrice = productPrice;
    }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getProductPic() { return productPic; }
    public void setProductPic(String productPic) { this.productPic = productPic; }

    public double getProductPrice() { return productPrice; }
    public void setProductPrice(double productPrice) { this.productPrice = productPrice; }

    public String getCreateTime() { return createTime; }
    public void setCreateTime(String createTime) { this.createTime = createTime; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        FavoriteItem that = (FavoriteItem) o;
        return productId == that.productId;
    }

    @Override
    public int hashCode() {
        return Integer.hashCode(productId);
    }
}
