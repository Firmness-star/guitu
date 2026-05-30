package com.flower.service;

import com.flower.dao.CategoryDao;
import com.flower.entity.Category;
import java.util.ArrayList;
import java.util.List;

/**
 * 商品分类服务实现类
 * 负责处理商品分类相关的业务逻辑，提供分类查询功能
 */
public class CategoryServiceImpl implements ICategoryService {

    private CategoryDao categoryDao;

    CategoryServiceImpl() {
        this.categoryDao = new CategoryDao();
    }

    /**
     * 获取所有商品分类列表
     *
     * @return 包含所有分类对象的列表，若不存在则返回空列表
     */
    @Override
    public List<Category> findAllCategories() {
        List<Category> list = categoryDao.findAll();
        return list != null ? list : new ArrayList<>();
    }

    /**
     * 获取所有一级分类（父级 ID 为 0）
     *
     * @return 一级分类列表，若不存在则返回空列表
     */
    @Override
    public List<Category> findParentCategories() {
        List<Category> list = categoryDao.findParentCategories();
        return list != null ? list : new ArrayList<>();
    }

    /**
     * 根据父级 ID 获取对应的二级分类列表
     *
     * @param parentId 父级分类的 ID
     * @return 子分类列表，若参数无效或不存在则返回空列表
     */
    @Override
    public List<Category> findChildCategories(int parentId) {
        if (parentId <= 0) {
            return new ArrayList<>();
        }

        List<Category> list = categoryDao.findChildCategories(parentId);
        return list != null ? list : new ArrayList<>();
    }

    /**
     * 根据分类 ID 获取单个分类详情
     *
     * @param id 分类 ID
     * @return 分类对象，若参数无效或不存在则返回 null
     */
    @Override
    public Category getCategoryById(int id) {
        if (id <= 0) {
            return null;
        }

        return categoryDao.findById(id);
    }
}
