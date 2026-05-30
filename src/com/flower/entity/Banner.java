package com.flower.entity;

import java.io.Serializable;

public class Banner implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String imgUrl;
    private int productId;

    public Banner() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getImgUrl() { return imgUrl; }
    public void setImgUrl(String imgUrl) { this.imgUrl = imgUrl; }
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }
}
