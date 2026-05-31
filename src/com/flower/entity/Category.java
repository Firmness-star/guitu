package com.flower.entity;
import java.io.Serializable;
import java.util.List;

public class Category implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String name;
    private int parentId;
    private String description;
    private List<Category> children;

    public Category() {}

    public Category(int id, String name, int parentId, String description) {
        this.id = id;
        this.name = name;
        this.parentId = parentId;
        this.description = description;
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

    public int getParentId() {
        return parentId;
    }

    public void setParentId(int parentId) {
        this.parentId = parentId;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    /**
     * 判断当前分类是否为一级分类（父级 ID 为 0）
     *
     * @return 若为一级分类返回 true，否则返回 false
     */
    public boolean isParent() {
        return parentId == 0;
    }

    /**
     * 判断当前分类是否为二级分类（父级 ID 大于 0）
     *
     * @return 若为二级分类返回 true，否则返回 false
     */
    public boolean isChild() {
        return parentId > 0;
    }

    public List<Category> getChildren() { return children; }
    public void setChildren(List<Category> children) { this.children = children; }

    @Override
    public String toString() {
        return "Category{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", parentId=" + parentId +
                ", description='" + description + '\'' +
                '}';
    }
}
